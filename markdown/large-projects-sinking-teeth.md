I've needed something to restore my faith in good code. I think I've found it.
Let me explain why.

I'm looking for a big project that I can sink myself into. I know a few
programming languages and am slowly coming round to see the point of
python[1]; I'm confident with my ability to use git without loosing data and
SVN is just insane[2].

Since I use Linux where there's source code for everything, I decided to dig
into one of the projects that I use on an everyday basis.

Disclaimer: I am not a developer in any of the projects listed in here. I may
have filed one or two bugs, but nothing serious. I do not have write access to
any of the upstream projects. I am however a user, and I like to know where
stuff came from. Maybe one day I will be a dev, until then all opinions
expressed here are my own and are susceptible to being wrong and/or updated
into obsolescence. I also have no real idea about what's going on or how
things really work.

Warning: This is a kinda long post for me, you have been warned. Enjoy!

#### [Qt](http://qt.nokia.com)

I first looked at Qt a few months before the acquisition. The capabilities of
the framework amazed me, GUI programs can be build quickly without the
developer[3] going insane trying to figure out what goes where [4]. Qt was
nice because it can deploy applications on almost any platform[5].
Theoretically, Qt should work on any platform that has a standards compliant
C++ compiler (with no guarantees on speed and complete capabilities).  
The philosophy behind the code is also attractive. Those trolls really know
what they are doing.

