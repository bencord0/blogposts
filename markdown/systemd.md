It's been nagging me for a while. I knew that it would happen at some point. I
read the blogs, the reviews, the flames. The future of PID1 is here.

I've been putting this off for a while, udev-200 was the first visible change.
I practiced the upgrade a few times, so I was ready when it stabilised.
Replace all instances of eth0 with enpXsY. It seemed harmless enough. For my
generic images, adding dhcpcd to the default runlevel, and not creating the
net.* specific scripts tends to do well. Hostnames (dhcp/dns coupling) are a
bit erratic but some tweaks to the runlevel order fixes those.

This is something a bit more invasive. I can't upgrade this easily.  

#### It's all about choice
  
Gentoo is on the verge of quite a few major upgrades. The devs have been
assuring users that there is no need to make the jump, everything still works
and we all have the choice to not migrate over.

SysV+openrc has some really odd corner cases where I find myself spending too
much time googling around and not finding an answer. For instance,
/etc/init.d/* stop scripts not stopping gunicorn workers (even if the master
is killed!). Daemons are forking too many times for PID (and process group id)
tracking to be useful. In gentoo's init scripts you can specify  

    stop() {  
        ...  
        kill -TERM -$(cat /run/${SVCNAME}.pid)  
        ...  
    }

  
to kill the process group, but that isn't 100% reliable.

Systemd places processes into cgroups keeping track of all children, no matter
how naughty they are.

There's also some other cool linux features that systemd exposes, better
support for process isolation, socket activated daemons (a cool feature for
another blog post), faster boot times? It is the future of linux distros
(fedora and arch are fully supported, even
[SailfishOS](http://lwn.net/Articles/561463/)!).

I also find that systemd units are easier to automate than sysv (drop a unit
file, add a symlink and recalculate default.target). This isn't so bad in
gentoo with [declarative](https://blog.flameeyes.eu/2013/01/the-unsolved-
problem-of-the-init-scripts) init scripts.

When writing daemons the [12factors](http://12factor.net) are also well
respected. A statement that I will leave with no extra comment until a future
post.  

#### WTF?!
  
It's not all fun and giggles. There's some funny NIH with system
configuration.  

    root@localhost ~ # qlist systemd|grep -e bin |grep ctl  
    /usr/bin/systemctl  
    /usr/bin/localectl  
    /usr/bin/hostnamectl  
    /usr/bin/timedatectl  
    /usr/bin/bootctl  
    /usr/bin/loginctl  
    /usr/bin/systemd-coredumpctl  
    /usr/bin/journalctl  
    /bin/systemctl

  
You get used to them once you figure out that they can be used to deprecate
files like /etc/hosts and /etc/fstab. Not all of the utilities are fully
working yet, so I can't recommend that everyone switches to systemd right now.  

#### Stage3 Tarballs
  
There are currently no official gentoo systemd stage3 tarballs. I'm working on
creating a stage3 of my own which is probably worth another blog post. You
still need openrc installed as a
[crutch](https://bugs.gentoo.org/show_bug.cgi?id=373219), even if it isn't
running as PID1.

Update: I have a [stage3 tarball](http://dl.condi.me/gentoo-systemd/latest/stage3-systemd.tar.xz).