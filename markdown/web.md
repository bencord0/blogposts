Reasons why I shouldn't be let anywhere near web development.  
<https://gitorious.org/random-useless-scripts/pygi>

  
I'm not a big fan of closing tags, markup languages like HTML and XML really
annoy me. It may be nice to a computer, and semi-readable by humans but it's
hard to keep track of large scraps of xml and it's hard to find good
formatters.

Pygi is my attempt to get around this by using a higher language to remove
some of the work.  
Take a look at pygi.py ad my favourite function, endall() which walks back
along the tag stack, and closes them all.

It's a fun way to speed up writing websites and leaves me left to think up the
design rather than spend time debugging tags.

So, here's my attempt at a simple chat application. No javascript, written in
HTML (with some HTML5-ness) and driven by python3.

There's plenty of room left for improvement, username support, colour choices
and so on.  
I might even write a client instead of relying on browsers. Merge requests
welcome.  
