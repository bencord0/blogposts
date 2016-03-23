Hi future me, again.

Did you remember how to mount a file as a block device? Even put a filesystem
and OS on it too.  

    # losetup -f # Will print out the next available loop device  
    # losetup /dev/loop0 /path/to/file.img # Will mount the whole disk image [1]  
    # kpartx -a /dev/loop0 # Will find the partitions [2]  
    # mount /dev/mapper/loop0p1 /path/to/mountpoint # Will mount the first partition [3]

How useful is that?

After the initial losetup to bind the file to a loop block device, you can run
tools like

    dd if=/dev/sda of=/path/to/network/backup.img

or

    gdisk /dev/loop0

if you want to make usb live images.

I'm sure you'll think of something. Don't forget about cleanup,

    # kpartx -d /dev/loop0 # Removes any partition mappings  
    # losetup -d /dev/loop0 # decouples the loop device and closes the file

