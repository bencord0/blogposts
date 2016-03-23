There's a cool trick where you can efficiently share a filesystem with a VM.
Until Linux Containers beef up their security from first principals, hardware
emulation is one of the stronger methods of locking down and isolating
services.

Undeniably, setting up containers is much easier than curating VM image
templates. The [systemd-nspawn](http://man7.org/linux/man-pages/man1/systemd-nspawn.1.html#EXAMPLES)
man page has many examples of creating the base filesystem layout and
"booting" into them.

Current container systems like docker and systemd-nspawn suffer from a vital
requirement. At somepoint, they need to run as root. Hardware emulators 
such as qemu, gained the support for user-mode running years ago.

Here's a neat trick, to go from stage3 tarball, to booting an isolated system.
A filesystem (or really, just a directory that looks like a rootfs) from the host
can be passed to qemu as the the boot volume via the 9p virtual filesystem.

    qemu-system-x86_64 \
        -fsdev local,path=~/root9p/,security_model=none,id=dev9p \
        -device virtio-9p-pci,fsdev=dev9p,mount_tag=root9p \
        -kernel /path/to/linux \
        -append 'root=root9p rootfstype=9p console=ttyS0 rw init=/usr/lib/systemd/systemd' \
        -nographic

The provided kernel doesn't have to be anything fancy, upstream linux with the 9p
filesystem enabled is sufficient, you don't even need an initramfs.

Systemd is used because it requires less setup than sysv-init/OpenRC. Systemd tends
to automatically detect that it is running under virtualisation, that various
filesystems are missing and it knows how to create runtime users and temporary files.

The plan9 virtual filesystem is setup with -fsdev and -device directives.
fsdev converts a host filesystem to a device id. device converts the device id
into something mountable as the root= directive.

User mode networking is enabled by default if no net directives are used.
It's not the most efficient driver, but it works without needing to be root.

Using the serial console (ttyS0 and nographic) is a quick way to try this
on servers or if you want to have your terminal do scrollback for debugging.
