In my quick [review](http://bencord0.wordpress.com/2013/09/01/systemd/) of
systemd, I left a few points hanging for further elaboration.

I mentioned that there are no official stage3 tarballs with systemd. Without
them, the only way to get a systemd system is to upgrade via the
[guide](http://wiki.gentoo.org/wiki/Systemd).

As I get used to it, I'm going to need a way to install systemd repeatedly and
consistently. I have therefore created my own stage3 tarball.  

    amd64: <https://dl.condi.me/gentoo-systemd/latest/stage3-systemd.tar.xz>

#### Overview
  
I have a [gist ](https://gist.github.com/bencord0/6407310)with the various
scripts that I wrote. Consider this blog post the README.

In essence, a stage3 tarball is a basic rootfs directory structure with just
enough binaries and libraries to install more stuff. Add a kernel, bootloader,
some must-have packages and configuration files and you have a bootable
[snowflake](https://blog.flameeyes.eu/2013/03/managing-configuration).

They're easy to make, but care needs to be taken to make them sufficiently
generic and small enough for distribution. Mine comes in a just over 98MB.

Some things to consider:  

* You don't have to mess with your real rootfs. _\--root_ and _\--config-root_
  (control the _$ROOT_ and $_PORTAGE_CONFIGROOT _variables respectively) are
  good ways to create new rootfs directory trees. This behaves much like
  debian's _debootstrap_ or _yum --installroot_.

* Use binpkgs, we don't need full build logs or compilation artifacts. Emerging
  with packages also requires a smaller dependency set (no build dependencies
  on the target), so less packages need to be installed.

* This means that creating the final target system occurs in two steps, one_
  \--buildpkg_ but not _\--usepkg_, then again with _\--usepkg_. These are the
  _chroot-prepare_ and _chroot_ directories.

#### Pre-emerge tricks

The very minimum that emerge needs to know about the target, is the
make.profile symlink. This is at _./etc/make.profile_ relative to
_$PORTAGE_CONFIGROOT_ and points to a profile in _$PORTDIR/profiles_.  

    root@localhost ~ # ls -l chroot/etc/make.profile  
    lrwxrwxrwx 1 root root 46 Aug 31 22:10 chroot/etc/make.profile -> /usr/portage/profiles/default/linux/amd64/13.0

Here, emerge (the program itself) and the portage tree (_/usr/portage_) are
located on my real filesystem. I'm actually doing this all in a virtual
machine dedicated to building gentoo root filesystems, so "real" is a
subjective term.

If I wanted to use the defaults, I could create a naive stage3 tarball in two
commands.  

    # emerge --{config-,}root=chroot world  
    # tar xzf stage3-naive.tar.gz -C chroot .

#### Add systemd

To force systemd, I have changed the global USE flags to "-consolekit
systemd", so that packages will be compiled with systemd awareness, and added
sys-apps/systemd to the world set.

I also added _net-misc/dhcpcd,_ _sys-apps/dbus_ and_ sys-apps/iproute2_ to the
world file because they are useful to have and not part of the system set. I
have a larger list of world dependencies that include _app-editors/vim_, _app-
portage/eix_, _sys-kernel/dracut_ (and keywords to unmask it), _sys-boot/grub_
plus some portage, filesystem and networking tools.  

#### Compiling packages

Create the binpkgs, saving them to a _PKGDIR_ somewhere. Defaults to
_/usr/portage/packages_.  

    # EMERGE_FLAGS="--buildpkg --update --jobs"  
    # mkdir "chroot-prepare" "chroot"  
    # tar xavpf stage-template.tar.gz -C chroot  
    # emerge $EMERGE_FLAGS --config-root=chroot --root=chroot-prepare world

This is where most of the time will be spent. It is good to have a strong
multicore machine with enough RAM for this stage. Add _\--jobs_ (unbounded)
and set _MAKEOPTS_ (in_ make.conf_) if you can without crashing the build
host. VMs are really useful for this eventuality.

We could tarball up _chroot-prepare_, but it includes a few extras that we
won't necessarily need to get a working stage3. It also misses out something
critical that exposes a bug in the portage tree.  

#### Emerge proper

    # emerge $EMERGE_FLAGS --usepkgonly --config-root=chroot --root=chroot world

Ideally, this command would work. However there are a few [bugs](https://bugs.
gentoo.org/buglist.cgi?query_format=specific&order=relevance%20desc&no_redirec
t=1&bug_status=__all__&product=&content=enewuser%20ROOT) in the area where
_sys-apps/dbus_ (a dependency of systemd) will not be installed correctly. It
has a _pkg_setup_ phase that calls _enewgroup_ and _enewuser_ from the
_user.eclass_ eclass. Which, in their current incarnations are not ROOT aware,
preventing dbus from starting at boot.

The gist includes a [patch](https://gist.github.com/bencord0/6407310#file-
user-eclass-patch) to the eclass that I should attempt to get merged. Given
the previous attempts by others, and that this only works for recent linux
distros I won't hold my breath.

The other half of fixing dbus is that the required programs to call
_enew{user,group}_ also require files provided by _sys-libs/glibc_ (for
_/usr/bin/getent_), _sys-libs/pam_, _sys-auth/pambase_, _sys-apps/shadow_ and
_sys-apps/baselayout_.

Thanks go to _dev-util/strace_ (and following which _open()_ calls failed
because pam was not yet installed) and _qfile_ (of _app-portage/portage-
utils___) for hunting down the needed packages. I'm not sure what the proper
way to fix this is since my patched eclass requires permission checking in the
chroot, not the dbus ebuild itself.

This knowledge lets us create a working stage3.  

    # DBUS_DEPS="sys-libs/glibc \  
        sys-libs/pam \  
        sys-auth/pambase \  
        sys-apps/shadow \  
        sys-apps/baselayout"  
    # emerge $EMERGE_FLAGS --usepkgonly --config-root=chroot --root=chroot \  
          --oneshot --nodeps $DBUS_DEPS  
    # emerge $EMERGE_FLAGS --usepkgonly --config-root=chroot --root=chroot \  
          world

And finally,  

    # tar cJf stage3-systemd.tar.xz -C chroot .

  
Phew.