tl;dr: How I setup the musl compiler toolchain on a glibc system

```bash
bencord0@localhost ~ $ eselect profile list|grep '*'
  [24]  default/linux/amd64/17.1/desktop/plasma/systemd (stable) *
```

If I compile a program with the system compiler, I get an ELF binary for an amd64 linux system linked against GNU's glibc. I'll refer to these as `x86_64-pc-linux-gnu`.

```bash
$ cat main.c
#include <stdio.h>
int main()
{
    printf("Hello World!\n");
    return 0;
}
$ make CC=cc main
cc     main.c   -o main
$ readelf -h main
ELF Header:
  Magic:   7f 45 4c 46 02 01 01 00 00 00 00 00 00 00 00 00
  Class:                             ELF64
  Data:                              2's complement, little endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI Version:                       0
  Type:                              DYN (Shared object file)
  Machine:                           Advanced Micro Devices X86-64
  Version:                           0x1
  Entry point address:               0x1050
  Start of program headers:          64 (bytes into file)
  Start of section headers:          14272 (bytes into file)
  Flags:                             0x0
  Size of this header:               64 (bytes)
  Size of program headers:           56 (bytes)
  Number of program headers:         11
  Size of section headers:           64 (bytes)
  Number of section headers:         29
  Section header string table index: 28
$ patchelf --print-interpreter main
/lib64/ld-linux-x86-64.so.2
$ ldd main
        linux-vdso.so.1 (0x00007ffcb41ee000)
        libc.so.6 => /lib64/libc.so.6 (0x00007fbc234d2000)
        /lib64/ld-linux-x86-64.so.2 (0x00007fbc236ca000)

```

