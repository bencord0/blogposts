I haven't posted in a little while, so here's a nice juicy tutorial that I've
been working on. There's some more news surrounding this, but I think that
I'll start off with a Homemade Hypervisor for you to sink into.

#### Things you'll need

A clean Gentoo server using systemd. I can provide stage3 tarballs if you need
them to install from. SSH access and PAM accounts are setup (local if you need
them, NIS or LDAP if you can). You have a root login (or can sudo). Host has
static IP address (v4 and v6), DNS resolves and a hostname is set for your
convenience (but nothing in this tutorial depends on correct resolvers). Host
is not a router/DHCP/DNS server or running any other network infrastructure
services. Host interfaces are attached to an internal bridge, "br0".

**/etc/systemd/network/bridge.netdev**

    [NetDev]
    Name=br0
    Kind=bridge

**/etc/systemd/network/ethernet.network**

    [Match]
    Name=enp*
    [Network]
    Bridge=br0

**/etc/systemd/network/host.Network**

    [Match]
    Name=br0
    [Network]
    Address=192.0.2.X/24
    DNS=192.0.2.1
    Gateway=192.0.2.1
    Address=2001:db8::X/64
    DNS=2001:db8::1
    Gateway=2001:db8::1

Host has a volume group named "vg"

    # pvs
     PV         VG   Fmt  Attr PSize PFree
     /dev/sda1  vg   lvm2 a--  2.73t 2.53t
     /dev/sdb1  vg   lvm2 a--  2.73t 2.53t
     /dev/sdc1  vg   lvm2 a--  2.73t 2.53t
     /dev/sdd1  vg   lvm2 a--  2.73t 2.53t

Install xen and libvirt Reboot into Xen Start xen and libvirtd services In
gentoo, you need to do some configuration, so here are some salt states for
you.

**/srv/salt/xen/init.sls**

    # These unit files are taken from Arch, which took them from Fedora.
    # Some additions have been made based on Gentoo's init.d scripts.
    {% for unitfile in [
        'proc-xen.mount',
        'var-lib-xenstored.mount',
        'xenconsoled.service',
        'xenstored.service',
        'xen-watchdog.service'] %}
    /etc/systemd/system/{{ unitfile }}:
      file:
        - managed
        - source: salt://xen/files/{{ unitfile }}
    {% endfor %}
    /etc/xen/xl.conf:
      file:
        - managed
        - contents: |
            vif.default.bridge="br0"
    # Some systems use /run, but the default configuration values use /var.
    /var/lock:
      file:
        - directory
    xen-packages:
      pkg:
        - installed
        - names:
          - app-emulation/xen
          - app-emulation/xen-tools
          - app-emulation/xen-pvgrub
    xen-services:
      service:
        - running
        - enable: True
        - names:
          - xenstored
          - xenconsoled
          - xen-watchdog
        - provider: systemd

**/srv/salt/xen/files/proc-xen.mount**

    [Unit]
    Description=Mount /proc/xen filesystem
    ConditionPathExists=/proc/xenconsoled
    RefuseManualStop=True
    [Mount]
    What=xenfs
    Where=/proc/xenconsoled
    Type=xenfs

**/srv/salt/xen/files/var-lib-xenstored.mount**

    [Unit]
    Description=mount xenstore file system
    What=tmpfs
    Where=/var/lib/xenstored
    Type=tmpfs

**/srv/salt/xen/files/xenstored.service**

    [Unit]
    Description=Xenstored - daemon managing xenstore filesystem
    Requires=proc-xen.mount var-lib-xenstored.mount
    After=proc-xen.mount var-lib-xenstored.mount
    Before=libvirtd.service libvirt-guests.service xendomains.service xend.service
    RefuseManualStop=true
    ConditionPathExists=/proc/xen
    [Service]
    Type=forking
    Environment=XENSTORED_ARGS=
    Environment=XENSTORED_ROOTDIR=/var/lib/xenstored
    EnvironmentFile=-/etc/conf.d/xenstored
    PIDFile=/var/run/xenstored.pid
    ExecStartPre=/bin/grep -q control_d /proc/xen/capabilities
    ExecStartPre=-/bin/rm -f ""/tdb*
    ExecStartPre=/bin/mkdir -p /var/run/xen
    ExecStart=/usr/sbin/xenstored --pid-file /var/run/xenstored.pid
    ExecStartPost=/usr/bin/xenstore-write "/local/domain/0/name" "Domain-0"
    ExecStartPost=/usr/bin/xenstore-write "/local/domain/0/domid" "0"
    [Install]
    WantedBy=multi-user.target

