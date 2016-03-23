I've been using python a lot recently. A LOT! Mostly django applications...
but there are exceptions. I've also signed up to every
web-cloud-hosted-trial-service that I can find [heroku](http://heroku.com),
[openshift](http://openshift.redhat.com), [dotcloud](https://www.dotcloud.com/).

Through various projects at work and in my own time at home, I think I now
have the basic (and the slightly advanced) skills to setup a full cloud
application on virtual machines. don't ask.

One of the niggles with working with lots of machines, I'll explain why
further down, is that you need to maintain subtly different settings and it
isn't the wisest of ideas to store all of that config data in source control.

[12factor.net](http://www.12factor.net/) has 12 good recommendations for
modern sw-dev and has some very persuasive points to make. Read it, read it
now.

Now that you've read that, you'll start to appreciate the number of
environments that you small little application will be running on. And that's
just in your own deployment. In OSS-world, someone else might want to make a
similar deployment too.

Counting explicitly there will be one checkout on my local developer desktop
probably using a locally installed sqlite instance, no proxy/cache, using a
development webserver and secured with my personal passwords. Then there will
be a staging environment, used to prepare virtual machines with the app
integrated into the image. These requires integrating into the operating
system, probably with an apache/mysql with generic passwords. Finally there
will be production deployments, which you let other people interact with. That
is an environment that requires load balancing and performance monitoring.
There may be multiple front ends that the application is deployed to, none of
which maintain state for very long. These are probably backed up by a cluster
of postgres databases, memcached proxies, DNS servers etc. Scaling just
involved adding more machines, which means more deployments.

Of course, using the techniques outlined in 12factor, this model of cloudy
development is a proven methodology.

So, that's 3 or 4 different clones, just to deploy/develop one measly app. Add
in other contributors, then that's when I really start getting scared about
storing any anything not application specific in the repo.

Anyway, I've come up with a solution, easily. It fits my needs well.

So, you have just started a new software project and decided that you're going
to do it in python. I get these niggling feelings all the time, I find writing
them down in a (cloud backed up text file), then never looking at them ever
again, helps.

Let's start with

**hello.py**

    print "Hello World!" 

But of course, that's not very modular, so let's make it a bit more
interesting yet functionally the same.

**hello.py**

    HELLO_STRING="Hello World!"  
    def main():  
         print HELLO_STRING   
    if __name__ == '__main__':  
        main()

Which is a little bit more useful, with the module level "constant". Which
means that we can now import this singleton module Let's expand this a example
further by turning this into a slightly more realistic module that is split
into multiple files.

Place these files into a folder called **hello**  

**__init__.py**

    HELLO_STRING="Hello World!"  
    def main():  
        print HELLO_STRING

  
**__main__.py**

    main()

Now, from the parent directory, you can zip the **hello** folder up and run it
directly. Of course, there are a multitude of other ways to package modules [[
.egg](http://svn.python.org/projects/sandbox/trunk/setuptools/doc/formats.txt)
].

This is great 'n all, but it your code can't run from anywhere else in your
own filesystem without exporting PYTHONPATH, or some other shuffle.

Introducing pip.  
Lets start by implementing the simplest api to distutils so that pip can take
care of future deployments.  

**setup.py**

    from distutils.core import setup  
    setup(  
        name = "hello",  
    )

  
These file can get a lot more information in them, including versioning,
dependency listing and controlling the setup/install process.

When a project starts to use words like "install" and "build process", I start
to get worried and panic about the mess that development/experimental builds
have on my system as a whole. In the pythonic world, there is a work flow that
hides this complexity away from your managed operating system. It acts like
mini-chroots and isolates your work into lightweight virtual environments.
Hence the name [virtualenv](http://virtualenv.org).

You can create your own little virtual env like this.  
1/. cd into the root of your project work. This is the one with the setup.py
file in it.  
2/. virtualenv --distribute --no-site-packages ENV  
3/. source ENV/bin/activate

This plops you into a clean python environment (without python modules that
you system has, but another system might not). The single most practical use
this has is to keep track of dependencies that pip brings in. You don't need
root access to install extra packages, as the environment (including
dependencies) are all stored under the ENV directory. You will need to
activate the environment each time you want to hack around.

If we're working in the OSS world, then consider uploading your modules to
PyPi. Then others can get your module (and you can get other modules) with

    pip install <module>

Now, when it comes to django application, if we follow Factor 3 all
configuration must be in the environment. It doesn't mean we can't store them
in files, just don't store them in code repositories.

And now we come to the point of this posting. Entering the environment,
including the config, is a concious step when using a virtualenv workflow.
There is a way to coordinate this.

In Ruby-land, there is a de-facto standard location to store the environment
in a file called

    .env

as KEY=value pairs, one per line. This file is respected by heroku, useful.

Support for this method of storing the environment can easily be add to your
virtualenv environment.

**ENV/bin/activate**
    # ... at or near the bottom  
    if [ -f .env ]; then  
        export $(cat .env)  
    fi

And there you have it, a fully localized virtual environment, tailored for
running where it is in the filesystem, and not sacrificing security secrets to
the codebase. Just remember not to check in the .env, and force everyone to
make their own.

To finish off, add this to source control and start distributing!

**.gitignore**

    .env  
    ENV  
    *.pyc
    git init  
    git add .  
    git commit -m 'initial commit'  
    git remote add some host  
    git push

