![Not this icecream](http://bencord0.files.wordpress.com/2010/12/bj.jpg?w=179)

Image is not representative of this post.

While I do enjoy Ben<del> & Jerry</del>'s Ice cream, here, I'm referring to
setting up a distributed compilation cluster using simple machines all on the
local subnet.

Introducing [icecream](http://en.opensuse.org/Icecream), based on distcc, a
wrapper to the compiler that allows making the best use of the spare
processing power in your network.

I find myself doing a lot of compiling. I use gentoo so it comes with the
territory. Speeding up the build process as much as possible is refreshing. As
I have a lot of spare computing power at my disposal right now (but that's a
story for another blog post), it makes sense to utilize all of it.

Unfortunately networking processors at the moment is a complicated problem
(although [Tilera](http://www.tilera.com/technology) may have solved it).
There are systems such as MPI, Mosix and [Beowulf
clusters](http://en.wikipedia.org/wiki/Beowulf_%28computing%29), but it
usually takes a lot of dedication and setup to get one working. Even when it
does work, you still need software engineers who know the capabilities of the
system to write software specifically.

My experience of using a [Cluster of
Workstations](http://en.wikipedia.org/wiki/Network_of_Workstations) (CoW) has
been quite disappointing since that usually involves defining some upper limit
of resources that need to be allocated to your program. The programs tend to
be written with these hardcoded values, number of processors, amount of ram,
disk space etc.

What would be nice is for a cluster system that allows multiple heterogeneous
computers (anyone can bring in any spare computer), load it with simple
software/configuration that distributes processes and/or threads to the most
available core. Preferably, with little or no modification to normal programs.

I don't have the illusion that these problems have been satisfactorily
resolved, but I present here an example that presents a solution to one of
tasks that processing in parallel is good for.

#### The single threaded case
[Compiling](http://en.wikipedia.org/wiki/Compiler) a simple program such as
[helloworld](http://bencord0.wordpress.com/2010/12/14/hello-world/) requires a
single call to gcc.

Maybe you have a slightly larger program, say, three or four source files and
a Makefile. When you give the 'make' command, that will invoke 'gcc -c' for
each source file and 'gcc' or 'ld' to link the intermediate object files into
a final executable.

The nice bit here, is that each invocation of 'gcc -c' is only dependent on
the compiler toolchain, not on other source files. We can get a speed-up by
invoking the compiler to do these in parallel.  

#### Single computer, Multiple processors

    make -j
  
If you have a multicore system as found in almost any modern computer, you can
reap the benefits of two or more compilations at the same time.

There is a little bit of an overhead, you can't expect that $latex
\textrm{time} = \frac{\textrm{single threaded time}}{\textrm{number of
cores}}$ but it gets close, and can save a significant amount of time if
compiling tens, hundreds or even thousands of source files. This overhead can
be reduced by specifying how many parallel jobs 'make' is to devise.  

    make -j
  
where $latex \textrm{jobs} = \textrm{number of processors} \cdot \textrm{cores
per processor} + 1$

But we can do better than that.  

#### Multiple computers, Multiple processors. First steps into a clustered
environment

![Bay](http://bencord0.files.wordpress.com/2010/12/bay.jpg?w=179)

What if, when I typed 'make -j', instead of my precious 1.6GHz Core2Duo Tablet
(I call it Bay), takes a performance hit, but my
[AMD](http://www.google.com/finance?q=NYSE:AMD) hex-core (affectionately named
Juniper) did the heavy lifting instead. That way, I can take advantage of a
higher clock speed (a single compiler invocation is faster) but also the
ability to run more compilation jobs in parallel.

Time to get some [Icecream](http://en.wikipedia.org/wiki/Ice_cream).

I can split [openSUSE](http://www.opensuse.org)'s icecream into 3 parts.  

* **wrappers to gcc** \- diverts calls to gcc to icecream's control

* **iceccd** \- the icecream demon, run this on each node in your cluster

* **the scheduler** \- decides where to send a source file to be sent for compilation
  
##### Setup and configuration

![Juniper](http://bencord0.files.wordpress.com/2010/12/juniper.jpg?w=179)

On both computers, run the iceccd demon. It can sit in the background as an
init script. On one computer (arbitrarily selecting the most powerful one),
run the scheduler and configure the iceccd nodes appropriately. See later for
how to actually do this, and especially how to get portage to do this.

Add the icecream wrappers to gcc, g++ and friends to the PATH environment
variable before your real compiler path.

Now, any call to 'gcc' without absolute paths will be sent to the icecream
wrappers and the scheduler may decide to put this compile job anywhere it
wants to. This *could* be the originating computer, it might be on the super
awesome processors.  

##### Caveats
  
My network includes amd64/x86_64 processors so I don't have to fiddle about
with tedious cross compilers. This is also a concern for x86 processors
compiling x86_64 code.

The native compilers on my computers might have different versions. This could
cause incompatibilities between the intermediate object files generated.

Let's ignore that logistical problem for the moment. Now I can invoke 'make
-j9', Juniper's 6 + Bay's 2 + 1. Now I can install gentoo into a complete
system in half a day.

But I have a few more computers nearby.

#### Multiple archs, Multiple computers, Many cores.

One of the major configuration headaches for icecream's predecessor distcc is
that one had to prepare a cross-compiler for every node to compile for every
other node. In a version managed network such as a university or large
company, this problem goes away since there can be design choices made to
limit everyone to the same arch/version of the compiler and other software.

Bad news, I've never seen one. Ever.

So, how does icecream deal with this incompatibility? For my cluster, where
all the processors share a common instruction set, icecream can make a tarball
which contains the compiler environment and distribute that tarball to all
nodes capable of using it.

You can create the tarball yourself with  

    icecc --build-native
  
and then rename it sensibly. Boom! The version mis-match problem has gone
away. iceccd can distribute this tarball to other nodes whenever they start
compiling code for the target computer. In my case, the first time icecream is
used, a build environment tarball is created from my Bay's native toolchain.
iceccd pushes this to Juniper and since they are both amd64, Juniper will use
this toolchain to process any jobs that the scheduler has decided to send from
Bay.

If I have any x86 processors nearby (such as my NAS christened Parsley) that
want to join the cluster, a bit more work is needed to generate the cross-
compiler tarball, but it is possible.  

  1. get the source of binutils and gcc with the same version of the target's binutils and gcc (ie. Bay).
  2. compile the binutils on Parsley, with --prefix=/usr/local/cross --target=x86_64-linux
  3. compile gcc with the same configuration, and 'make all install-driver install-common'
  4. in an empty directory, copy /usr/local/cross/bin/x86_64-linux-{gcc,g++,as} as usr/bin/x86_64-linux{gcc,g++,as}
  5. create an empty source file empty.c in the directory
  6. attempt 'chroot . usr/bin/gcc -c empty.c' and copy over any libraries that the compiler complains about.
  7. tarball the directory, and place it on Bay
  8. Adjust the ICECC_VERSION variable in the iceccd configuration file to use this tarball for any x86 hosts
  
Lather, rinse and repeat for any other cross compilers you need.

Next: Doing it yourself, installing icecream.

#### Installation Notes  

**Gentoo**

    emerge sys-devel/icecream  
    nano /etc/conf.d/icecream  
    /etc/init.d/icecream start  
    rc-update add icecream default

Add PREROOTPATH="/usr/lib/icecc/bin" to make.conf. This lets portage make use
of the cluster.

Prepend "/usr/lib/icecc/bin" to PATH in ~/.bashrc so that this works for
yourself.

**Ubuntu**  

    sudo apt-get install icecc

This automatically starts the iceccd in the background, it will broadcast for
a scheduler by default. Configuration files are under
/etc/{default,icecc}/icecc

But personally, I find this gets a bit temperamental and run iceccd manually.

**openSUSE**  

    yast -i icecream icecream-monitor  
    chkconfig icecream on

It might be a good idea to do the  

    export PATH=/opt/icecream/bin:$PATH

trick in ~/.bashrc to make use of the cluster.

**Other Linux**

This is helpful if you are unfamiliar with the platform you are using and need
a quick ad-hoc cluster node. To participate in a cluster, all you need is to
run the iceccd binary. By default it will broadcast for a scheduler and
compile any jobs sent to it. If it fails to find a scheduler, you can use the
'-s' switch.

The '-m' switch controls the maximum number of jobs running in parallel on the
machine running this instance of iceccd.

I haven't figured out what the '-w' option does.

The source code can be found at  

    svn://anonsvn.kde.org/home/kde/trunk/icecream