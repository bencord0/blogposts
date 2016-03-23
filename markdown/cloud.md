Programs crash. It is a fact that all sysadmins have to put up with. In a
production environment, the best we can do is restart them and hope nobody
noticed. Figuring out what went wrong is a task that can usually be differed
until the service is back up to speed again. That's what logs are for after
all.

Applications crash around me more often than you would otherwise notice. I
admit that I do tread the thin line between stability and features.

I run git-master/svn-trunk code on my Home Desktop. When we have just declared
the latest version worthy of a public release, I'm the first to suggest that
we move on to $(latest version +1)-preAlphaX, just to try out this fancy new
routing feature. Just yesterday, I was checking to see if a series of
statistically rare (3 distinct crashes over thousands of calls) crashes still
exist in the current codebase (not even tagged for preAlpha yet).

And that's not even mentioning the cloud-service that is being hacked together
in my extra time. Needless to say, I am literate in many techniques to keep a
service working sufficiently well in the light of the impossibility of
perfection.

So, how do you build a service that appears to keep working, on and on, even
if one cannot guarantee the robustness of many the single-apps running?

Well, lets start with an example of an ideal app. Citadel[1] is a
BBS/Groupware server that originates from the late '80s. It is a single,
monolithic application that has well crafted internal data structures for
storing strings (BBS, email, chat/IM are all represented in the same way).

Citadel has an application layer protocol for data input and retrieval that
makes fools out of any xml-rpc implementation. The Citadel protocol[2] is
simple (reminds me of SMTP a bit), yet diverse enough such that this same API
is used for cluster synchronization (between citservers), client access
(/usr/bin/citadel, the user frontend cli), webapps (webcit), PAM and Apache
modules to hook into the user database and naïve backups to an ASCII stream.
I'm a personal fan of[4].

The rest of citadel's feature set, as far as I can tell is best described as
translators between this protocol and the protocol-du-jour. A fun thing to try
is to access your mail, IMAP/POP what have you. Now do it over NNTP, or the
native client. It's all the same.

Citadel is written in pure and portable C, with very few dependencies and a
tiny core library.  

    # From the ebuild  
    DEPEND="=dev-libs/libcitadel-${PV}  
            >=sys-libs/db-4.1.25_p1 #A well proven, on disk database.  
            virtual/libiconv #for translations  
            ldap? ( >=net-nds/openldap-2.0.27 ) #optional and not needed  
            pam? ( sys-libs/pam ) #optional nice-to-have  
            ssl? ( >=dev-libs/openssl-0.9.6 )" #but not gnutls, I don't think anyone will care  
    RDEPEND="${DEPEND}  
            net-mail/mailbase #just checking if the FHS is sane  
            !net-mail/mailwrapper #no wrappers, citadel does it all internally  
            postfix? ( mail-mta/postfix )" #optional postfix

  
-rwxr-xr-x 1 root root 128K Sep 27 11:13 /usr/lib/libcitadel.so.2.0.0

But what does this mean for stability?

Designing good data structures and a suitable protocol for moving them around
is a luxury that many modern application developers do not have. There's a
simple reason: redesigning the wheel takes time and requires extensive
hindsight knowledge. It will probably be a bit buggy and won't have feature
parity with another easily accessible alternative.

It isn't worth the time and effort, and your project manager/financial analyst
knows this too. So we make do with an off-the-shelf solution, it costs some
money and isn't exactly what we want. We spend more time learning the API and
writing glue-code. All because of one very, *VERY* important feature - it
exists, simples.

It adds bloat, more blackboxes and involves more people when things go wrong.
But it is the easier thing to do. Contrast to Citadel, and one quickly
realises that a small binary means a small codebase. A small, intimate
codebase a code dive, bug fixing or feature adding is easier, albeit
technically intricate.

For my readers who are wondering why we don't just reinvent the wheel in the
face of these challenges, I invite you to write this twitter application that
I have been promising for a few posts now. Go on, I dare you to write an OAuth
implementation. There's plenty of documentation, diagrams and discussions
about the intricacies on the internet[4]. Conceptually, it's just 3 HTTP
requests, a callback (or out-of-band message) and the love child of HTTP-
Digest and the Needham-Schroeder cryptographically secure delegated
authentication (think Kerberos).

How many people can say they'll be comfortable reimplementing SHA-1?[5][6]

... Where were we..? Oh yes, service uptimes.*

Things crash, accept it. It probably crashed in a section that you have no
idea how to fix. What's the work around?  
If you have near a lot of resources, then it's easy to apply some cloud-
computing tricks.

1/. Spawn many instances of the application. If it crashes less than 50% of
the time, then by-averages, you're improving stability. If it's more than 50%,
then call it a failed test and send it back to the devs. Implementation
Difficulty: Easy. Virtualization is cheap(logistically) and financially if you
select the correct platform.  
2/. Use a watchdog[7] or shell loop. So that when the app crashes out, no one
notices the flames. The occasional reboot also helps to stave off the effects
of memory leaks. Implementation Difficulty: Easy. You can get your init
system, or cron to do this. Upstart has a nice 'respawn' keyword.  
3/. Modularize. A common method to scale an application is to separate its key
features. Put the database, frontend processor, backend worker, web-interface
and API servers on different physical machines. Better yet, sell them as
separate products. Bonus points if they scale with load heterogeneously.
Implementation Difficulty: Intermediate. You now have to start defining a real
API and start worrying about communication lines. Welcome to the internet.  
4/. Load balance. If you have 6 application servers, 3 backend workers, and a
database cluster, then think about Hardware[8][9], Software[10] or DNS load
balancing. The idea is mask the fact that a machine or two have gone down. If
communication can go on an either-or path, load balancing magic can keep
service consumers unaware that anything goes wrong while 1/. and 2/. come into
effect. Implementation Difficulty: Easy-Hard. Adding in physical load
balancers can even trick cluster-unaware applications into doing the right
thing. It gets harder if you want to exploit extra communication and heartbeat
protocols for state synchronization. It can be really fun to try cluster
management at the application layer.

The last bit about writing cluster applications is probably the one thing that
I will try to avoid due to the implications if you get it wrong. Reliability,
consistency, performance. In the world of clusters, pick two. However, I have
seen instances that optimise reliability and performance until something
breaks. Then the same cluster will go into self-preservation mode and optimise
for reliability and consistency until it recovers.

Finally, A well written application can scale to tens, if not hundreds of
thousands of users without resorting to these techniques. With a non-trivial
amount of extra time to reinvent wheels, network services would be looking
much less cloudy.

[1] <http://citadel.org>  
[2] <http://citadel.org/doku.php?id=documentation:applicationprotocol#application.layer.protocol.for.the.citadel.system.introducion>  
[3] <http://citadel.org/doku.php?id=faq:systemadmin:how_can_i_batch_create_a_list_of_users_on_a_new_system>  
[4] <https://dev.twitter.com/docs/auth/authorizing-request> The biggest user of OAuth is probably the most authoritative.  
[5] <http://torvalds-family.blogspot.com/2009/08/programming.html>  
[6] <http://git.kernel.org/?p=git/git.git;a=blob;f=block-sha1/sha1.c;h=886bcf25e2f52dff239f1c744c11774af12da48a;hb=66c9c6c0fbba0894ebce3da572f62eb05162e547>  
[7] <http://www.openbsd.org/cgi-bin/man.cgi?query=watchdogd>  
[8] <http://www.cisco.com/en/US/products/ps6906/index.html>  
[9] <http://www.f5.com/products/big-ip/>  
[10] <http://blog.last.fm/2012/03/02/balancefm>

*Intentionally vague about what service I'm talking about.  