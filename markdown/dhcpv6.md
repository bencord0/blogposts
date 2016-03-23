Hi future me,

IPv6 is probably ubiquitous when you're reading this. But I'm speaking too
soon, then here's some quick tips about setting up your own subnet.

I'll make some assumptions, the network (specifically the router) already has
a /64 subnet and prefix. For the sake of
[example](http://tools.ietf.org/html/rfc3849), lets pretend these are:  

    2001:DB8:1234:5678::/64 - the subnet  
    2001:DB8:1234:5678::1 - the router inside that subnet

[Typically](http://tools.ietf.org/html/rfc3849), your router will advertise
this information in a "Router Advertisement" ICMPv6 message. With a Cisco
router, you don't need to configure net-misc/radvd.

![Router Advertisement](http://bencord0.files.wordpress.com/2012/10/ipv6-ra.png)
The important bits are the "Managed address" and "Other configuration" flags.
Then we can let the DHCPv6 server take over.

There's a good [guide](http://www.mmacleod.ca/blog/2011/08/ipv6-part-8-configuring-dns-and-dhcpv6-on-an-ipv6-network/)
on server configuration. Essentially, use ISC's DHCP server
(>net-misc/dhcp[server ipv6]-4.2) and follow the man pages.

I think DHCPv4 and DHCPv6 can run on the same instance, but I haven't checked
yet. Symlinks from /etc/init.d/dhcpd6 -> /etc/init.d/dhcpd FTW.

Now, the uncertain bit, DHCP clients.

Windows seems to be behaving itself,

![Windows DNS](http://bencord0.files.wordpress.com/2012/10/ipv6-windns.png)
Remember to check these two boxes in the windows ipv6 advanced settings

Linux hosts vary from distro to distro.

I've had success from the ISC dhclient on Debian/Wheezy (isc-dhcp-client
4.2.2) and Gentoo (net-misc/dhcp[client]-4.2.4)  

    # /etc/dhcp/dhclient.conf  
    request subnet-mask, broadcast-address, time-offset, routers,  
        domain-name, domain-name-servers, domain-search, host-name,  
        netbios-name-servers, interface-mtu, interface-mtu,  
        rfc3442-classless-static-routes, ntp-servers,  
        dhcp6.name-servers, dhcp6.domain-search;
    send fqdn.fqdn = gethostname();  
    send fqdn.encoded on;  
    send fqdn.server-update on;  
    # Gentoo only /etc/conf.d/net  
    modules_eth0="dhclient"  
    config_eth0="dhcp"

  
Why dhcp client's don't send their hostnames is a mystery to me, it seems like
the default thing to do in v4 land, but is missed in v6 world.
