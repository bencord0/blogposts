Setting up Gentoo containers on systemd-nspawn is nearing the point where it's
almost as easy as other distro methods, such as `debootstrap` and `yum --installroot`.

There have been a few innovations to my setup since I last blogged about this,
so consider this post a "how I create containers in 2021", and expect it to
update again in a few more years.

In the current state of the world, systemd is pervasive and you can pretty much
rely on it to exist everywhere where you find linux. It comes with it's own
container engine, nspawn. On my systems, ZFS has become my standard. I'm
comfortable using it's built-in encryption and have migrated completely away
from dm-crypt/LUKS. ZFS snapshots have become a core part of my workflow.

Booting nspawn containers from zfs snapshots is a dream.

Creating a gentoo rootfs for those snapshots is now where the hard part lies.

## How other distributions do it

The [systemd-nspawn(1)](https://www.man7.org/linux/man-pages/man1/systemd-nspawn.1.html#EXAMPLES)
man page has a lot of really good examples for creating a suitable, minimal,
rootfs for Fedora (or any RH-like distro), Debian (and by extention ubuntu),
Arch (via pacstrap) and OpenSUSE.

These are all binary based distributions, and usually have a dedicated
"shortcut tool" that can bootstrap a rootfs from hosted binary packages.
Gentoo doesn't have that.

For example, to create a debian system.

    zfs create -o mountpoint=/var/lib/machines/debian zpool/machines/debian
    debootstrap unstable /var/lib/machines/debian
    systemctl enable --now systemd-nspawn@debian
    machinectl shell debian

It used to be possible to do a similar thing with fedora, but [sys-apps/yum](https://bugs.gentoo.org/643312)
has since been removed from the portage tree. Instead, we have to use the release media.

    # The image URL contains version numbers
    BASEURL="https://dl.fedoraproject.org/pub/fedora/linux/development/rawhide/Container/x86_64/images/"
    TARURL="$(curl "${BASEURL}" \
      awk 'match($0, /href="(Fedora-Container-Base-Rawhide-.*.tar.xz)"/, C) {print C[1]}')"

    # Download the specific image, and extract the rootfs tarball
    curl -O "${TARURL}"
    tar xvf Fedora-Container-Base-Rawhide-*.tar.xz \
      --strip-components --wildcards '*/layer.tar'

    # Create a new zfs dataset
    zfs create -o mountpoint=/var/lib/machines/fedora zpool/machines/fedora
    tar xvpf layer.tar -C /var/lib/machines/fedora

    # Install systemd and boot the image
    systemd-nspawn -M fedora dnf install -y systemd
    systemctl enable --now systemd-nspawn@fedora
    machinectl shell fedora

## Bootstrapping Gentoo

Happily, over the past few years portage has gained the ability to install
packages into alternative root directories. Support came initially with the
`--root` flag (where to install the packages if not in `/`) and is now
complemented with the `--sysroot` flag (where to install build dependencies).
`--config-root` also exists (where to read portage's configuration files),
but this has to match `--sysroot`.

    zfs create -o mountpoint=/var/lib/machines/gentoo zpool/machines/gentoo
    emerge \
      --root=/var/lib/machines/gentoo \
      --sysroot=/var/lib/machines/gentoo \
      --nodeps @system
    emerge \
      --root=/var/lib/machines/gentoo \
      --sysroot=/var/lib/machines/gentoo \
      @system

    systemctl enable --now systemd-nspawn@gentoo
    machinectl shell gentoo

There are probably some niceties that you should add too. For example,
sharing the host's portage tree, distfiles and prebuilt packages.

    # /etc/systemd/nspawn/gentoo.nspawn
    [Files]
    BindReadOnly=/var/db/repos
    Bind=/var/cache/distfiles
    Bind=/var/cache/binpkgs

## Binary only

One of the major limits today is that it's not possible to do this cleanly
with a source-only install as the build graph creates some unfortunate build
dependency cycles.

    (media-libs/freetype-2.11.0-r1:2/2::gentoo, ebuild scheduled for merge to '/var/lib/machines/gentoo/') depends on
     (media-libs/harfbuzz-2.9.1:0/0.9.18::gentoo, ebuild scheduled for merge to '/var/lib/machines/gentoo/') (buildtime)
      (media-libs/freetype-2.11.0-r1:2/2::gentoo, ebuild scheduled for merge to '/var/lib/machines/gentoo/') (buildtime_slot_op)

It's usually possible to work around this with `--nodeps` since you already
have the BDEPENDs installed on the host.

    emerge \
      --root=/var/lib/machines/gentoo \
      --sysroot=/var/lib/machines/gentoo \
      --nodeps -1 media-libs/harfbuzz

And then continue emerging `@system`.

Happily, this pain only needs to happen the first time after an `emerge --sync`,
and can be avoided if you have access to precompiled versions locally or from a binhost.

    # /etc/portage/make.conf
    FEATURES="buildpkg binpkg-multi-instance getbinpkg"
    PORTAGE_BINHOST="https://portage.condi.me/${CHOST}/packages/"

This way, if my personal binhost has recent builds in it, you can avoid the
circular build-time dependencies. As a note, gentoo's release media tool (catalyst)
avoids this problem by specifying a [packages.build](https://projects.gentoo.org/pms/8/pms.html#x1-500005.2.7)
file, instead of relying on the `@system` set.

    emerge --root=$root --sysroot=$root -av @system
    These are the packages that would be merged, in order:
       ...

    Calculating dependencies... done!
    Total: 247 packages (247 installs, 247 binaries), Size of downloads: 0 KiB

------

## Custom Profiles

There is no point is using `emerge --root= @system` if we stop there.
At the basic level, we might as well use a stage3 tarball to get the same effect.

What becomes more interesting, is when you combine it with a custom overlay
managed by [`repos.conf`](https://wiki.gentoo.org/wiki//etc/portage/repos.conf).

You can create a new local overlay from nothing.

    # /etc/portage/repos.conf/local.conf
    [local]
    location = /var/db/repos/local
    auto-sync = no

Or use a git managed overlay.

    # /etc/portage/repos.conf/bencord0.conf
    [bencord0]
    location = /var/db/repos/bencord0
    sync-type = git
    sync-uri = https://github.com/bencord0/portage-overlay

A quick `emaint sync -r bencord0` will then fetch the tree (and on my systems,
update the eix cache).

You can create your own profiles by [following the wiki on custom profiles](https://wiki.gentoo.org/wiki/Profile_(Portage)#custom).
For my own hosts, VMs and containers, I now point them at my own host specific profiles.

    $ tree /var/db/repos/bencord0/profiles/ -d 2
    /var/db/repos/bencord0/profiles/
    ├── base
    │   ├── python
    │   └── zfs
    ├── default
    │   └── linux
    │       ├── amd64
    │       └── arm
    └── host
        ├── aniseed
        ├── juniper
        ├── parsley
        └── x395

And switch to the profile, "eselect profile" is not ROOT aware.

    ln -s \
      /var/db/repos/bencord0/profiles/default/linux/amd64/nspawn \
      /var/lib/machines/gentoo/etc/portage/make.profile

    root=/var/lib/machines/gentoo
    emerge --root=$root --sysroot=$root @system @world @profile

By using per-host custom profiles, I can also pre-install specific packages,
set USE flags and accept keywords. This makes system updates much easier, as I
can now loop through the updates for all container hosts on a system.

    cd /var/lib/machines
    for machine in *; do
      # filter out non-gentoo systems
      if [[ ! -e "${machine}/etc/gentoo-release" ]]; then
        continue
      fi

      root="${PWD}/${machine}"
      emerge --root="${root}" --sysroot="${root}" -1uv \
        @system @world @profile
    done

## Networking

Another useful benefit of systemd containers is a closer integration with the host networking. It's possible to keep the container in it's own independent network stack, while still keeping it on the same L2 segment as the rest of your network.

    # /etc/systemd/network/br0.netdev
    # Create a bridge device to attach containers to
    [NetDev]
    Name=br0
    Kind=bridge

    # /etc/systemd/network/br0.network
    [Match]
    Name=br0

    [Network]
    # This is a reference to host's network interface
    # I set a static IP address on this, and disable addressing for the bridge
    MACVLAN=main
    IPv6AcceptRA=no

    [IPv6AcceptRA]
    DHCPv6Client=no

Then each container can be configured to attach to the bridge.

    # /etc/systemd/nspawn/gentoo.nspawn
    [Files]
      ... as above

    [Network]
    Private=yes
    VirtualEthernet=yes
    Bridge=br0

This now lets me create webservers in the containers, and have them fully routable within my LAN. Unlike with Docker or other CNI plugins, I don't need a NAT, overlay or custom routing and discovery protocol. `iptables` inside the containers can also be configured, and the rules are saved independently of the host's firewall rules.
