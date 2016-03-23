Hi future me,  
Sometimes you're going to find yourself needing to boot some very archaic CDs.
But CD drives might not exist in the future, so you're stuck with USB to shim
the ISO. (I think that first sentence should get all of the Google hits, but
lets include some more buzzwords such as LiveCD, LiveUSB, syslinux etc.)

What you need is a syslinux USB drive (SD cards work too), and make use of the
memdisk "kernel", which really isn't a kernel.

The idea is to boot syslinux from bios/mbr, then use memdisk (provided by
syslinux in /usr/share/syslinux/memdisk or ./memdisk/memdisk from built
source) to boot the ISO.

A better option would be to follow the [Gentoo
LiveUSB](http://www.gentoo.org/doc/en/liveusb.xml), but we can't always be
assured that the boot process will be that simple, e.g. DOS and it's many
variants.

#### The real bit

Assuming that syslinux is installed on D:\ (because this is a windows guide),
with a pre-existing D:\syslinux.cfg (because you followed the Gentoo guide
above).

Place memdisk and your iso file (as an iso file, no raw writing to disk here!)
in D:\ too.

Add this entry to syslinux.cfg

    label myisofile  
      kernel memdisk  
      initrd myisofile.iso  
      append iso