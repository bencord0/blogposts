This blog post is my reply to a [recent blog post](https://linuxmender.wordpress.com/2015/01/24/sid-arch-or-gentoo-who-would-you-rather-roll-with/) about rolling releases.
I'm firmly in the Gentoo camp. For me, it's about knowledge and control over how my machines are setup and configured, with an emphasis on safety.

Once you get past one or two machines, setting up a central package repository becomes essential. I typically setup a "portage host" (a read/write NFS share of /usr/portage) that is shared between all of my hosts within a network. The goal is to maintain a consistent set of packages throughout the cluster. Typically, I sync the tree (and any overlays) every few days via cronjob.

There's a tool called "eix", which can be used to quickly enumerate the differences between packages installed (aka. world) and the list of upcoming updates. A useful trick is to have cron also email that diff daily.

The reason that I stick with Gentoo is that, when it does become time to update, I don't need to update everything at once. With incremental upgrades, I can save any of the big changes (like a kernel upgrade, or a database slot change) for later, and focus on the smaller updates like perl packages, CLI tools (curl, wget, screen etc) for now.
Nginx and Apache updates can be done on a running system and both support graceful reloads, so those can be updated on sight too.

The compile time wait isn't that much of an issue for me. I recommend that you find the fastest machines you can then create some containers to do the actual compiling inside. This will protect your live filesystems and with FEATURES=buildpkg, will save the binaries to the NFS share ready for when I want to update the rest of the fleet. Again, with more machines in your network, the WAN bandwidth savings become noticeable.

With all rolling distributions, especially since Arch, Gentoo and Sid are community run, there is a risk that a breakage has managed to slip through. Being able to test a package upgrade in isolation has been a huge help in the past, especially if it becomes routine and you have the safety to rollback and try updating again.

Sometimes, machines can go several months (or even years) without updates.

With a Fedora (rawhide), OpenSUSE (tumbleweed/factory) or Ubuntu, my experience is that it is probably better to just reinstall the system instead of trying to catch up. The process will typically involve rewriting the repositories config and downloading every single package again. It is usually down to the individual project's QA process that it doesn't break catastrophically.

However, they might not be testing your particular corner cases.

Rolling distros need to take into account the fact that not everyone is upgrading through the officially sanctioned release versions. There are no release versions.

From what I have seen of the Arch project, they appear to just ignore this problem. They have build machines, a sizeable and knowledgeable community to catch the common problems and a general philosophy of "just update everything". With this laissez faire, always eager attitude, it seems clear why Arch seems to be restricted to mostly desktop systems.

Sid packages, eventually trickle down into the testing archive (typically without a rebuild) within a few days (if no major bugs are found). Security and bug fixes are intermingled with feature releases. Following the changelogs and mailing lists is usually sufficient to determine if updating today's set of packages is safe.

The Gentoo project has spent a lot of time tailoring it's package manager towards update safety. It's rare that you need to recompile everything when upgrading. The portage system also handles transitioning to an updated system gracefully, a feature especially helpful in preventing needless relinking just because glibc has been updated.

It may be tricky, but if there's one lesson from this [search](https://duckduckgo.com/?q=updating+old+gentoo), it is really difficult to truly break a Gentoo system.

