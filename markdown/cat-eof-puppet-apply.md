Apparently, `puppet apply` can handle stdin streams.

This could be useful. I think I'll need to add this to /etc/local.d to replace
some of the provisioning scripts that I was writing.

THIS CHANGES EVERYTHING.

#### Example

    $ cat << EOF | puppet apply  
    file {'hello.txt.':  
       path => "$(pwd)/hello.txt",  
       ensure => present,  
       content => "Hello World!",  
    }  
    EOF  
`

