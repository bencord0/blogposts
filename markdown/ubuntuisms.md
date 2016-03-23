Through no fault of my own, I found myself sitting patiently at my desk
waiting for a progress bar to complete. That was last Friday, the progress bar
was for Ubuntu 11.10 Server 32-bit. The line between me and the 'true'
internet contains a vast array of firewalls, switches, routers, nexuses
(nexii?), IPS and fiber. I don't actually hit the internet until the "local"
pop-out somewhere in Amsterdam.

20 minutes of a 0.5MB/s download later, I should have realised. I can't just
close my eyes and hope that my dive into Ubuntu would be challengeless.

My task, package 'P' so that end-users don't have to wade through 'developer-
friendly' documentation[1]. In the modern inclination towards Cloud Computing,
Virtualising 'P' and pushing it out onto UCS[2] farms seems like the way
forward.

We're experimenting with a Linux port. Linux has the happy ability to live
happily with copies of itself in a network without calling in the accountants.
It also means that a single use box only needs a single (or dual) core, a bit
of RAM and ~5GB of disk space[3].

When building test tools, one writes code that works to do the job in the very
limited scope of the moment. And so it is with program 'P'. 'P' is a perfectly
pythonic program and, in theory, should run perfectly happily on any modern
OS. It's a long and even more complicated story why, but program 'P' only
works on windows. Stands to reason, windows is the most popular desktop OS.

The hand-wavy excuse for this legacy behaviour is that there's a compiled C
module that has one too many windows dependencies.

Snag. Developers, when forced to not use Visual Studio, think Linux is
synonymous with Ubuntu. They have my pity and sympathy for not spending too
long deciding. It's understandable since they just want to get on with writing
code, if it's written well, then it should work anywhere.

I fire up my Gentoo templates. I have this really cool one that I just clone,
change the hostname/root password and I immediately have a new Linux
server[4].

Gentoo naturally has ... err ... differences and it is going to take too long
to sift through and re-port 'P'. Ubuntu here I come. A true case of
whenyoucantbeatthemjointhem syndrome.

So, actually installing the bug 'U' isn't that painful. There's a curses
wizard that guides you through some nice desirables, LVM partitioning, boot
loaders and the VM friendly checkbox. I'm prepared to sacrifice updatability
and tweaking if the end executable still works. The package manager works well
enough, and google knows which commands I need next. I might even learn
something about how the Ubuntu world works, then <del>come to love it</del>
hate it less. I only need to follow a recipe.

[1] I actually learnt the python language by reading this program.  
[2] http://www.cisco.com/en/US/products/ps10265/index.html  
[3] Compared to quad/octo-core 8GB RAM (max guest support) and ~40GB disk
space, typically.  
[4] It is REALLY cool, menial things like portage trees, local rsync mirrors,
binhosts and icecream clusters are pre-configured. I should write a post about
setting one up. From this template, friends at work have instantiated new
subnets of production worthy servers within hours of summoning it from the
mighty god VLAN.

