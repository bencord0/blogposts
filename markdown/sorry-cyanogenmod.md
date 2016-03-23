aka. Lore: The evil brother of the android Data.

In my circles of friends[1], I am probably the most vocal advocate for open
hardware and running alternative operating systems on devices.

The Cyanogenmod post-market firmware for Android devices is probably[2]
something that I will never try, explore and love.
  
It may be one of the greatest (and morally acceptable) approach to software
development on a wide range of consumer level devices that are literally found
everywhere. However, I do have some concerns.  

#### Community: the curse of the forum

Unfortunately, this is probably the greatest barrier to my entry to the world
of alternative handset firmware.

A lot of the [3] work that the community does is obscured by the way that it
is presented. Unfortunately, the medium of choice tends to be public forum. I
don't like fora[4].

An internet forum, especially popular ones are full of hundreds of users,
thousands of threads and millions of posts. With all that traffic, they have
greater information redundancy than a Facebook Datacenter[5].

I can't find information that I need to do a simple task. Say, what files do I
need to put where, how to put them there. What do I need to do to generate the
file or find out the format? or do I just treat them as a magical binary blob
that gets dumped using another binary blob of a loader.

No, I lie. I can find the information. Problem is, it is usually the 16th post
on the 7th page of the 3rd sticky of the forum specific subtopic. Of course,
that's all because I found it after going through the previous 5 threads which
had the "old" method.

The illogical nature of data presentation is resultant of a time-sensitive,
user-contributed[6] information store where content is provided by other
entities who are equals, not superiors in their knowledge of the system. Lies,
or misinformation have the authority as the truth. In the end, this just means
that I can't bring myself to trust it.  

#### The Meego Connection

Contrast with a project that I can deal with. As of writing, there are no
MeeGo devices in the UK. There are announces and software releases, code dumps
and promises. But I can't walk into Tesco[7] and pickup a WeTab or Cordia[8].
Yet.

Let's see how MeeGo addresses some of my concens.

First, meego is an operating system, and meego devices treat it as such. It
uses BIOS, a bootloader that I am used to, and init/rc scripts that I can
read.

For me, this means that I just need to replace a kernel and rootfs. I know how
to do that. Surely, at the most difficult, it can't be much harder than
parsley[9].

A root shell, is a root shell is a root shell. It's bash, and is not a lame
excuse of a honeypot. Example, from my android phone[10].  

    $ pwd  
    /  
    $ awk  
    awk: permission denied  
    $ grep  
    grep: permission denied  
    $ python  
    python: permission denied

  
I won't even show you the ls output, its unnaturally crazy for a rootfs.
Helpful.

In other areas, Meego has a clear method to load programs[11], not a 7 step
process[12], just to get Hello World to work. The inner gubbins are all well
documented (not commented) files and an upstream first philosophy does not tie
me down to a particular toolset either. Of course, there are exceptions to my
hatred. ChromiumOS uses portage, albiet not latest, but normal portage.  

#### Little Extras

"Developer" and "User" roles blurred. The only difference between these two
aspects should be debugging symbols. Upgrades should use the same mechanism
that developers use to get new code uploaded.

Installation is the same as maintainence, is the same as every other day
usage[13]. In short, this is the difference between media-libs/libpng and
{libpng12,libpng-devel}.rpm Pollution.

I like my computers clean, and preferably with a knowledge of how they work.

[1] I've been using the term longer than google, don't sue.  
[2] I'm open to change.  
[3] very good  
[4] forums, for those of other grammatical persuasions.  
[5] <http://www.facebook.com/media/set/?set=a.10150158002922694.290954.193287527693>  
[6] not dev, not expert, but guesswork  
[7] <http://direct.tesco.com/content/specials/kindle.aspx>  
[8] <http://cordiatab.com/>  
[9] <http://forum.qnap.com/viewtopic.php?t=19180#p112708>  
[10] Because Nokia *STILL* haven't released the phone that I was going to get.  
[11] <http://wetab.mobi/en/developers/packaging-widgets-tta-archives/>  
[12] <http://developer.android.com/resources/tutorials/hello-world.html> c.f.
[Hello World](http://bencord0.wordpress.com/2010/12/14/hello-world/)  
[13] <http://www.gentoo.org/doc/en/handbook/handbook-amd64.xml?full=1> Because
no computing system is ever complete.  
