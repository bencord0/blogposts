#### S.M.A.R.T.
  
Self-Monitoring, Analysis and Reporting Technology[1] is a useful set of
heuristics that are supposed to provide an advanced warnings of possible drive
failures. With modern Hard Drives in modern Operating Systems, early SMART
errors cause the filesystem to drop into read-only mode.

#### What I've learnt today

During normal computer usage, when the first indicators of drive failure start
to crop up, performance degradation is usually the first indicator as the
hardware itself tries to compensate and work around problems. A few errors is
usually not an issue, and it is expected that all drives are not as reliable
as we might hope.  
However, as errors build up, and the drive runs out of preventative measures
and eventually fails. With SMART, when the first non-fatal errors start
occurring, warning start being flagged.  
This triggers the operating system to drop filesystems on the drive to move
into read-only mode, the user starts finding out when write()s fail and
applications start to throw up errors.

In my LVM[2] setup, any LVs with extents on the failed drive goes into read-
only mode and the recommended course of action is to check status of relevant
mirrors, and start to pvmove extents onto drives with free extents. I admire
the design of this clever algorithm[3].

If you catch the SMART status flags early, then pvmove is generally a safe
thing to do. If not, then you need to start looking at backups.  

#### Foreseeable problems

You've committed all LV extents and you have no free (or not enough) extents
on undamaged disks, pvmove won't start because it knows that it cannot finish.  
Add more PVs, or shrink some LVs (remembering to shrink the filesystems first)
to resolve the issue.

pvmove won't help, read()s don't even work any more. You've lost data, go
find your backups, or use LVM mirrors.  

#### LVM Mirrors: setup, failure and recovery

    lvcreate volgroup -n newLV -10G
    lvconvert -m1 /dev/volgroup/newLV

creating a 10 gigabyte, linear LV, then convert it to a mirror of the LV.

LVM will not place mirrored extents on the same drive.  

The -m flag can also be used during lvcreate to do this in one step. The
number specifies how many mirrors there will be in addition to the master
linear volume.

If one side of the mirror fails (I/O errors, disk death, drive removal etc),
LVM converts the volume to a linear drive and read()/write() operations can
continue to work.

Replace the drive, partition and add the new disk to the LVM. Now you can
rebuild the mirror. Just in-case the other side of the mirror fails soon.  

    gdisk /dev/sdX  
    pvcreate /dev/sdX1  
    vgextend volgroup /dev/sdX1  
    lvconvert -m1 /dev/volgroup/MyLV

  
Note: LVM is capable of handling PVs and LVs larger than 2TB. Traditional MBR
has some limits with partitions larger than 2TB which GPT solves. Hence gdisk
instead of fdisk.

For most home usages, single disk failures are the most common. It isn't very
common for 3 drives of a RAID5 to fail at once[4]. There is a good series of
documentation from centos[5] all about LVM mirrors and contingency for when
things go wrong.

[1] <http://en.wikipedia.org/wiki/S.M.A.R.T.>  
[2] <http://tldp.org/HOWTO/LVM-HOWTO/>  
[3] <http://linux.die.net/man/8/pvmove>  
[4] Not common, but it has occured to me before. On a server that is at least
two generations of Moore's Law with drives that have not been used for a
while.  
[5] <http://www.centos.org/docs/5/html/Cluster_Logical_Volume_Manager/mirrorrecover.html>

