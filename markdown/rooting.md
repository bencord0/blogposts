When I buy hardware (computers, phones etc), I ignore every and all software
features that may be advertised on the box.

Just because my computers could run windows, doesn't mean that I need them
too. Thus, all my computers boot, or dual boot Gentoo/Linux.

Juniper was a no-brainer, it's many cores and high clock speed make it a very
effective build host and/or number cruncher. If I could afford a multi-CPU
machine, then I would have gone for that instead. I settled for a higher-than-
average core count.

#### What Rooting should be like
  
Parsley required a choice. Eventually, I settled on a QNAP device since
they're open about their features, the Linux heritage[1] and the possibility
of shell access to what really matters. Unfortunately for me, any changes to
the root filesystem are non-persistent[2] since the machine boots into an
initramfs which are tricky at best to wield[3]. They are cpio archives saved
to a read/write portion of the internal flash memory. However, checking and
testing changes requires reboots and effort. And a little bit of reverse
engineering to see what QNAP has done.

The good news is that QNAP provide recovery images in-case of random cosmic
ray attack. They even provide documentation about "recovering your device" by
downloading DSL[3] to a USB drive, booting it and recovering it with the help
of the trusty 'cp' command. With a few tweaks this process quickly evolved
into a standard gentoo install.

[1] source code for the GPL'd stuff is downloadable from the website.  
[2] including generating host-ssh keys.  
[3] DamnSmallLinux

#### What Rooting usually is
  
One of the most exciting stories in recent technological history is that Linux
if finally going mainstream. Albeit in the mobile space. Our favourite non-
GNU/Linux distribution, Google's Android is in the wild and is surprisingly
popular.

It is a triumph for open source, fantastic for free software and an agent for
change[4].

Except that, it isn't. The life cycle for production android phones is that
you get the hardware with a pre-installed[5] software image which includes
compiled open source components and proprietary applications and in the case
of HTC(and friends), very proprietary[6] UI.

For most, if you want to do anything non-standard, rooting/jail-breaking a
device is the thing to do.

<https://twitter.com/#!/BlakeFitzmier62/status/74567465488744449>  

#### Aside
  
Theoretically, it should be possible to download source code from upstream
repositories, build them locally without any magic then flash them to the
device. At the end of this process one hopefully has feature parity with the
original official ROM.

Of course, that doesn't happen in android yet, base android is available in
the repositories, but additional apps and some UI features are just not
available. Building the image is sometimes tricky, but documentation can help.
And flashing any created image is highly non-trivial. Compare to parsley,
where all the magic is hidden in a byte for byte copy to the internal flash.
The precise changes and setup I made to parsley probably deserve another blog
post.

[4] read: changes  
[5] and well tested  
[6] yet very nice to use

#### Whar Rooting could be

MeeGo devices do exist, but getting my hands of hardware is difficult.
Personally, I have my eyes on 4tiitoo's WeTab, but I may have to wait for the
v2 hardware that their CEO alluded to in the recent MeeGo Conference in San
Francisco. Hopefully, a UK release too.

HTC recently caused a bit of a storm when they announced that future
bootloaders would be locked down and encrypted. Facebook happened and they now
have made a commitment to using open bootloaders. If this means that one can
load a custom image that is loaded without hacks, then this is most certainly
a good thing.

4tiitoo don't cause that much public anguish. It is just another step in the
life cycle of their device.

Let me explain.

KDE is a popular open source and cross platform Desktop Environment. KDE is
written on top of the Qt framework which gives me even more reason to love it.
Traditionally, KDE has given a very good and adaptable desktop experience, but
it too has been swept up in the tablet excitement.

There exists a netbook specific interface for KDE which serves as proof of
KDE's adaptability. So making a tablet specific UI should be easy[7].

There are bootable images available of plasma-active[8]. As the readme
suggests, one doesn't Root or otherwise hack the device, just boot up from a
USB image. See how open bootloaders can be helpful.

[7] http://community.kde.org/Plasma/Active  
[8] http://download.open-slx.com/iso/11.4/ This one is based on OpenSUSE

#### Recap

I'll never own an iPhone on moral grounds.

Android phones are fun, I have one but only because Nokia were too slow to
market a device that I wanted so I went for one of those nice HTC UIs with a
sliding keyboard. Can you say stopgap?

There is an alternative, it just doesn't exist in this country yet.

MeeGo is a platform that I can morally agree with, support and contribute back
to if I could.

MeeGo Tablet UX is still in development, but the core exists (and has recently
passed version 1.2, 1.3 or 1.4 will have Wayland with the support of Intel).

There exists a German company which decided to market a device based on MeeGo
core, but couldn't be bothered to wait... so they created their own Tablet UX.
This became the WeTab.

The WeTab is a fantastic platform concept and has very few lock-ins.

The KDE community which shares commonality with MeeGo via Nokia's Qt is strong
and vibrant.

KDE is experimenting with new user interfaces and ideas. One of which is the
plasma-active project. It just so happens that plasma-active works very nicely
on tablets.

The WeTab serves as a good proving ground for plasma-active, much like the
N900 did for morally acceptable mobile phones.

I can't wait to get my hands on one.  