**/srv/salt/xen/files/xenconsoled.service**

    [Unit]
    Description=Xenconsoled - handles logging from guest consoles and hypervisor
    Requires=proc-xen.mount
    After=proc-xen.mount xenstored.service
    ConditionPathExists=/proc/xen
    [Service]
    Type=simple
    Environment=XENCONSOLED_ARGS=
    Environment=XENCONSOLED_LOG=none
    Environment=XENCONSOLED_LOG_DIR=/var/log/xen/console
    EnvironmentFile=-/etc/conf.d/xenconsoled
    PIDFile=/var/run/xenconsoled.pid
    ExecStartPre=/bin/grep -q control_d /proc/xen/capabilities
    ExecStart=/xen/sbin/xenconsoled --log= --log-dir=
    [Install]
    WantedBy=multi-user.target

**/srv/salt/xen/files/xen-watchdog.service**

    [Unit]
    Description=Xen watchdog daemon
    Requires=proc-xen.mount
    After=proc-xen.mount
    ConditionPathIsDirectory=/proc/xen
    [Service]
    Type=forking
    ExecStart=/usr/sbin/xenwatchdogd 30 15
    KillSignal=USR1
    [Install]
    WantedBy=multi-user.target

**/srv/salt/libvirt/init.sls**

    app-emulation/libvirt:
      pkg:
        - installed
    /etc/libvirt/libvirtd.conf:
      file:
        - managed
        - contents: |
            unix_sock_group = "qemu"
            log_level = 1
            log_outputs="1:stderr"
    libvirt-services:
      service:
        - running
        - enable: True
        - names:
          - libvirtd
          - virtlockd.socket
        - provider: systemd
        - watch:
          - file: /etc/libvirt/libvirtd.conf

#### Define storage and networking

There is no salt module to do this (yet?), but it only needs to be done once.

    cat << EOF > pool-default.xml
    <pool type='dir'>  
         <name>default</name>  
         <source>  
         </source>  
         <target>  
                 <path>/var/lib/libvirt/images</path>  
         </target>  
    </pool>
    EOF
    virsh pool-define pool-default.xml
    cat << EOF > pool-vg.xml
    <pool type='logical'>  
         <name>vg</name>  
         <source>  
                 <name>vg</name>  
                 <format type='lvm2'/>  
         </source>  
         <target>  
                 <path>/dev/vg</path>  
         </target>  
    </pool>
    EOF
    virsh pool-define pool-vg.xml

You may need to undefine the preconfigured virbr0

    virsh net-destroy default
    virsh net-undefine default

Define a bridge to attach VM networking to

    cat << EOF > net-default.xml
    <network ipv6='yes'>  
         <name>default</name>  
         <forward mode='bridge'/>  
         <bridge name='br0'/>  
    </network>
    EOF

    virsh net-define net-default.xml
    virsh pool-start default
    virsh pool-autostart default
    virsh pool-start vg
    virsh pool-autostart vg
    virsh net-start default
    virsh net-autostart default
    virsh pool-list
    virsh net-list

#### Starting a new VM

Download a VM image to run. I'm using an all-in-one kernel (with integrated
initramfs) which boots into a live environment. You can build one using the
instructions on [GitHub](https://github.com/bencord0/genboot). Also, take the
time to create a unique ID for this VM and provision an LV.

    wget https://dl.condi.me/gentoo-systemd/latest/vmlinuz
    cp vmlinuz /var/lib/libvirt/images/gentoo-systemd
    UUID=$(uuidgen)
    virsh vol-create-as vg $UUID 50G

Define a new VM. I deploy a lot of servers and throwing VNC around my network
isn't desirable, so I'm only using a serial console.

    cat << EOF > vm-$UUID.xml
    <domain type='xen'>  
         <name>vm-$UUID</name>  
         <uuid>$UUID</uuid>  
         <memory unit='GiB'>1</memory>  
         <os>  
                 <type arch='x86_64' machine='xenpv'>linux</type>  
                 <kernel>/var/lib/libvirt/images/gentoo-systemd</kernel>  
         </os>  
         <devices>  
                 <disk type='block' device='disk'>  
                         <source dev='/dev/vg/$UUID'/>  
                         <target dev='xvda' bus='xen'/>  
                 </disk>  
                 <interface type='bridge'>  
                         <mac address='00:00:00:00:00:00'/>  
                         <source bridge='br0'/>  
                 </interface>  
        <serial type='pty'>  
          <target port='0'/>  
        </serial>  
                 <console type='pty'>  
                         <target type='xen' port='0'/>  
                 </console>  
         </devices>  
    </domain>
    EOF
    virsh define vm-$UUID.xml

Start the vm

    virsh start vm-$UUID

Enter the console

    virsh console vm-$UUID

You can "ctrl + ]" to exit the console

Destroy and cleanup

    virsh destroy vm-$UUID
    virsh undefine vm-$UUID
    virsh vol-delete $UUID --pool vg
    rm vm-$UUID.xml