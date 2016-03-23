## or Why I Almost Lost Data Today

Some of you who follow my twitter may already know that one of the inevitable
misfortunes that can happen within a computer centric lifestyle is [Hard Drive
Failure](http://en.wikipedia.org/wiki/Hard-disk_failure). Let me tell you what
has happened to me.  

For one person, I have a lot of hard drives floating around.

Not including the many drives that I have killed over the years. I've learned
a few things about hard drives. For instance, NEVER buy, borrow or otherwise
acquire a hard drive that was manufactured in the Philippines, in my
experience they die in less than a year. The worst example is when I bought
a 500GB external drive in my first year of university, that lasted 3 months...
the enclosure is still in good use.

My collection has spawned by harvesting old drives from computers that get
replaced over time (see Maxtor and Seagate drives). The Spinpoint F1 was the
first 1TB drive I owned, mostly for storing Anime and backups that wouldn't
fit on a laptop. Over time, I started to load up Nutmeg (predecessor to
Juniper) with terrabyte drives when I experimented with setting up a home
server and LVM. I could leave Nutmeg active to do some number crunching while
I went about my day; The WD Cavier Green lineup appealed the most, boasting
low power consumption and high density.

Now when I got a dedicated NAS with an extensive feature set provided by QNAP,
2TB drives were still a little bit too expensive, so I transferred the 4x1TB
drives in Nutmeg to Parsley. Cleaver juggling of bytes to the smaller drives
let me transition to this new solution without loosing data.

Of course, now my big drives are all in one basket so the 2TB Caviar Green,
the latest of my drives, is used as redundancy that I keep in the enclosure
mentioned above. It also helps data juggling when I need to do
maintenance/experimentation on. I should note that QNAP puts a lot of scripts
and abstractions on their NAS (in the name of user friendliness I presume),
unfortunately this prevents me using LVM and hence I'm resorted to store data
on single drives.

Situation Happy.  

Of course, that is until QNAP decided to push Firmware update 3.4. This is a
feature release and includes some nice things like,
[VLAN](http://en.wikipedia.org/wiki/Virtual_LAN) support, Host access lists
for SMB, advanced permissions for the shares and some software updates (new
download manager, new web file manager). If only it had LVM support, this
would be perfect.

The problem that hit me is that the upgrade process makes some changes to QNAP
controlled areas of the hard drive, most of this was stored as persistent data
on HDA and some on HDD. Of course, "something" was on HDA, and the update saw
fit to reinitialize that drive's filesystems. This screwed over my symlinks
and the lack of snapshotting (a feature I miss from LVM) means that there's
very little I can do about it. Looks like I have to find those backups then.

In the meantime, I'm starting to [RAID](http://en.wikipedia.org/wiki/RAID) up
the drives (I now have a free 1TB drive), a candidate for RAID1. Future plans
(such as a transition to 2 or 3 TB drives) may pave the way for RAID 5
migration. Alternatively, I might try to migrate data from the NAS onto future
larger drives, with an overall aim to put Gentoo on the nas and have full
personal control of what goes on LVM mirrors would be nice.

There are many other combinations that I can use, keeping in mind that total
storage space vs redundancy concerns. I don't mind getting larger drives, the
smaller ones serve as adequate backup drives. The question is mostly about
drive configuration.

I'm toying with LVM Striped Mirrors, or LVM over RAID 5. If there is a
solution that doesn't involve RAID, no matter the difficulty, I will consider
it. RAID has some pretty bad limitations, such as forcing the use of same size
drives, no snapshotting etc.

LVM is nice because it offers the ability to add, move or remove PVs while the
LVs are online. There are even some implementations that offer redundancy by
letting some stripes be mirrored (eg. to protect more important LVs) cf. HP-
UX. The current Linux implementation dictates that mirrors and stripes are
mutually exclusive, but one is allowed to have some LVs mirrored, and others
striped within the same VG. The simplest solution with what is available in
Linux right now is to have RAID, with striped LVM on top. This offers dynamic
drive sizes, with some protection against drive failure. This is not entirely
ideal since the protection is uniform for the entire VG.

**Ideas and suggestions in the comments please.**  