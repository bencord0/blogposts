<http://twitter.com/openshift/statuses/233780080940314624/>

Since you asked, I'll talk you through it.

#### 1/. Prepare a clean setup

I have some handy stage4 tarballs and a spare Xen VM.

The Gentoo handbook (www.gentoo.org/doc/en/handbook) is the best documentation
to installing a basic gentoo system with network access and a working
compiler.

In terms of system resources, don't skimp. 512MB RAM is not enough to install
the gems! A minimum of 1G RAM is a must. In my short experience, ruby
applications are use a lot of memory so avoid depending on swap.

This heavier footprint is disappointing. Breaking the 512MB limit means that
deploying one some of the smaller (free) plans from other cloud services is
impossible. You can't run OpenShift on OpenShift.

#### 2/. Install the system wide dependencies

    emerge -avuk git bundler rake mongodb  

The -a and -v switches let you make sure that emerge is doing what you want it
to do. Tweak any USE flags and keywords here, the defaults are safe. The -u
and -k flags are shortcuts to speed up the emerge, -u will skip any packages
already installed (but still allows upgrades) and -k (or -g ig you have set
PORTAGE_BINHOST) will use binary packages if you have them.

dev-db/mongodb is currently in ~arch. Remember to add it to
/etc/portage/package.keywords along with dev-lang/spidermonkey and app-
arch/snappy.

#### 2a/. Activate mongodb

    sudo /etc/init.d/mongodb start  
    mongo localhost/admin --eval 'db.addUser("admin", <password>)'  

Turn on mongodb with authentication.

    /etc/conf.d/mongodb  
    MONGODB_OPTIONS="--journal --auth"  
    sudo /etc/init.d/mongodb restart  
    /usr/bin/mongo localhost/admin << EOF  
    db.auth("admin", <password>)  
    use stickshift_broker_dev  
    db.addUser("stickshift", <password>)  
    EOF  

#### 3/. Grab the openshift sources

Drop down to normal user privilages. Create a user if you have to.

    git clone git://github.com/openshift/crankcase.git  

#### 4/. Install the local dependencies

Ruby gems are installed to $HOME/.gem/, so add that to your PATH.

    echo PATH=$HOME/.gem/ruby/1.8/bin:\$PATH >> $HOME/.bashrc  
    echo export PATH >> $HOME/.bashrc  

Logout, then log in and check that the new PATH has been loaded.

The crankcase repository is a super repository for lots of openshift goodies.
Since we can't 'yum install rubygem-stickshift-*', we need to create the gem
from source and install it locally.

    cd crankcase/stickshift/common  
    gem build stickshift-common.gemspec  
    gem install stickshift-common-*.gem  

gem build creates a versioned .gem package.  
gem install resolves dependencies from the internet and installs the gem
locally.

    ls ~/.gem/ruby/1.8/gems # to make sure that it got installed.  

Now do the same for stickshift/node, stickshift/controller and
swingshift/mongo.  
Currently stickshift/node is a dependency, but should not be in future
versions.

#### 5/. Prepare the broker

    cd stickshift/broker  

Update the database config under config/environments/development.rb

Create config/environments/plugin-config/swingshift-mongo-plugin.rb according
to the [openshift documentation](https://openshift.redhat.com/community/wiki
/build-your-own-paas-installing-the-broker#Configure_Mongo_data_store_plugin)

Hook into the plugin configuration file with

    echo "require File.expand_path('../plugin-config/swingshift-mongo-plugin.rb', __FILE__)" >> config/environments/development.rb  

Add the plugin to the Gemfile

    ...  
    #Add plugin gems here  
    gem 'swingshift-mongo-plugin'  

Gather it all together  

    bundle  

This command will fail if you don't have enough RAM.

#### 6/. Run the broker

Edit scripts/rails. Bump the port to something higher, so that you don't need
root privilages to run it. Disable SSL, or generate a certificate/key pair for
rails to use.

Run the server with  

    bundle exec rails server  

The broker application is now running. Connect to it with a browser or curl.
Don't be too disappointed with the resulting error about a routing error. The
broker is an API server for RESTful requests from the rhc client tools, not a
website.

#### 7/. Run the test suite

    /usr/bin/rake test  

While not all tests pass, it's not a complete failure.

DB errors can be quenched by setting config/environments/test.rb with
appropriate values.

Some of the failures are dure to missing packages, trying to be smart and
calling 'rpm' to install missing gems.

#### 8/. Where to go from here

I called the rails application by hand. The repository contains some helpful
init system hooks for Debian and RedHat(under init.d), Fedora (under systemd)
and apache (under httpd). To integrate this into Gentoo's OpenRC, the closest
thing would be to add a new script based on init.d/stickshift-broker.

My personal preference would be to switch to systemd and use the provided
systemd/stickshift-broker.{env,service}. In Gentoo, OpenRC and systemd can be
installed at the same time. The init system in use will be decided on boot
(init=/sbin/init or init=/usr/bin/systemd). Using the systemd service files
provided is a better solution for cross-distro compatibility and future
proofing. As always, in Gentoo the choice is available to spin your own init
scripts, or just hook into apache.

Once hooked into an init system, then dropping down to port 80 or 443 with
root privileges is more appropriate.

I have also not yet attempted DDNS integration and message queues.

#### Conclusion

I have the first piece of an OpenShift Origin deployment working under Gentoo.
It is a very hands-on install, and I don't have any ebuilds yet. This is a
really good test for the Open Cloud and the principal of platform
independence.