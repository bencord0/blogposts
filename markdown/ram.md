Every now and then, I find myself justifying why I go for systems with a lot
of System RAM (contrast Graphics RAM). I think I've finally figured it out.

Thanks to the lightweight awesomeness that is a basic gentoo install (aka. "a
stage3 install"), I can cobble together a system that boots up and gives me a
usable computing environment in less than 200MB in RAM. Typically, these are
clean VM images in .ova format, but it also works as a basic way to get
standalone servers to work. Useful if/when I re-make a box like Parsley again.

For a end-user system in Desktop/Laptop configurations I can set up a KDE
environment that happily runs in 1GB. In the future I'd hope to do the same
with a tablet setup, but that has some extra UI challenges to overcome first.
Htop reports that Juniper is happily idling at 534MB, with no swap usage. For
reference, load averages are 0.01 0.06 0.09 and 4/6 cores are at 0.0%, the
active two are ~10%. This is a full KDE session with a browser and terminal
session open.

So why do I like large RAM systems?

I use amd64 everywhere. I don't have any x86-only devices anymore. Even my
tablet, a trusty WeTab has a 64-bit Intel N450 atom. Primarily, that means
that I can make binpkgs for any one of my systems, and have them work on all
of them without fancy cross-compiling and distributed compiling (i.e.
icecream) works with native compilers.

Secondly, 64-bit architectures have a larger address space and get over that
pesky 2GB RAM limit.

My work laptop, the one I'm typing this on now, is a 4GB system with a capable
Intel i5 processor, a simple onboard graphics card in a comfortably portable
form factor. My desktop, Juniper, is a roaring AMD Phenom II X6 with 8GB of
RAM and a motherboard that knows no limits. At work, I have some systems that
50GB+ of RAM.

So, what is one to do with all that RAM?  
Well, I've figured it out.

When you have a system that fits comfortably in a few hundred MB of RAM,
memory leaks are really easy to spot. Yes, there are the typical layer 8
"leaks" such as opening 300 tabs in opera and *NOT* crashing.

Or the infamous,

/usr/lib64/opera//operapluginwrapper-ia32-linux 58 62 /opt/Adobe/flash-player32/plugin/libflashplayer.so  
VIRT: 392M  
RES: 185M  
SHR: 18648  
CPU%: 21.0  
MEM%: 4.9%

just to run a youtube video? It's worse than Java. Then there are the genuine
memory leaks. Yea, I'm looking at you knotify. But I've also managed to get
'ls' to hit the oom killer once [1].

But a system with lots and lots of RAM has one nice behaviour when such an
event occurs. It doesn't slow down (too much), and it doesn't crash horribly.
I don't mind if an application is sluggish, just as long as it doesn't bring
down the entire UI. If it means that I have to ssh in, poke around 'htop' and
friends 'ps', and 'kill -9' I'm still happy.

Lessons? I'm still going to click (most of the) links that come by my twitter
feed. The internet is using HTML5 a lot, which is good for mem/cpu ops, but
flash is still everywhere. It's still sitting in a single thread that insists
on using its own memory space. And it still will take up twice the entropy
that the OS itself takes up.

\---

[1] deeply recursive searches into temporal backup folders. Don't ask.  