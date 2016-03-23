
    #!/bin/bash
    echo -n "Passphrase:"  
    read -sr p  
    gpg -d --batch --passphrase "$p" "$0" | python
    exit $?  
    -----BEGIN PGP MESSAGE-----  
    Version: GnuPG v2.0.19 (GNU/Linux)
    jA0EAwMClL8rFOkU2Nm0yTK6hn6pQXkvOV1Q6Zn4fSrdAA4hrsOfYKkN5YMsJEIS  
    khru8d9rbGU1nLVnso1VhGJWpg==  
    =9G1r  
    -----END PGP MESSAGE-----

  
Maybe I should combine this with
[puppet](http://blog.condi.me/blog/cat-eof-puppet-apply/).

