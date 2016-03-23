Hey future me! I know it's not that often that you require it, but there are a
lot of virtualization solutions out there that use qemu as a backend machine
translator.

It isn't the most optimal vm environment when used on it's own, but it
provides some useful features that other projects build upon.

There's KVM, Xen-HVM and when you need it in a pinch, raw qemu itself. But
there's something that you've never gotten right. Not without external tools
and graphical managers. Networking.

So, here's a quick reference.

_startvm.sh_  

    #!/bin/sh
    BRIDGE=$(/sbin/ip route list | awk '/^default / { sub(/.* dev /, ""); print $1}')
    TAP=$(sudo tunctl -b -u $USER)
    sudo ifconfig $TAP promisc up
    sudo brctl addif $BRIDGE $TAP`

    qemu-system-x86_64 \
        -hda \
        -cdrom -boot 'dc' \
        -m 1024 \
        -net nic -net tap,ifname=${TAP},script=no,downscript=no

    # Dissappearing network interfaces will be removed from the bridge automatically.
    sudo tunctl -d $TAP

The requirement are that you use modern networking, iproute2, bridge-utils and
usermode-utilities (for tunctl). Also, it's a good idea to attach the
eth0/eth1 interfaces to a bridge. There's no need for external scripts that
are stored in distro specific locations, and if bridged networking is used
anyway, there's no extra legwork outside this script.

_/etc/conf.d/net_  

    bridge_br0="eth1"
    config_eth0="null"
    config_eth1="null"
    rc_need_br0="net.eth1"`
    config_br0="dhcp"

