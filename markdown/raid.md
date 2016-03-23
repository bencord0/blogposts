I'm rebuilding juniper this weekend. It was getting a bit crufty recently. Now
that I've had a chance to get comfortable with Xen, I think I am ready to
attempt putting windows under HVM using the IOMMU and getting VGA Passthru to
work.

** The goal is simple, get a full-time Linux desktop which can still play games.**

I am aware that Valve/Steam is planning a Linux client, but I'm impatient. I
also might learn something along the way.

In the meantime, I've noticed that there have been a few updates to LVM since
I last _vgcreate_'d. RAID topologies are now possible without resorting to
special hardware cards, or the dreaded _mdadm_.

[http://sources.redhat.com/cgi-bin/cvsweb.cgi/LVM2/doc/lvm2-raid.txt?rev=1.3
&content-type=text/x-cvsweb-markup&cvsroot=lvm2](http://sources.redhat.com
/cgi-bin/cvsweb.cgi/LVM2/doc/lvm2-raid.txt?rev=1.3&content-type=text/x-cvsweb-
markup&cvsroot=lvm2)

My plan, as always, is to have LVM responsible for carving out block devices,
but I'm taking it a bit further this time. LVM supports the idea of "Bootable"
LVs. In practice, the place a small boot partition as the first LV in a PV and
bios should be able to use it. The advantage is that this LV can be mirrored
onto other PVs.

Another thing I might try out is [XtreemFS](http://xtreemfs.org). It is pegged
as being a cloud scalable, drop-in replacement for NFS. It offers abilities
such as ad-hoc expansion: just add more OSDs, resiliance: files can be stored
in more than one OSD, performance: you can retrieve files from your nearest
OSD or from multiple OSDs simultaneously and finally, fail-over: choose
another OSD on the fly if the current one goes down.

OSD: Object Storage Device, aka. where files are actually written.
[XKCD:908](http://xkcd.com/908/) style.

<http://www.youtube.com/watch?v=6WP0V5ABMUA>

