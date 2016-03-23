Two days ago, [Jolla](https://together.jolla.com/question/3612/release-notes-
software-update-2-1025-edit-28122013/) have released the second update to
SailfishOS.

The first [update](https://lists.sailfishos.org/pipermail/devel/2013-December/
001693.html) (1.0.1.10) was mostly a bugfix release to shake off some issues
with the stock 1.0 release. There was also a small patch update (1.0.1.12)
which modified a single file, but the change wasn't significant to warrant the
full fanfare. The change could have been applied by manually editing a
configuration file.

Software Update 2 (1.0.2.5) aka Maadajävri, software releases are named after
lakes, is very much a feature release.

New features include:

*  Google calendar sync (from Google, to Jolla)
*  Exchange sync prompt to accept any certificate
*  Camera is enabled in Android apps
*  Camera can be orientated any direction
*  Yandex store updates/uninstalls (for Android apps)

But the biggest and most contrivertial change is probably the new "Advanced
recovery mode".

#### The Attack

There is a potential "Zero Day" flaw in Jolla. It can be exploited as an
["Evil Maid"
attack](https://www.schneier.com/blog/archives/2009/10/evil_maid_attac.html)
and lets someone with physical access can steal your data, and p0wn your
phone.

Create a "Recovery Image", which is a linux kernel with an initramfs bundled
with some pesky instructions. In theory, the instructions could be to copy
data off of the internal memory and upload it to wikileaks using the phone's
own data connection!

Turn off the device, hold volume down and hit the power button and the Jolla
will enter fastboot mode. It will then accept any kernel image deployed via
USB.

You can get an example recovery image (and some tools to make your own) on
[github](https://github.com/djselbeck/jollarecovery). Bundle this onto a
Raspberry Pi (with a battery pack and a short usb cable) and distribute this
pocket sized package to the "maids". For each device, pop the battery (to turn
it off without needing the device unlock code) and boot into fastboot. Attach
the Pi and let the attack run. Reboot the phone normally, and wipe prints.

#### The Controversy

Being able to bypass the device unlock code is certainly a big concern. It is
for this reason, executing arbitrary kernels, that most smartphone vendors
lock their bootloaders to protect their users.

Jolla are marketing as an open device without locking anything down. For
instance, Sailfish does not require Jailbreaking or Rooting. You can just
enable "Developer Mode" from a helpful menu in the settings.

For software prior to 1.0.2.5 henceforth Update2, fastboot is the quickest way
for developers to load their own code to the device. It doesn't require
special cables or a physical hack to the internal hardware (c.f. JTAG).
Neither does it mandate any particular software already on the phone. Useful
for debricking after you have pushed some bad code.

In Update2, Jolla have disabled (or at least placed a restriction on)
fastboot. While this does thwart the evil maid attack as described, it does
affect the tinkerability of the device. According to the release notes, the
lock down will be lifted once a proper fix can be pushed in a later update.

The proper fix is, of course, to only permit fastboot once the device lock
code has been entered. That would alleviate the security concern and preserve
tinkerability. If no device lock has been set, then permit all fastboots.

#### The Workaround

For the time being, we will have to resort to alternative methods to load
custom kernels.

Turning on the device with the volume down key pressed, but wihout a usb cable
will boot from the alternative kernel. Previous versions didn't contain a
recovery, and would drop you into fastboot mode anyway.  
The trick is to find where on the internal flash this recovery image is.

Hint: it isn't /boot/recovery.img.

The real recovery image is stored (raw) in /dev/disk/mmcblk0p21, better known
as /dev/disk/by-partlabel/recovery.

        # dd if=myrecovery.img of=/dev/disk/by-partlabel/recovery
