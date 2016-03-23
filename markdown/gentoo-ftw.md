These past few weeks, there have been some pretty disturbing disruptions for
Linux users on rolling release distros.The biggest upset in recent times I'll
describe as "The udev-200 issue", where the symptoms of an unsupervised
update/reboot cycle will present you with a) a system that won't boot, b) a
system without network or c) both.

Disruptions of this kind are not pleasant for end users. In the time that I've
been using Linux, I have seen the effect of quite a number of transitions: KDE
3/4, Gnome 2/3, X11 automatic configuration, libpng2, Linux 2.6/3. Thankfully,
future generations need not worry about these things since all distributions
have made these jumps and the remnants are bitrotting in Google's index.

We are still going through some, python2/3 (and packaging in general),
sysvinit/systemd, X11/Wayland, Grub2/UEFI, IPv4/v6. These won't be solved
overnight. The problems should resolve themselves over a time span of years,
but I suspect that they will be solved.

Gentoo has just come through some particularly nasty ones in the past few
months: udev-200 is the most recent, but EAPI=5 with an out-of-date portage
back in February, I now have a habit of trialling upgrades on VMs these days
which are easy to do with the prolific tooling available.

In the more usual distros, time release or feature release based worlds can
not handle the adaptability. I have never had an upgrade of Ubuntu work
flawlessly, something always breaks, I don't even know how to approach the
problem in Fedora/RedHat land. Debian has a whole
[chapter](http://www.debian.org/releases/testing/i386/release-notes/ch-
upgrading.en.html) devoted to this.

Typically, when an upgrade of magnitude is about to occur, it is time for the
annual "dd if=/dev/zero of=/dev/sda" and reinstall. Biannual if you use
Windows.

In Gentoo, this is unacceptable. Changes to a rolling release cycles must be
gradual. A transition plan in place and users notified and prepared beforehand
about what the technical issues are. It is good that in most cases, upstream
developers and distro developers find a way to make the upgrade process
seemless.

(I think it is still good to know what could have broken, and especially how
to fix it if it did. None of this re-install from scratch/golden image+backups
absurdity.)

Gentoo has the tools to handle these advances properly. Often, I am asked why
I still use it when "Arch is obviously better" (configurability with none of
the compiling) or "Just use Ubuntu, everyone else is!". I cry a little inside.
So I've put together a short list of features that need to be available before
I could ever consider distro-hopping again.  

#### Modular Networking using key=value pairs

  
I've tried debian-esque /etc/network/interfaces. It's terribly inconsistent
and requires constant referencing to do anything but basic dhcpv4.

Here's my current conf.d/net.  

    modules="dhclient iproute2"
    bridge_add_eth0="br0"  
    bridge_add_eth1="br0"  
    bridge_add_enp3s0="br0"  
    bridge_add_enp1s6="br0"
    config_eth0="null"  
    config_eth1="null"  
    config_enp3s0="null"  
    config_enp1s6="null"
    config_br0="192.168.1.2/24  
    2001:xxxx:xxxx:xxxx::2/64"  
    routes_br0="default via 192.168.1.1  
    default via 2001:xxxx:xxxx:xxxx::1"  
    dns_domain="my.domain"  
    dns_search="192.168.1.1 2001:xxxx:xxxx:xxxx::1"

  
This is will be my network configuration for a little while until udev-200
issues blow over and I have a bit more confidence. In particular:  

  
  * the bridge is created dynamically as real network interfaces become available,
  * the bridge is udev-200 safe
  * IPv4 and IPv6 are configured harmoniously.
  * switching to dhcp/autoconfiguration can be done by commenting the last block. dhclient is the only linux dhcp client that I have tricked into [doing v6 properly](http://bencord0.wordpress.com/2012/10/10/dhcpv6/).
  
Attaching VMs to the network is easily achieved by adding them to the bridge.
I have personal experience that both Xen4 and LXC handle this nicely. Qemu/KVM
need a separate if-up/down.sh script which can get tricky, but nonetheless
works.

I have more complicated setups too, my gateway/firewall has a few extra
stanzas to handle ppp. At work I have deployed Gentoo on [Cisco
UCS](http://www.cisco.com/en/US/products/ps10265/index.html) which pulls VLANs
out of two Bonded/Etherchannel 10 Gig fiber cards.  

#### revdep-rebuild

DLL-hell was a big problem. Upgrading a library would cause untold havoc on
applications that depended on installed-at-build-time dependencies. In modern
Windows, programs are completely housed under their C:\Program Files\
namespace. OS X Frameworks takes this even further. And Ubuntu still breaks on
dist-upgrade.

The effect isn't as noticeable these days, but the install/uninstall/upgrade
breakages got annoying. Gentoo's solution was to recompile broken packages
against the newly installed libraries. FEATURES=preserved-libs mitigates the
issue in an efficient way. Portage will keep the old library around (without
name clashing) until the reverse dependencies have been upgraded or recompiled
against the newer version of the library. When no more packages depend on the
old files, they are removed.  

#### CONFIG_PROTECT and dispatch-conf

  
Another problem with upgrades is that configuration files and init-scripts
evolve. New options are added, defaults are changed, hacks are removed. The
etc-update mechanism is a neat wrapper to diff and $EDITOR for sysadmn
intervention. [OpenSUSE](http://michal.hrusecky.net/2013/04/fosdem-2013-and-
etc-update/) just gained this ability.  

#### epatch-user, egit-src

  
Compiling from source. More specifically, modifying the source before it is
installed. This could be modifying some source code for a failed build, then
resuming. Adding a custom patch during the build process via epatch-user
hooks, or just living on the edge with code fresh from the repo.

More commonly, I use this feature to repair broken emerge runs, or fixing some
build options before a package is fully merged into the real filesystem.  

    # Example taken from my personal overlay  
    ebuild /usr/local/portage/net-misc/balance-fm/balance-fm-1.0.1-r1.ebuild compile
    # Hack hack hack  
    cd /var/tmp/portage/net-misc/balance-fm-1.0.1-r1/work/balance-fm-1.0.1/  
    $EDITOR Makefile  
    # Don't forget to make patches to record changes, and save them somewhere safe.
    # recompile  
    rm /var/tmp/portage/net-misc/balance-fm-1.0.1-r1/.compiled  
    ebuild /usr/local/portage/net-misc/balance-fm/balance-fm-1.0.1-r1.ebuild compile
    # install the changed package  
    ebuild /usr/local/portage/net-misc/balance-fm/balance-fm-1.0.1-r1.ebuild merge

  
This is a good technique during ebuild development that keeps everything
installed tracked by portage and uninstallable.

Philosophically, I find this morally pleasing because there is a direct
correlation between what is installed on my filesystem and the GNU definition
of [corresponding source](http://gpl-violations.org/faq/sourcecode-faq.html).

I might come back to this topic later because this blog post is getting long
and you have probably _ctrl+w_'ed by now.