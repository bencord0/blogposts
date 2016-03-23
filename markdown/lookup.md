Its all about choice. [1]

## or Why I love Gentoo

In further attempts to circumvent this lousy Sky branded home router (from
Netgear), I've now setup a DNS caching server on juniper. It also serves as an
authoritative server for the local network.

Installation was fairly painless, and gentoo helped find the bits of config
that I didn't know how to fiddle with. Gentoo provides the tools, and
literally shows you how to install new software from scratch. Furthermore,
once you have compiled and installed code, it can give you a leg up to
configure, run and use the shiny new software.

#### Installation
  
**Step 1/.** Get tired of typing ip addresses for common things.

**Step 2/.** Edit /etc/hosts and C:\Windows\System32\drivers\etc\hosts files to map names to ip addresses.

**Step 3/.** Get tired of maintaining/synchronizing multiple hosts files all over your network and decide that you really need a DNS server.

**Step 4/.**  

    eix -c net-dns/*
  
to find a list of available DNS servers. Settle for BIND.

**Step 5/.**  

    emerge -av bind

and adjust USE flags as desired.  

    euse -i [flag] [...]

is your friend.

**Step 6/.** Sit back and watch 6-cores of multi-threaded awesomeness happen. Unfortunately, this step won't take too long.

**Step 7/.**  

    qlist net-dns/bind | grep etc

brings up a list of configuration files. Edit them accordingly.

#### Configuration

**Step 8/.** Realise you don't know wtf you're doing to the configuration files.  

    qlist net-dns/bind | grep man

  
brings up a list of man pages.

**Step 8a/.** Read the man pages.

**Step 8b/.** Give up on man pages.

**Step 9/.** Look for more documentation.  

    eix net-dns/bind

tell you where to find the website.

**Step 9a/.** Read the Bind9 Administrator's Reference Manual (ARM) paying particular attention to the contents page, and in particular chapter 6 which points you towards RFC 1035. Read the examples.

**Step 9b/.** Understand the examples, verify your knowledge google('bind zone file')[1]. {2}{3}

**Step 10/.**  

    qlist net-dns/bind | grep sbin

showed you something called  

    named-checkconf

and  

    named-checkzone

Use them wisely.

#### Run and Test

**Step 11/.**  

    /etc/init.d/bi<tab><tab>

gives you grief.  

    /etc/init.d/named start

gives you favourable results. It also runs named-checkconf :D.

**Step 12/.** Test the server.

**Step 12a/.** Remember to reset/comment out the previous hosts files. edit/cleanout /etc/resolve.conf.  

    #/etc/resolve.conf  
    nameserver localhost  
    domain localdomain
  
**Step 12b/.**

![nslookup](http://bencord0.files.wordpress.com/2011/03/nslookup.png)

This is why you followed the past 11 steps

**Step 13/.**  

    rc-update add named default

Makes things persistent over reboots.

**Extra Credit:** Enable automatic hostname registration for Windows.

![The magic tick
box](http://bencord0.files.wordpress.com/2011/03/windowsdns.png?w=251)

The magic tick box

In linux, DHCPCD does this by default. No extra points.  
  
[1] http://rrr.thetruth.de/2010/06/would-mark-shuttleworth-use-gentoo-had-he-
not-founded-ubuntu/ but I picked a better picture.  
[2] Yes, meta-code starts at index zero. It leads you [a cleaver zone file
generator](http://pgl.yoyo.org/as/bind-zone-file-creator.php).  
[3] I also need to find a better footnote system.  

