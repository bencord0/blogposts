I'm a big fan of the stage3 install method.

Prepare partitions, format filesystems and make a mount point. Extract a root
filesystem into place. Add a kernel and boot loader, reboot and done. The rest
is configuration.

Depending on the platform, where the kernel resides and what the bootloader
does to boot the new rootfs can vary dramatically.

##### x86 (BIOS)

BIOS loads the first 512 bytes of the primary disk into memory and executes
it. Those instructions are the bootloader itself which is then responsible for
finding and running the kernel, which in turn finds the rootfs and runs init.
I'm ignoring extra stages like initramfses or Xen hypervisors.

##### ARM (e.g. Raspberry Pi) and other embedded systems

Hardware scans for a bootloader in some specific place (typically there isn't
a "first disk" like the x86 sequence). That bootloader, in the Raspberry Pi
example, is the GPU firmware which then activates the ARM CPU to run the
kernel, which probes hardware to find the rootfs.

##### Xen PV (e.g. Amazon AWS)

Boot is described by a text file (previously a python script) which contains
definitions for the kernel, filesystems, network and virtual hardware. In PV
mode, the Xen userland tools are the bootloader which runs the provided kernel
in an unprivilaged domain. IO to the guest is provided through Xen to the
Dom-0 transparently.

Xen PV mode has an option to use a modified grub as the loaded kernel which
can boot from a kernel that resides inside the rootfs. There is also a HVM
mode which provides full hardware emulation. This uses the BIOS (or EFI)
method. This is also true for virtualization provided by VMWare, VirtualBox
and some modes of qemu.

PV and HVM modes are no longer binary modes. There is a spectrum of
virtualization that mixes PV and HVM, but the differences manifest once the
guest has booted.

##### EFI (UEFI, including secure boot)

EFI is an extensible successor to BIOS for x86-like platforms. EFI looks for a
specially marked filesystem, typically formatted with the FAT filesystem and
searches for the bootloader using a search list of expected file. names. The
bootloader is not limited to 512 bytes and EFI provides many more functions
that the loader can make use of. EFI systems are most easily recognised by the
use of a GPT partitioning scheme, however some BIOS bootloaders are GPT aware.

##### Qemu/KVM

This is similar to Xen PV mode in that the kernel to be booted resides outside
of the rootfs. Typically, it is provided as command arguments instead of from
a configuration file.

##### Containers (e.g. LXC)

A container does not run a kernel of it's own. Instead it should be an
isolated section of the host that can run an init process without the faff of
bootloaders and kernels.

##### PXE

This boot method involves retrieving the boot components from the network.
(Virtual) Hardware begins by broadcasting for an IPv4 address, server location
and filename to download and execute. This can be used as a rescue boot method
of last resort if a machine was unable to boot using locally available
methods, as a way to provision a common OS environment to a group of hosts or
to run diskless nodes in a terminal server configuration. The rootfs could be
a locally installed block device or a network resource such as an NFS share.

No matter what method is used to boot a computer, the goal is to reach an
environment that is running the rootfs. A system can be booted using any of
the methods above, what defines a Linux distribution is the rootfs.

In Gentoo, this rootfs is provided as a stage3 tarball that is extracted and
configured to the user's requirements. The Gentoo project provides a series of
tarballs tailored for specific architectures.

For Debian based systems, there is the debootstrap script which creates a
Debian rootfs on demand. This rootfs can be treated exactly the same way as an
extracted stage3 and needs a kernel and bootloader to be configured.

Recently, I came across another just-a-rootfs method of installing a distro. A
much less publicised part of an Ubuntu release is the "core" tarball. This is
analogous to a stage tarball for Gentoo. Extract, add a kernel and boot it.

Ubuntu has never made as much sense to me until I found these
[tarballs](http://cdimage.ubuntu.com/ubuntu-core/daily/current/).