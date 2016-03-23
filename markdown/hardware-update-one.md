#### Recent Upgrades on Juniper
  
![The *Before* shot](https://blogcondime.s3.amazonaws.com/uploads/crosshair_juniper.jpg)  
IOMMU: I shelled out for the crosshair IV. The ASUS motherboard based on the
890FX chipset. If an upgrade is to feel like an upgrade, then why not a
[RoG](http://rog.asus.com/products/Motherboards/Crosshair_IV_Formula.htm)
setup.

#### New Capabilities

With modern hardware, a kernel compilation takes 10-20 minutes (depending on
how much I removed from a stock genkernel), X takes 20-30 minutes, and KDE
still takes a few hours. It wasn't so long ago that a full (graphical) gentoo
install would take a week or two, minimum.

Now, I can have a usable gentoo system running from stage3 in under an hour. A
working machine up in two (X, opera, fluxbox etc), and leave the rest of the
day for updates and extras to emerge in the background c.f. KDE.

![The thrones of power and memory](https://blogcondime.s3.amazonaws.com/upload
s/cpu_ram_slots_juniper.jpg)

What was once a traditionally computationally and I/O bound task, is no longer
a problem when you have 6 physical cores to emerge packages (all with
/var/tmp/portage in RAM for that extra burst of speed). I can even boost that
to 'make -j11' with parsley's 4 logical cores. So, I find myself turning to
other problems to throw parallel processing power at.

![With great power comes great cooling](https://blogcondime.s3.amazonaws.com/u
ploads/cpu_ram_slots_juniper.jpg)

With great power comes great cooling

#### New Usage Patterns

When emerging many packages (think about what happens when KDE releases a new
minor version), I commonly seen that processor utilisation peaks and dives. A
single core is loaded up as ./configure scripts check the system for the
umpteenth time in series, then make -j11 hits and the console output turns to
a mist of white scrollback. The feeling of the awesome parallel power is short
lived however, and we're back to a single threaded install phase I/O bound by
the Hard Disk and we thank the RAM gods for a job well done. Portage resolved
what is to be the next ebuild to munch, and the cycle starts over again.

I play other games, such as doing runs of low-bit rsa keys. 256-bit keys are
trivial, and 512-bit keys are feasible. 1024-bit keys are out of my league,
but I'm just doing this with spare clock cycles.

What I have discovered is that finite and feasible computations (compiling and
factorizing) probably don't make the best use of a multicore machine. I
decided to partition up the resources instead, dynamically allocating them to
where they would most be needed.

#### New Directions

Next Post, Where I find VMWare and what's so special about an IOMMU.

![Make-It-Work settings correctly applied](https://blogcondime.s3.amazonaws.com/uploads/iommu_enabled.jpg)