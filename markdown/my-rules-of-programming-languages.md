I've found myself stumbling into a few [programming
languages](http://en.wikipedia.org/wiki/Programming_language) recently.
Normally I deal with C, C++ and associated build systems. Today, I had a dive
into some others.  

#### [Awk](http://www.gentoo.org/doc/en/articles/l-awk1.xml)

I like this one. The basic syntax is very similar to C statements, but
[awk](http://cm.bell-labs.com/cm/cs/awkbook/index.html) can be invoked from
the terminal. Just remember to take a few extra keystrokes and properly escape
the command line.

I've come to think of it as a stream editor with state. With awk, one can
condense really long find/grep/sed/cut piped commands.

I haven't figured out a nice way to print the rest of the line from the Nth
index/offset/match yet. There's a way to do this with a loop, but it's not a
quick CLI one-liner. If syntax like  
`awk '{print $3..$NR}'` existed, then that would be nice.  

#### [php](http://uk.php.net/tut.php)

There is finally a language that is more detestable than the
[autotools](http://www.gnu.org/software/hello/manual/automake/Autotools-
Introduction.html) build system. Actually, dropping in the autotools for php
might be a preferable solution in my eyes. Start with a template
webpage.html.in, run your macros or functions and spit out webpage.html from a
web server.

That process is what php wants to be. It's the implementation that let it
down. Have you ever looked at a php/html source and admired the beauty?

Example.  

    <?php if (condition) ?>  
    	<some html> and text </some>  
    <?php } else { ?>  
    	<other html> or text </other>  
    <?php } ?>

  
I don't know why code structures like this are even allowed to exist. How many
open/close structures do you really need? Is it trying to be an html tag? a
comment? If php is going to be parsed before the final HTML is sent to the
browser, then does it even need to look like HTML at all? For something as
conceptually simple as 'if' statements, I'd be happy with the C preprocessor
expanding macros when a page is requested. Prizes for anyone who is brave
enough to make this work.

Other things that irk me are [php variables](http://www.php.net/). What's up
with the $dollarprefixing? If you have unique keywords, then a computer can
figure out that everything else is going to be some kind of variable. Does
this need explicit marking? Prefixing a keyword with a special symbol should
be done for a good reason. In C/C++, the use of a * prefix denotes
dereferences of pointers. bash $VARIABLES and ${VARIABLES} are expanded when
parsed and have a different meaning without the $ prefix. The same goes for
awk. This matter is a bit tetchy, I'm looking at you Ruby.

Even if I don't like it, I do have to concede that php is one of the best ways
to start making server-side scripts. I hear there's a popular website named
[facebook](http://developers.facebook.com/blog/post/358) that has developed a
way to convert this <del>awful</del> slow language into a compiled binary
instead.

**Update:** [Part 2](http://bencord0.wordpress.com/2011/06/28/programming-rules-part-2/)  