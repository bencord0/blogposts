I've had the [Pixel](http://bencord0.wordpress.com/2013/03/01/pixel/) for a
few months now. The most surprising thing that I've realised is how much time
I have been using this without modifications. In the first month, I
immediately dropped into devmode, installed Gentoo, Debian and my own builds
of ChromiumOS.

In the end, I decided to use the Pixel with devmode off, while I sacrifice
shell access to the local filesystem, the extra security of the verified boot
is nice. This isn't that restrictive for me because the crosh shell
(ctrl+alt+t) has a ssh client which is enough for me to do my "real" computing
on a server somewhere else.

When at home, I have a server at home, at work I have a small cloud and
workstation to connect to. But sometimes, I wonder if I really can get away
from these support servers and make the most of the ChromeBook environment.

I don't care about picture or video editing. There are some [HTML5
games](https://www.cubeslam.com/) too. What will matter to me most is an IDE
and collaboration tools (groupware). I'll save groupware for later.

Introducing [Nitrous.IO](https://www.nitrous.io/). This is going to be one of
those multi-page blogs.

Much like HTML5 Photo/Video editors, Web IDEs are still finding their feet. A
quick [Chrome Web Store](https://chrome.google.com/webstore/search/ide?hl=en)
search has previously pointed me in the direction of [Cloud9](http://c9.io)
and [Codeenvy](http://codeenvy.com). They are surprisingly not terrible and
are even packaged nicely for chrome. In the self-hosted world, there is
[Adafruit's webIDE](http://learn.adafruit.com/webide/overview) which works
really well on a raspberry pi.

The latest WebIDE to gain prominence is Nitrous.IO and it has a feature set
that is worth taking some time to explore.  

#### 1/. It's a throwaway environment

The unit of computation is a "Box", an abstraction over an EC2 instance. You
can increase or decrease the resources to a Box by adding or removing N2O
which is earned or purchased. Upon signup (you can use your github account if
you don't care about memorising another password), there's just enough N2O to
create a small Box, but it serves well for a free tier.

If you screw up the environment, just delete it and create a new one. If you
need more resources, or want to isolate development then buy more N2O. It's an
interesting business model and has some implications for a feature further
down.  

#### 2/. It's an IDE

It feels like a real IDE. Perhaps not as full featured as Eclipse (oh the
plugins!), Visual Studio (despite the platform, still a excellent IDE) or
QtCreator (my favourite for mobile app development), but it gives you a text
editor, filesystem hierarchy and a console to do those tasks that haven't yet
made it into menubar form.

Actually, I find the whole experience very similar to using [Kate](http
://kate-editor.org/). On my Pixel, Nitrous is a packaged app and feels like
native IDE; except for the active TLS stream to somewhere in Amazonia.  

#### 3/. Features and Integrations

One of the pieces that differentiates the WebIDEs is how code is
imported/exported, where the files are saved and shell commands run.

CloudEnvy, C9 and Adafruit isolate you to the environment as defined by your
Github or Bitbucket repository. Nitrous goes a step further by dropping you in
as a non-root user on a heavily modified ubuntu machine (in an AWS region of
your choice). From there, you can "git clone", "pip install" or even
"virtualenv" the rest of the development environment. GCC 4.6, a good
selection of pythons (no pypy), rubies, java, erlang, golang compilers and
interpreters along with cmake and qmake round out the most of the needs for
developers. Puppet and chef binaries are available, as well as the heroku
toolbelt!

It is these devops friendly integrations that really make this environment
worth while. With most of the essentials already installed, there is no
pressing need for root access.  

#### 4/. It's cooperative

I think that the killer feature for Nitrous.IO is what presents itself
innocuously to the right of the layout. "Collab Mode" lets you invite other
users to the Box. This makes use of the sidebar chat and notifications feed.
Changes to files by one user update in realtime.

Collaboration is probably where the Nitrous business model will present
itself. Inviting more people to your project means that they will create their
own accounts, their own Boxes and use up more N2O. Since the granularity for
collaboration is per Box, it makes sense to keep separate projects (managed by
separate groups) on separate Boxes.  

#### Full stack for free.

There are some amazing things on the internet for <del>web</del> internet
developers at the moment. [GitHub](http://github.com) to store source code
(free if you keep it public). [Heroku](http://heroku.com) to host it (750
hours/month free per dyno). [Travis-CI](http://travis-ci.org) to test (free on
the public service).

These three alone form the triumvirate of web software. In fact, with [Pull
Request](http://about.travis-ci.org/blog/announcing-pull-request-support/)
support and [Heroku Deployment](http://about.travis-
ci.org/docs/user/deployment/heroku/), the life-cycle of a patch getting to
production is really easy.

Easy, except for composing the patch itself. This is where Nitrous.IO steps
in.  

1. **Fork on github**  
   From the github web ui, find a project and fork it to your own namespace.
2. **Create a nitrous.io Box**  
   This step replaces "open a terminal".
3. **Enable github keys**  
   There's even a [button](http://help.nitrous.io/github-add-key/) for this.
4. **Clone from github**  
   With the handy (literally [touch-friendly](http://help.nitrous.io/ide-fullscreen/)) shell.
5. **Herokai**  
   _[heroku create_](http://help.nitrous.io/heroku/) from inside the git directory
6. **Install travis**__  

    gem install travis; travis init python
    travis login && travis enable_

7. **Link to Heroku**  
   _[travis setup](https://github.com/travis-ci/travis#setup) heroku  
   This step adds an encrypted key to be committed
8. **Push**  
   Since the original clone was against github, and travis is now watching
   pushes and pull requests, this will trigger a CI run.
9. **Admire**  
   If the tests are successful, then travis will also deploy to heroku.

This workflow also works with pull requests. However, there is a difference
between a CI run for every pull request (or every branch) and the merge commit
in the master branch. There are some useful integrations between travis and
github such that [successful pull requests](https://github.com/bencord0
/python-django-sample/pull/2) (notice the green ticks by the commit SHA) can
easily be merged (and branches deleted) and [failed
patches](https://github.com/bencord0/python-django-sample/pull/4) (with evil
red crosses) can be sent for further review.  

#### The Awesomeness Continues

In conclusion, I have managed to create, host and iterate a webapp entirely on
a chromebook, an ephemeral environment. If someone comes along with some
useful changes, they can fork and submit a pull request and most of the hard
work testing is already done for me.

If I like the changeset, then a few clicks of the big green buttons to merge
will trigger a build/test run, deploy to heroku which will then swap out the
slug and continue serving with zero downtime.

The awesome bit is that this is all available for free!  