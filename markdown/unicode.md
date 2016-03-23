Dear present and future me, friends and visitors. Unicodifiying your computers
is not a hard thing to do. If you use Python3, then the str type is unicode.
In Python2, you need to use the built-in type unicode.  

    bencord0@parsley ~ $ sudo cat /etc/env.d/02locale   
    LANG="en_GB.UTF-8"  
    bencord0@parsley ~ $ sudo env-update && source /etc/profile  
    >>> Regenerating /etc/ld.so.cache...  
    bencord0@parsley~ $ locale  
    LANG=en_GB.UTF-8  
    LC_CTYPE="en_GB.UTF-8"  
    LC_NUMERIC="en_GB.UTF-8"  
    LC_TIME="en_GB.UTF-8"  
    LC_COLLATE="en_GB.UTF-8"  
    LC_MONETARY="en_GB.UTF-8"  
    LC_MESSAGES="en_GB.UTF-8"  
    LC_PAPER="en_GB.UTF-8"  
    LC_NAME="en_GB.UTF-8"  
    LC_ADDRESS="en_GB.UTF-8"  
    LC_TELEPHONE="en_GB.UTF-8"  
    LC_MEASUREMENT="en_GB.UTF-8"  
    LC_IDENTIFICATION="en_GB.UTF-8"  
    LC_ALL=  
    bencord0@parsley~ $ python3  
    Python 3.1.4 (default, Dec 13 2011, 16:25:45)   
    [GCC 4.4.5] on linux2  
    Type "help", "copyright", "credits" or "license" for more information.  
    >>> '\u0394'  
    'Δ'  
    >>> exit()   
    bencord0@parsley~ $ python2   
    Python 2.7.2 (default, Nov 1 2011, 13:03:41)   
    [GCC 4.4.5] on linux2  
    Type "help", "copyright", "credits" or "license" for more information.  
    >>> print u'\u0394'  
    Δ  
    >>>

The rest of the time, just remember to catch UnicodeDecodeError.