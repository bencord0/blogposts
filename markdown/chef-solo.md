![Full Size Chef Puppet](http://d13z1xw8270sfc.cloudfront.net/resize/52591/lat
in_chef_25_inch_full_puppet.jpg/300/300/0/) Full Size Chef Puppet

The [Chef](http://opscode.com/chef) hello world equivalency is not as straight
forward as a [shell redirection](http://bencord0.wordpress.com/2012/11/09/cat-
eof-puppet-apply/) that is [Puppet](http://puppetlabs.com). But after teaching
[@crizzXe](https://twitter.com/crizzxe) how to deploy an appliance that I've
been working on I now have a good way to convey what's going on.

#### Workflow

The workflow is simple enough. On the system to be configured, the Node, run
the Chef with a Recipe to prepare your server.

The recipes are stored as a git repository (or tarball checkout)
[[example](https://github.com/bencord0/chef-solo-repo)].  

    # git clone git://github.com/bencord0/chef-solo-repo.git ~/tray

  
The chef programs will need to be installed.  

    # gem install chef

  
or, for the Gentoo inclined,  

    # emerge --autounmask-write chef  
    # dispatch-conf  
    # emerge chef

  
Cook it all together with  

    # chef-solo -c ~/tray/config/solo.rb -j ~/tray/config/node.json  
    # cat /tmp/chef-solo.txt

  

#### Resources
  
Now, got to the [Recipe DSL
Reference](http://docs.opscode.com/chef/dsl_recipe.html), and flesh out
_cookbooks/default/recipies/default.rb_ with whatever else you need.

The initial learning curve is steep, but in less than 200 words I have
distilled the essentials. Everything else is about extending the resources
that are managed by chef, and changing configuration parameters.

Other infrastructure includes adding a chef-server (or puppetmaster) to add
co-ordination and persistence to a farm of nodes.