Here's a neat trick.  
In almost every Linux install I do these days, I make sure it uses LVM for
partitioning.

This has some advantages over straight up MBR partitions.  
\- Not having to predetermine the sizes of the rootfs, home partitions etc. I
can start with small LVs then lvresize && resize2fs/resize_reiserfs if I ever
hit the end.  
\- Handle hardware expansion elegantly. Adding and removing the underlying
HDDs without worrying about copying files and folders. pvcreate, vgextend,
pvmove then a final pvremove is all I need to replace a Disk that is starting
to show SMART errors.  
\- RAID1-like protection, but only on LVs that need it. Also RAID0-like
striping for performance on SWAP LVs.  
\- Snapshots: OMG! how useful are these?!?! The use cases deserve a post of
their own.

Well, today I found another useful tidbit. Data Migration and vgmerge.

Here's the scene. I've been playing with some new OSes recently. Assessing
them for future "everyday uses". Okay, I admit it, I've been playing with the
Windows 8 Consumer Preview. But this post is less about that. This concerns
the step that everybody recommends you take just before you play with the cool
new shiny.

Backups. The emergency one shot backups that you take just before you wipe the
SSD on your primary computer.

Now, my personal backup method of choice is naive, practical but mostly
predictable. The low level methods are always the best.

I grab the nearest LiveUSB, and dd a backup to a trusty external HDD.  

    # dd if=/dev/sda of=/mnt/external/sda.dd

I originally thought that something along the lines of _dd|xz -fast>sda.dd.gz_
would be a better way to optimize final on-disk size of the backup and the
time to complete the backup. I ended up skipping the compression phase and
choosing the linear I/O of ~80M/s which finishes the snapshot of my 128G SSD
in a timely fashion.  
For the paranoid, this step can also be combined with an encryption pass for
safer keeping.

Backup in hand, I'm brave enough to do anything without the guild of data loss
if something goes amiss.

But what to do with that backup?

1/. Get it on more flexible storage. To me, storing data on external drives
with only one instance seems a bit risky. So move the external HDD to the USB
port on my NAS and copy the nice image onto my NAS for protection.  

    $ cp /mnt/external/sda.dd ~/sdd.dd

  
2/. Loopback the file into a block device.  

    # losetup /dev/loop0 ssd.dd  
    # kpartx -a /dev/loop0  
    # ls /dev/mapper/loop0*

  
3/. Give the drive a scan, repopulate the LVM.  

    pvscan /dev/mapper/loop0p3

  
**WARNING: Duplicate VG name vg: Existing 1mMn1c-0Hom-iHch-80SL-UFS6-2YPE-xMf8kM takes precedence over UxWlJN-z15S-61cO-cU62-z3dU-MyYJ-VQn3OE**

Dammit. Me and my consistent naming schemes!

4/. No matter, easily remedied. Thankfully VG names are not the last way to
differentiate between VGs.  
I pick the smaller VG, the one that looks to be less than 70G, not the one
over 7.2T  

    vgrename  -v 1mMn1c-0Hom-iHch-80SL-UFS6-2YPE-xMf8kM ssdvg

  
5/. Sort out the mess. The important bit is to get of name clashes.  

    # lvdisplay |grep LV\ Name  
      LV Name                /dev/ssdvg/ROOT  
      LV Name                /dev/ssdvg/HOME  
      LV Name                /dev/ssdvg/USR  
      LV Name                /dev/ssdvg/OPT  
      LV Name                /dev/ssdvg/SWAP  
      LV Name                /dev/vg/USR  
      LV Name                /dev/vg/ROOT  
      LV Name                /dev/vg/SHARE  
      LV Name                /dev/vg/SWAP  
    # lvrename ssdvg/ROOT ssdvg/wsROOT  
    # lvrename ssdvg/HOME ssdvg/wsHOME  
    # lvrename ssdvg/USR ssdvg/wsUSR  
    # lvrename ssdvg/OPT ssdvg/wsOPT  
    # lvremove ssdvg/SWAP

  
6/. And here's the magic.  

    # vgmerge vg ssdvg

  
7/. Since that last step was instantaneous, it seems a bit too easy. Of
course, there's the final step to integrating these LVs into my main storage
bank.  

    # pvmove /dev/mapper/loop0p3

  
Let that spool over, LVM will take the appropriate measure to ensure that the
LVs are distributed amongst the remain (long-term) PVs. The tidy up can be
finished with a vgreduce.

8/. Mount the LVs, check that data is all there and accessible. This is the
time to check any checksums of important bits of data.

loop0p1 is the former windows partition. That can be rescued by creating
another LV of appropriate size, then dd-ing loop0p1 into vg/wsWIN.

loop0p2 was the /boot partition, and can be safely ignored or rescued if
really wanted.

