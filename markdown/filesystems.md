![Raspberry Pi and Chromebook
Pixel](http://bencord0.files.wordpress.com/2013/03/13030005.jpg?w=300)
Raspberry Pi and Chromebook Pixel

I haven't had a commercially backed Linux device that I've been excited to use
as much as my Pixel.

One of the things that brightened my day today was the realisation that
Chromebooks support Linux filesystems for SDCards and other removable media.

This opens up a lot of Pi hackery possibilities.

    crosh> shell  
    chronos@localhost / $ cat /proc/filesystems;find /lib/modules/`uname -r`/kernel/fs/  
    nodev   sysfs  
    nodev   rootfs  
    nodev   bdev  
    nodev   proc  
    nodev   cgroup  
    nodev   tmpfs  
    nodev   devtmpfs  
    nodev   debugfs  
    nodev   securityfs  
    nodev   sockfs  
    nodev   usbfs  
    nodev   pipefs  
    nodev   anon_inodefs  
    nodev   devpts  
            ext3  
            ext2  
            ext4  
    nodev   ramfs  
    nodev   ecryptfs  
    nodev   pstore  
            fuseblk  
    nodev   fuse  
    nodev   fusectl  
    /lib/modules/3.4.0/kernel/fs/  
    /lib/modules/3.4.0/kernel/fs/fuse  
    /lib/modules/3.4.0/kernel/fs/fuse/fuse.ko  
    /lib/modules/3.4.0/kernel/fs/isofs  
    /lib/modules/3.4.0/kernel/fs/isofs/isofs.ko  
    /lib/modules/3.4.0/kernel/fs/hfsplus  
    /lib/modules/3.4.0/kernel/fs/hfsplus/hfsplus.ko  
    /lib/modules/3.4.0/kernel/fs/fat  
    /lib/modules/3.4.0/kernel/fs/fat/fat.ko  
    /lib/modules/3.4.0/kernel/fs/fat/vfat.ko  
    /lib/modules/3.4.0/kernel/fs/nls  
    /lib/modules/3.4.0/kernel/fs/nls/nls_iso8859-1.ko  
    /lib/modules/3.4.0/kernel/fs/nls/nls_ascii.ko  
    /lib/modules/3.4.0/kernel/fs/nls/nls_utf8.ko  
    /lib/modules/3.4.0/kernel/fs/nls/nls_cp437.ko  
    /lib/modules/3.4.0/kernel/fs/udf  
    /lib/modules/3.4.0/kernel/fs/udf/udf.ko

  
There is a cool ability to read and modify SDCard images with dd, or the
Chromebook's 'Files' app. There is support for fat, ext4 and hfs+. Sadly,
reiser, ntfs and exFat aren't there to complete the list, but I don't think
anyone uses those (or is it just me?).

Another cool thing that I found was that the pixel comes with the PL2303 usb-
serial driver.  

    chronos@localhost / $ (lsmod;find /lib/modules)|grep pl2303  
    pl2303                 16448  0   
    /lib/modules/3.4.0/kernel/drivers/usb/serial/pl2303.ko

  
Which means that I can [serial](http://www.adafruit.com/products/954) into the
Pi from the Pixel.  

    chronos@localhost / $ minicom -b 115200 -D /dev/ttyUSB0

  
Oh, and remember to disable hardware flow control.