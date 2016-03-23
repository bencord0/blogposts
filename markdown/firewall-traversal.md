In the world of video conferencing, one of the most annoying aspects of
networks are firewalls. When setting up calls, a lot of ports are needed. RTP
requires a port for media in each direction, plus their RTCP port (usually RTP
port + 1). Double that number again for the audio channels and just for luck,
add an extra port for BFCP/H.239 content.

For a company that relies on video conferencing, multiplying this many ports
by the number of external calls they expect to have concurrently, and this
poses a problem.  
  
Ideally, firewalls shouldn't be needed and the problem goes away.
Alternatively, poke some holes through your corporate firewall. This doesn't
work since now you're exposing ports that are expecting a high volume of
random (possibly encrypted) udp data. It also doesn't work since RTP traffic
usually uses dynamic ports which is why protocols such as SDP exist in the
first place.

Tandberg developed a very nifty solution for firewall traversal which exploits
the useful fact that most firewalls are implemented to allow outgoing traffic,
and prevent incoming traffic.

Essentially, setup one box outside the firewall (known as the traversal
server) and one box inside the firewall (the traversal client). The client
connects to the server and creates a path of two way communication through the
firewall. When the server gets messages from the outside world, it can play
the proxy role, add some routing information and send it to the inside world
to the traversal client.

It's a great solution, it just involves trusting some expensive and
proprietary boxes that all your calls have to go through. But that's fine, you
use encryption[1].

So, you're not going to lower your firewalls, nor poke holes in them, nor use
a series of standard protocols that have been designed in the open to solve
this very problem. You need a more... trusting solution.

One of the solutions of the most paranoid (yes, they really do this) is to get
two C90s[2]. One sits in the internal network and the other in a DMZ. Then,
plug the inputs of one to the outputs of the other and setup a call. Others
point the camera at each other's screen and have a physical separation;
probably sitting in a vacuum box.

Ahh, the lengths some people go through. Of course, there are other ways to do
this c.f. The Skype method.

[1] Only, it is encrypted between peers, and that box needs to be able to
decrypt and modify some headers to do it's job.  
[2] http://www.tandberg.com/telepresence-products/telepresence-engine-c90.jsp
Note, the video mentions 'firewall traversal' with a nice graphic of a VCS.