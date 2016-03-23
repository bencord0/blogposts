I think I've done it. I now have my own home IaaS.

I went for the [OpenStack](http://www.openstack.org) approach,
[Packstack](https://wiki.openstack.org/wiki/Packstack) with
[RDO](http://openstack.redhat.com/Main_Page) on [Scientific
Linux](https://www.scientificlinux.org/). In the future I want to replace SL6
with Gentoo on the bare metal, and install the OpenStack packages from
portage, but I'll wait for the [work from a Gentoo
dev](https://mthode.org/posts/2013/Jan/openstack-on-gentoo/) who knows what
he's doing.

This also means that the running hypervisor is KVM, not the Xen that I would
rather be using. Technically, there isn't much difference to them, but Xen is
the hypervisor used by AWS, PV images can be booted without fiddling with
partitioning and bootloaders. That's so '90s.

Getting an instance of OpenStack is fairly easy these days. Tools like
[DevStack](http://devstack.org) and PackStack, the plethora of puppet and chef
modules to deploy openstack means that it is really easy to get running. That
is, if you follow the patterns that everyone else did. Compiling from source
and manual configuration by hand and vim is still a chore.

I've only managed to get keystone working when doing it that way.

I chose PackStack on an Enterprise Linux-like distro because it is a well
tested version that offers a straightforward (but tightly controlled) pathway
to add additional nodes. PackStack also plays well in a /24 home environment
without requiring managed switches and offers a bit more persistence than
DevStack.  

#### First Steps

  
Once you have an instance of OpenStack, what next?

To use IaaS, you need a VM image to run. The
[documentation](http://docs.openstack.org/trunk/openstack-
compute/admin/content/starting-images.html) has some links to community
generated images. Of note is the CirrOS test image, the Hello World
Equivalency of any Cloud Architecture. Once it boots and you can ping a few
internet hosts the next step is to try out the Ubuntu or Fedora images. There
are SUSE images, but I didn't have much luck with them, and the Rackspace
Cloud Builders images are just more of the same.

No, there is no Gentoo image provided. A problem that I will use the rest of
this blog post to address.  

#### Deep Dive

  
Like any other modern linux system, instances need to be booted. The
KVM/Libvirt backend emulates the full x86 hardware so we use the [x86
(BIOS)](http://bencord0.wordpress.com/2013/05/02/core/) method. That requires
a disk image with MBR partitions, BIOS bootloader (I'm choosing extlinux) and
all of that mess.

As the system boots, it needs to probe the environment to get some
customizations working. The most important job during boot is to acquire the
ssh public key of a user allowed to login. It also need to set the hostname
(optional) and download (and run) a provided user-data script for parity with
the Amazon Linux and Openstack images. These late-boot jobs I have left to a
[local.d service](https://github.com/bencord0/lxc-create-gentoo/blob/master
/cloud-init.start).

My first image needed to be built by hand from within the provided fedora
image. After creating a blank file, and loop mounting it I went through a
stage3 install.  

#### My Modifications

  

  

  * Clear _/etc/fstab_. The rootfs is mounted by the kernel already, no other filesystem is of interest. (devtmpfs and other kernel filesystems are automounted by the kernel and initramfs before fstab is needed).
  

  * Remove root's password from _/etc/shadow_. An empty password field means that the root user can login from the console without providing credentials. All network logins are denied unless using the correct ssh key. This is also enforced by _/etc/securetty_ which I have left unchanged.
  

  * Enable the _s0_ serial console for _ttyS0_ in _/etc/inittab_. Xen uses the _hvc0_ console.
  

  * Create _/etc/init.d/net.eth0_ symlinked from _net.lo_.
  

  * Add symlinks for _sshd_ and _net.eth0_ to _/etc/runlevels/default_.
  
  
I've posted my kernel [config](https://gist.github.com/bencord0/5659063) to
gist.github.

Here's my _/boot/extlinux.conf_.  

    DEFAULT gentoo  
    LABEL gentoo  
            LINUX /boot/vmlinuz  
            APPEND root=/dev/vda1 console=ttyS0 rootfstype=ext4 earlyprintk=serial  
            INITRD /boot/initramfs  
            SERIAL 0

  
The trick is the last line, _"SERIAL 0"_ which enables bootloader output in
the serial log. Also note that the root filesystem sits on _vda1_, which
requires the virtio drivers. I'm even using the virtio network drivers which
offers better performance for virtual guests. I have unmanaged gigabit
switches inside my network and I did get network speeds faster than the
FastEthernet bottlenet. HDD IO was my real bottleneck.

The last modification that I made was to..  

    useradd -m -G wheel,users ec2-user

  
and  

    extlinux --install /boot

  
from inside the chroot.  

#### Preparing Packaging

  
Shuffling around 10G raw disk images is a pain, worse it takes much longer to
spinup instances. Qemu's qcow2 image format is much more efficient.  

    qemu-img convert -f raw -O qcow2 gentoo.img gentoo.qcow2

  
Finally, upload the image to openstack with glance.  

    source keystonerc  
    glance image-create --name gentoo-$(date +%Y%m%d)-amd64 \  
        --disk-format qcow2 \  
        --container-format bare \  
        --file gentoo.qcow2

  

#### Scripting it together

  
I've put together a [script](https://gist.github.com/bencord0/5659164) that
can be provided to an instance as it boots using the user-data mechanism. It
takes about an hour to run, but could be speeded up by using binhosts and
local downloads.

You should read the script.

There are references to some special tarballs, stage3-latest and portage-
latest are copies of tarballs as distributed by Gentoo. vmlinuz-latest is a
tarball containing the kernel, initramfs and modules without needing to
recompile gentoo-sources. vmoverride-latest is a tarball of the modifications
that I made above.

Since this script is expected to be run from inside the hand made Gentoo
image, emerge can be run from outside the chroot using the ROOT variable
pointing to the chroot. This has the advantage of only installing runtime
dependencies to the chroot.

extlinux needs to be run on a mounted system, bit bashing from outside of the
chroot I have found to be unreliable, so do that from inside the chroot at the
same time as the useradd.  

#### Baked image

  
At the end of all of this, I now have a basic Gentoo image working with
openstack. It is basic and posting this next link probably puts me in
violation of a few GPL clauses. So [here](https://s3.amazonaws.com/parsley-s3
-condi-me/gentoo-20130527.1-amd64.qcow2) it is.