This coupling, of programs that run using the Linux kernel with help from the GNU userland libraries is commonly known as the [GNU/Linux System](https://www.gnu.org/gnu/linux-and-gnu.en.html). In the Free Software world, this is quite an acheivement that we shouldn't take for granted. Most significantly, is that everyone has access to the source code for this System and we can build self-hosting, self-compiling instances of the System without a reliance on proprietary vendors, NDAs and other secrets.

## Non-GNU/Linux

The term `GNU/Linux` also, of course, bring up the question, "Does an Non-GNU/Linux System also exist?". Are there computers that use the [Linux kernel](https://www.kernel.org/), that don't depend on tools and libraries from the [GNU project](https://www.gnu.org/)?

The short answer is yes. [Android](https://www.android.com/) the mobile phone OS has historically been exclusively based on vendor patched Linux kernels, with an embedded friendly libc derived from BSD's libc, known as [bionic](https://android.googlesource.com/platform/bionic/). Additionally, since the mobile stack evolved completely independently from most Desktop Linux Distros, pretty much every application running on an Android System is JVM based, and optimised for taking user inputs via touchscreens. You're not generally going to be writing CLI tools to be used on Android.

[SailfishOS](https://sailfishos.org/) and [Ubuntu Touch](https://ubuntu-touch.io/) are good examples of smartphones which are GNU/Linux Systems.

## Non-GNU/Linux Desktops

BSD Operating Systems are famous for developing both their kernel (sys) and libc (usr) as a single distribution. This often has benefits, such as the ability to upgrade the System with a "Flag Day", where the userland and kernel need to be upgraded at the same time. The [OpenBSD 5.5 upgrade](https://www.openbsd.org/faq/upgrade55.html#time_t) to a 64-bit `time_t` is a really good example of the benefits of developing both together.

Linux has not historically been distributed as a single unit, and there are a [plethora of Distributions](https://distrowatch.com/) available. Due to the (relatively) [stable kernelspace/userspace ABI](https://lwn.net/Articles/172986/), there's an odd reality that it's even possible for other OSes to implement it too!

- Illumos/SmartOS [LX Branded Zones](https://wiki.smartos.org/lx-branded-zones/)
- FreeBSD's [Linuxulator](https://wiki.freebsd.org/Linuxulator)
- Mac OS can run Linux Docker Containers [using HyperKit](https://www.docker.com/blog/introducing-linuxkit-container-os-toolkit/)
- Windows 10 has the [Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/about)

On Linux, there is even a whole ecosystem of [libc implementations](https://wiki.osdev.org/C_Library). A popular Non-GNU libc for Linux systems is [musl](https://musl.libc.org/).

## `x86_64-pc-linux-musl`

Musl is a reasonalby complete, lightweight libc that has a particular niche in the world for small, portable, statically compiled binaries.

```bash
$ make CC=x86_64-pc-linux-musl-gcc CFLAGS=-static main
x86_64-pc-linux-musl-gcc -static    main.c   -o main
$ readelf -h main
ELF Header:
  Magic:   7f 45 4c 46 02 01 01 00 00 00 00 00 00 00 00 00
  Class:                             ELF64
  Data:                              2's complement, little endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI Version:                       0
  Type:                              EXEC (Executable file)
  Machine:                           Advanced Micro Devices X86-64
  Version:                           0x1
  Entry point address:               0x40102b
  Start of program headers:          64 (bytes into file)
  Start of section headers:          21136 (bytes into file)
  Flags:                             0x0
  Size of this header:               64 (bytes)
  Size of program headers:           56 (bytes)
  Number of program headers:         6
  Size of section headers:           64 (bytes)
  Number of section headers:         15
  Section header string table index: 14
$ patchelf --print-interpreter main
patchelf: cannot find section '.interp'. The input file is most likely statically linked
$ ldd main
        not a dynamic executable
$ ls -lh main
-rwxr-xr-x 1 bencord0 bencord0 22K Aug 23 13:05 main
```

On Gentoo, it's reasonably easy to setup a cross-compiling toolchain.

```bash
# crossdev -t x86_64-pc-linux-musl -S
```

This creates a gcc toolchain, which runs on `x86_64-pc-linux-gnu` to create `x86_64-pc-linux-musl` binaries.

```bash
/usr/x86_64-pc-linux-gnu/x86_64-pc-linux-musl/gcc-bin/9.3.0/x86_64-pc-linux-musl-gcc
```

Additionaly, a prefix is setup under `/usr/x86_64-pc-linux-musl/` where you can find binaries and libraries specifically linked against `musl`. You need to use toolchain specific programs to use and analyze them.

```bash
$ ldd /usr/x86_64-pc-linux-musl/usr/bin/coreutils
/usr/x86_64-pc-linux-musl/usr/bin/coreutils: error while loading shared libraries: /usr/lib64/libc.so: invalid ELF header
$ x86_64-pc-linux-musl-ldd /usr/x86_64-pc-linux-musl/usr/bin/coreutils
        /lib/ld-musl-x86_64.so.1 (0x7fc051bdd000)
        libc.so => /lib/ld-musl-x86_64.so.1 (0x7fc051bdd000)
```

## Sharing the host

Since I'm using `glibc` as my main libc and `musl` is only installed to the prefix, dynamic binaries would not work.

```bash
$ make CC=x86_64-pc-linux-musl-gcc main
x86_64-pc-linux-musl-gcc     main.c   -o main
$ ./main
-bash: ./main: No such file or directory
```

Which is a fun error to get, since `./main` is definitely a file and it does exist there. The quirk to keep in mind is that Linux "interprets" dynamic ELF binaries with _another_ program.

The [crossdev](https://wiki.gentoo.org/wiki/Crossdev) and [eprefix](https://wiki.gentoo.org/wiki/Project:Prefix/Technical_Documentation) mechanism provides me with a lot of these `x86_64-pc-linux-musl-*` wrappers, such as `x86_64-pc-linux-musl-emerge` an interface to portage that can install cross-compiled software to the `/usr/x86_64-pc-linux-musl/` prefix, `x86_64-pc-linux-musl-gcc` the cross-compiler (some software might need you to symlink this to `musl-gcc` in order to be built), `x86_64-pc-linux-musl-ld` the linker from `binutils` etc.

There are two more wrappers, symlinks really, that I use in addition to the toolchain wrappers.

```bash
$ ls -l /usr/bin/x86_64-pc-linux-musl-ldd /lib/ld-musl-x86_64.so.1
    /lib/ld-musl-x86_64.so.1          -> /usr/x86_64-pc-linux-musl/usr/lib/libc.so
    /usr/bin/x86_64-pc-linux-musl-ldd -> /usr/x86_64-pc-linux-musl/usr/bin/ldd
```

On a pure musl system, it would be normal to expect the ELF Interpreter to reside at `/lib/ld-musl-x86_64.so.1`. This is the `musl` analogue to `glibc`'s `/lib/ld-linux.so.2`. This can be resolved with a symlink into the prefix.

When not running the toolchain in `-static` mode, musl still requires a dynamic linker which is the libc itself.
