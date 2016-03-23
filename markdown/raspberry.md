The currently recommended image for Raspberry Pi is the Debian based
[Raspbian](http://raspbian.org) distro.

Playing in this sandbox is a new experience for me. It feels like the Linux
I'm used to, but there are some subtle differences. I'd thought I might share
my thoughts and experiences.

I'm used to playing with Gentoo/Linux on x86-64 hardware. My desktop, laptops
and home servers all use the amd64 instruction set. Even my tablet can
understand amd64. This makes it really easy to create Gentoo binpkgs, and
share /usr/portage over nfs.

With a raspberry pi, the first thing I did was to do a stage3 install of
Gentoo for the armv6-hardfp architecture. It took me a little less than a week
to get sound, X and a few useful programs such as fluxbox, mplayer and synergy
(I don't have a spare keyboard/mouse to use, don't need it anyway). Of course,
mplayer could just about play audio files, and video was entirely
unacceptable. Raw Gentoo is not optimized for the Pi, especially since nothing
is hooked into the GPU.

I did learn some lessons. How to setup cross-compilers (crossdev -S). How to
boot a pi (especially interesting since the Pi has no BIOS, or CMOS). Dabbling
with Gentoo first was time well spent.  

#### How to boot a Pi

The Raspberry Pi has no onboard firmware, or anything to store state at all.
The bootloader has to be provided on the SD card.

1. The GPU, on powerup, will scan the SD card for an MBR partitioning layout.
   (I can't use GPT)  
2. Find the bootable partition with a vfat filesystem. (Typically, placed as
   the first partition)  
3. Load bootcode.bin from that partition into the GPU to proceed with the
   rest of the boot process.  
4. Read the optional config.txt and finish booting the ARM with start.elf.  
5. Start the kernel, from kernel.img with options from cmdline.txt  
6. Run init from the root filesystem (which is found from the kernel command line)  
7. If networking is available, run ntp-client asap. Get sshd running too.

From what I can tell, bootcode.bin is a binary blob that tells the GPU what to
do. start.elf comes in many flavours, usually to tell the RAM split between
GPU and ARM host processor. Finally, kernel.img can be cross-compiled from
vanilla/gentoo sources, or use the raspberry pi patches for hardware
compatibility.

The final kernel.img is created by another tool called mkimage, which tacks on
an extra 32k of magic to the compiled kernel image.

The lazy way is to create the fat filesystem, mark it bootable then copy the
contents of https://github.com/raspberrypi/firmware/tree/master/boot into it.
Of course, don't forget to also place the kernel modules into
/lib/modules/`uname -a` on whatever root filesystem is used.

There is no faffing with grub, and editing the boot process can be done from
windows.

It would also seem that the only way to boot a Hard Drive would be to boot
from the SD card, then really boot from a usb hdd. This isn't that hard, since
it should be possible to replace kernel.img with a chosen bootloader, instead
of a kernel.  

#### Debian

I'm now running the raspbian image. I have ssh starting on boot, so I can
login and fiddle without a Keyboard/Mouse (or HDMI Monitor which I don't have
at home). I apt-get install'd synergy and screen so that I can use a spare
monitor at work. (The raspberry pi serves as a great nagios monitoring
display).

Hexxeh has put together a [Chromium build](http://hexxeh.net/?p=328177859),
which I find uses less of the (precious) CPU cycles than Midori. So that has
become by full-fat browser.

It looks like I will be staying with Debian for a little while. Fedora (from
the QtonPi project) seemed unfinished, they're moving to OpenSUSE anyway.
Ubuntu won't support the Pi because ARMv6 is too ancient for Canonical. Gentoo
worked well, but I probably won't try that again until I can get GPU
drivers/libraries in ebuild form. Of course, if the Chrome OS (which is
essentially Gentoo) port is finished, then I'd gladly try that too.

One last thing that I've been attempting is to read the [Debian
Reference](http://www.debian.org/doc/manuals/debian-reference/) and [Debian
Handbook](http://debian-handbook.info/). Once I figure out how to do common
tasks (def: tasks that **I** find common) such as kernel
recompile/reconfigure, tarball/git repository source code builds then I will
be much happier.  

#### Familiarity from source

From 5 minutes of googling, any tarball or repo with a debian/rules file
(pretty much everything in the floss world) can be dpkg-_buildpackage -us
-uc_'d into a_ ../$package-$version.deb_. Then _dpkg -i_ it into the live
system.

Oh, how I miss epatch_user.