Qt now comes as a single [git repository](http://qt.gitorious.org/). It's
straight forward to hack and if you have something good enough to share with
the rest of the world, then [send it
in](http://qt.gitorious.org/qt/qt/merge_requests).

Qt is easy to have multiple versions on the same system; Just point towards
the qmake in the source or install tree of choice and the rest is taken care
of. I usually have unstable from portage in /usr and messy ones from less
reputable sources in $HOME[6].  

#### [Linux](http://kernel.org)

The kernel itself comes from the blessed source tree from [Linus](http://git.k
ernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=summary) himself. I use
Gentoo, so sys-kernel/gentoo-sources from the portage tree is usually good for
me.

I don't know nearly enough about kernels and very low level programming. I
never really got round to teaching myself assembly. Thus, I just stick to
released kernels or kernels that have at least some level of QA on them. I
mess with menuconfigs and grub configs, but that's as far as I'm brave enough
to go. I would be hopeless if I had to fix a compile-time issue.  

#### [Gentoo/Portage](http://gentoo.org)

My opinion of hacking gentoo doesn't really count as a typical OS hacking
session. Besides the base layout and what gets put into a stage3, there isn't
much to hack. The interesting stuff for this meta-distro lies within Portage:
emerge, ebuilds, 'the tree' etc.

It's easy enough to start hacking, being written in python(logic and core) and
bash(configuration and high level commands). Downside is that it's written in
python and bash which I find are languages difficult to keep track of within
the mind of a simple dev[3].

If I could hack something, then I can think about some cool things that can be
done with the $ROOT variable and cross-platform development/deployment.  

#### [Android](http://www.android.com/)/[ChromeOS](http://www.chromium.org/chromium-os)

Now I can get into the larger projects. So large that it would not be sensible
to store the entire thing in a single git repo. SVN's architecture could
handle this, but that would introduce a whole new world of pain.

In my eyes, Android is a closed platform. I have no idea how to download
enough source to build and package into something that I can deploy on my
phone without external interference.

ChromeOS is nicer. Google have had the good sense to use a Gentoo chroot as
their build environment. Full instructions about getting the source, compiling
and deployment can be found on [chromium.org](http://www.chromium.org
/chromium-os/developer-guide).

I like the [deploy](http://www.chromium.org/chromium-os/developer-guide#TOC-
Running-your-image) instructions. If you ever need to brick/unbrick the image,
it is good to know that it is possible.

ChromeOS uses git stores for the source, and google's own "repo" tool to
manage the local checkouts from a high level. It's nice to know that
everything is available for this little distro, unfortunately it is way too
big and inconsistent to get my head around.

Google provides scripts to do everything. This removes the complexity, but
this is just too untidy for my liking. Umbilical cords of development managing
a host system (the build environment) that takes charge over the guest image
all within my dev system seems a bit overkill for a development cycle.
ChromeOS within Gentoo within Gentoo seems a bit overkill for me.  

#### [MeeGo](http://meego.com)

Unfortunately, meego is unfinished and I can't get my hands on a fully working
device. The source code is available, but not really in a usable state as far
as I'm concerned.  

#### [KDE](http://kde.org)

Finally we come to the KDE project. I've used KDE for a long time. It attracts
me because it promises to provide the desktop experience, batteries included,
on top of Qt. This means that it inherits things such as a philosophy that I
can subscribe to, cross-platform capability and peace of mind that I can (with
some reading) understand how it works at all levels (if I really need to).

KDE is now in a state of migration away from SVN towards Git. Knowledge of
both is required, and an eye on mailing lists and blogs is useful to keep
track of which bits have been ported over. Here I can point out something that
I like with the KDE ecosystem over google-like approaches. To build KDE, there
is no abstraction to do the job of repo[7] that serves as a higher level
wrapper for source control. There isn't anything special about SVN or Git,
they are both treated (imo) as ftp on steroids.

The build system is CMake. It is not "based on CMake", nor is it "CMake-like",
KDE worked with [Kitware](http://www.cmake.org/) until they had a build system
that was sane, simple enough and could do everything it needed to. Where CMake
couldn't live up to expectations, it was developed until it could perform the
duties asked upon it[8]. With some handy [bashrc shortcuts](http://techbase.kd
e.org/Getting_Started/Increased_Productivity_in_KDE4_with_Scripts/.bashrc)
taking control of the build is almost relaxing. There's a nice bash function
'cmakekde' that will configure, build and (prefix-)install any kde module
without doing anything unexpected or suffering from black box syndrome.

The design of the KDE repository layout clearly comes from the use of SVN.
There is a tree of source code, programs are logically grouped by modules
which are just directory folders at the end of the day. Browsing the code
locally doesn't need an entire checkout of KDE, 'svn up --depth empty', 'svn
ls' are good tools for browsing without overloading the upstream server[9].

Migrating to git looses this structure. Git repositories aren't generally kept
in a tree of cascading git repositories, git submodules aren't that great
either. Step in projects.kde.org, a searchable interface to KDE projects that
keeps track of project status, activity and repository information. It also
preserves the SVN tree structure (see the address bar) when locating specific
projects.

This style of development is open, transparent and sane[10]. The transition to
Git gives the flexibility for a project which is logically isolated to its
corner of the KDE tree to be in its own repo, independent of the rest of KDE.
This is useful for a few reasons.  

A KDE developer working on a single program can get just the repo required,
not the entire tree. This has good consequences, such as ebuild/rpm/deb
boundaries.  
A KDE packager or distro maintainer[3] can get hold of the tree and cmakekde
the lot and end up with a pristine KDE.  
A project originally developed outside of KDE can join in, just find a home
for it in the tree. The infrastructure hosting the code doesn't even need to
change, a link to the repo is all that is necessary[11].

The [How-To](http://techbase.kde.org/Getting_Started/Build/KDE4) document
about KDE development walks through setting up the dev environment. In
contrast to ChromeOS, the developer environment is just another local user
account, not an entire chroot. Target builds are done via prefix installs, not
bind mounts. You don't need to know about tesseracts just to understand where
the code is.

Thinking about all the many kinds of files used during software
development[2a], the KDE project has one of the most elegant shadow builds I
have ever seen. Let me describe how it works on my local system.

~/kde/src/ contains what is in essence a svn checkout of trunk, with git
clones of the bits that have already been migrated. ~/kde/build/ contains the
build, generated CMake files, object files and so on. ~/kde/ is my install
prefix, so ~/kde/{bin,lib,etc,share} and friends get populated on 'make
install'.

Bashrc hacks allow for some really useful shortcuts. Say, I'm in
~/kde/src/kdelibs and I call 'cmakekde'. This will 'cb' (change to build
directory shortcut), call 'cmake' (with preconfigured options) then call 'make
&& make install'. This should work and it doesn't matter if the 'kdelibs'
directory came from SVN, Git (it has been migrated) or even from a released
tarball. Since I'm sitting in the source directory, I can hack around, fix a
compile issue or just look around. At any time I can call 'make' by hand (and
through some 'cb' trickery) update the build AND leave the source clean for
patches and diffs to work without object files getting in the way. This also
has the benefit of not being Autotools based with a need to diff/patch
configure scripts because something [12] is out of date.

Finally, to build all of KDE from a single command (or from cron) there is the
kdesrc-build utility in the extragear repository. This single tool automates
the build process from a high level without replicating the build environment
all over again. Kudos to KDE for Konsistency.

[1] Still have no idea wtf is up with (*args, **kwargs) yet.  
[2] Simple linear history is nice, but bandwidth and disk space usage is
crazy. Implementations are slow and it gets in the way. [2a]File listings show
4 or 5 different kinds of files that I have to twist my head around; Actual
code files, generated code files (objects, libraries and executables), build
files (easy hand written stuff and complicated generated stuff[8]) and now
.svn directories EVERYWHERE.  
[3] i.e. me  
[4] Have you seen Win32 C/C++ HelloWorld? It's 200-300 lines long for a
program that is 10 lines of Qt including build scripts.  
[5] And now on [android](http://necessitas.sourceforge.net/) too  
[6] Usually this is Qt/master, but I have fun with other repositories.
prefix'd installs are useful when one doesn't want to bring the entire system
down.  
[7] I'll talk about kdesrc-build further down  
[8] c.f. GNU Autotools.  
[9] a limitation of SVN. This design was always going to lead to pain.  
[10] as in, it is the least insane of almost any other approach to developing
large projects.  
[11] maybe something nice on the blogs and a home on projects.kde.org would be
nice too.  
[12] who really knows what it could be.  