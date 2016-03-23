_This was originally supposed to be a short comment to **Default Security part
2**[0], but that got quickly out of hand. I'm hoping that pingbacks work._

[0] <http://people-and-technology.blogspot.com/2011/09/default-security-
operating-systems-part_07.html>

For an example of updates explicitly designed for security, see [1] and [2].
Here is an example of the DigiNotar CA breach (it is arguable that the ssl CA
system itself is flawed, but that's an issue for another blog post), and how
updates protect end users in real-time.

What happened is that someone managed to launch a practical attack on some
websites (read: gmail), but was thwarted (a month later) by some extra
checking that the Chrome browser does.

The software updates are instructions to tell software and Operating Systems
to blacklist any certificate that can be traced to that CA. The blog posts
explain how it works in Qt, but I should also point out that this morning, I
had a 57k Windows Security Update on my work desktop that addressed this issue
too.

I'm personally sceptical of software firewalls (and anti-virus software). A
good firewall/anti-virus should *NOT* need administrative privileges to run.
You can ask me about this later, because the reasoning is quite detailed for a
comment box.

Actually, I don't trust software firewalls at all. I may be a little bit bias,
considering my employment, but the separation between a hardware firewall and
your active system(s) is important. Also, I work with protocols and network
topologies that are explicitly designed with firewalls in mind[3].

The perfect network firewall is an air gap between your cables. Since that's
not the most practical solution (however, there are some implementation out
there, see [3]). The most common default for a firewall permits all outbound
traffic, but no inbound traffic. There is of course a provision that a replies
to outbound requests are let through too, otherwise that's just blind-fireing
IP packets.

For the more complicated firewalls, there is a need to define "out" and "in"
by hand first.

For Cisco ASAs, one defines each port/sub-network to a security level (integer
between 0 and 100 inclusive). Any traffic from a high level to a lower level
is permitted (plus replies), and any traffic from low to high is blocked. The
rest is up to exceptions and policies. E.g. letting certain traffic from low
to high, and blocking some other high to low traffic.

Protocols like Assent exploit this return path and use it to tunnel data
through the firewall. This even works for udp. Other protocols, UPnP springs
to mind, request the firewall to open up pin-holes and let connections
through. Just watch out for so-called 'smart' firewalls which use packet
inspection and change the bitstream ([mis-]configurable of course) to spoof
where the data is really coming from. This tends to be an issue for some
home/smb routers that claim to be 'sip-aware' or something else meaningless.

[1] <http://labs.qt.nokia.com/2011/09/02/what-the-diginotar-security-breach-means-for-qt-users/>  
[2] <http://labs.qt.nokia.com/2011/09/07/what-the-diginotar-security-breach-means-for-qt-users-continued/>  
[3] **[Firewall Traversal](http://blog.condi.me/blog/firewall-traversal/)**

