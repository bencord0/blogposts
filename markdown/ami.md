Modern cloud computing doesn't install the same way that "bare-metal" and
traditional virtualisation system use. As I have discussed
[before](http://bencord0.wordpress.com/2013/05/02/core/), they may not even be
using a boot loader. This has a dramatic effect on the way cloud servers (aka.
instances) are booted.

A first principles approach to converting from traditional systems to the
cloud, is to take a raw disk image, and use that in the virtual environment.
OpenStack lets you do this, and it will work but there are a few things you
can do to improve performance.  

#### Cloud-init

Use paravirtualization drivers. Commonly known as virtio-[something], these
will offer better performance than letting the hypervisor emulate standard
hardware.

Use cloud-initialization routines. The ubuntu _cloud-init_ package (ported to
Fedora, Debian and SUSE derivatives, emulated by other packages by other
distros) is a good way to individualise a cloud _instance_ once it has booted
to make adjustments from the shared cloud _image_. Such changes include using
deploy-time ssh keys (and possibly other security tokens) instead of relying
on a shared password (or other secrets), configuration management hooks (e.g.
puppet or chef) etc.

Another feature of cloud elasticity is the ability for services to scale
vertically. Just ask for more resources from the virtual environment. Giving
more CPU cores or more RAM doesn't require sending an engineer to open cases
and adding chips. Similarly, expanding HDD space isn't a hands-on task, but
requires some tweaks.  

#### Image format

I have already mentioned raw disk images. From traditional metal servers these
are easily imported to into OpenStack, but suffer performance issues on common
cloud operations, booting, snapshotting, resizing etc. require that the images
are copied in their entirety as the hypervisor (and related tooling) remains
agnostic to the bytes.

Using qcow2 images (from the qemu suite), a Copy-on-Write format is a
virtualisation efficient way to store images. It supports compression and
encryption and has a happy ability to use read-only backing stores and uses a
separate file for changes. If many instances use the same image, then they can
all use the same read-only starting point.

Elasticity, the ability to grow and shrink filesystems in the cloud, is
provided by another technique that is realised by the use of cloud systems.
Doing away with the bootloader, means that we can avoid using MBR and related
structures. The most prominent being fixed sized _Partitions_.  

#### The AMI format

The Amazon AWS cloud is primarily based on the Xen PV system. Kernel and
ramdisk are already outside of the filesystem as AKIs and ARIs (I'll explain
those in a bit). The meat of an Amazon image is the Amazon Machine Image, the
AMI.

From a bits and bytes point of view, an AMI is the literal filesystem. I don't
think this is actually documented anywhere, but that is all there is to it. An
AMI is the raw representation of a root filesystem (typically ext4).

A cloud environment such as AWS or OpenStack can use an AMI, combined with an
AKI and optional ARI to efficiently create a cloud instance. This boot method,
with nomenclature to remind us who named it, I will call _The AMI boot
method_.  

#### The AMI boot method

  
Step 1: Grab the AMI (a root filesystem) and apply it to a disk/block device
to be given to the hypervisor.

Step 2: Resize it to the flavor (typically sans u, blame American centric
developers), say 20G. This is the important step unique to the AMI format,
since there's no partition information in the user provided image, resizing
the filesystem is as easy as resizing the filesystem.

Step 3: Use the metadata stored with the AMI to apply the AKI and ARI (stored
separately).

Step 4: Let the hypervisor (Xen, KVM/qemu etc) can now go wild.  
Other hypervisors might inject the kernel/initrd into the filesystem, add some
bios boiler plate and boot it emulating the traditional process. I haven't
checked, but that is certainly possible.

OpenStack takes a further optimization (other clouds might do this too). While
the AMI is transported and handled by the user as a raw representation of a
filesystem (i.e. you can loop mount the bytes), glance stores and manipulates
AMIs using qcow2, so you get all of the goodies such as quick copies,
compression etc transparantly.  

#### Creating AMIs

Create a block device, and put a filesystem on it.  

    # lvcreate vg -n my_ami -L 10G  
    # mkfs.ext4 /dev/vg/my_ami  
    # mkdir /mnt/amiroot && mount /dev/vg/my_ami /mnt/amiroot

Alternatively, use a loopback device  

    # qemu-img create -f raw my_ami.img 10G  
    # mkfs.ext4 my_ami.img # No partitioning, no offsets involved  
    # mkdir /mnt/amiroot && mount -o loop my_ami.img /mnt/amiroot

Curate your linux rootfs under _/mnt/amiroot_ using methods that I have
already discussed in this blog. Perhaps by stage3 install, debootstrap or even
rsync from a live server. Now is a good time to install cloud-init, enable the
ttyS0 console and do other tasks that you want all instances based on this
image to have.

At this point, you might want to also add a kernel to the filesystem using the
distro's package manager. But you can save some space if you have a cloud-
ready kernel/ramdisk prepared.

The above commands created a filesystem that was 10G in size. Stored raw, this
is a bit unwieldy (even with filesystem holes) since uploads of this image
will send the literal zeroes.  

    # AMI_IMG=/dev/vg/my_ami or AMI_IMG=my_ami.img  
    # e2fsck -f $AMI_IMAGE  
    # resize2fs -M $AMI_IMAGE  
    # BLOCK_COUNT=$(tune2fs -l $AMI_IMG|awk '/Block count:/ {print $3}')

Fsck needs to run prior to any resizing efforts. The resize itself uses the -M
flag, which will shrink the filesystem automatically without the user needing
to guess how small it needs to be. The filesystem's size can be retrieved
using tune2fs, we store it in $BLOCK_COUNT.

By default, ext4 will use a block size of 4096 bytes per block. Thus the
filesystem size is 4096 * $BLOCK_COUNT.  

#### Uploading AMIs

Start with the AKI and ARI.  

    # KERNEL_ID=$(glance image-create \  
     --name="my_aki" \  
     --disk-format=aki \  
     --container-format=aki \  
     < boot/vmlinuz-* \  
     | awk '/ id / { print $4 }')  
    # INITRD_ID=$(glance image-create \  
     --name="my_ari" \  
     --disk-format=ari \  
     --container-format=ari \  
     < boot/initrd-* \  
     | awk '/ id / { print $4 }')

Adapt the command to your needs. The AKI and ARI are real kernels and
initramfses, the real ouput from a kernel build/install and might already be
compressed.

To link the kernel and ramdisk to the main image, we save their UUIDs and add
them to the AMI metadata.  

    # dd if=$AMI_IMG bs=4096 count=$BLOCK_COUNT \  
    >    | glance image-create \  
    >    --name="my_ami" \  
    >    --disk-format=ami \  
    >    --container-format=ami \  
    >    --property kernel_id=${KERNEL_ID} \  
    >    --property ramdisk_id=${INITRD_ID}

We only upload the necessary bytes to glance. Typically only a few hundred MB,
not the full 10G.  