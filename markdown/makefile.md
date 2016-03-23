I have been reading the GNU Make manual. I knew about some of these features
already, implicit rules, special targets etc. I've used .PHONY for a while,
without *really* knowing how it works (and thus, how to properly use it).

Today, I've learnt about .ONESHELL (new in gmake 3.82).

#### .PHONY

The .PHONY target is usually used to optimize make so that targets like 'all',
'clean' and even 'dist' don't look for files named 'all', 'clean' or 'dist'.  

    TARGETS=hello goodbye  
    all: build dist  
    build: $(TARGETS)  
    clean:  
    	-$(RM) *.o  
    	-$(RM) $(TARGETS)
    dist: hellogoodbye.tar.gz  
    %.tar.gz: $(TARGETS)  
    	tar czf $@ $^
    .PHONY: all build clean dist

If there exist hello.c and goodbye.c source files in the current directory,
then invoking 'make build' will compile and link the targets individually and
'make dist' will tarball them. 'make clean && make dist' will force a full
rebuild.  

#### .ONESHELL

In the most recent release of GNU Make, 3.82, if the target '.ONESHELL' is
defined, then make will execute the commands in every recipe in a single shell
invocation. Combine that with the 'SHELL' variable, and you have an
interesting tool to hand.  

    VIRTUALENV=venv  
    SHELL=/usr/bin/python
    get: $(VIRTUALENV)  
            @activate_this = 'venv/bin/activate_this.py'  
            execfile(activate_this, dict(__file__=activate_this))  
            import requests  
            r = requests.get("http://httpbin.org/get")  
            print(r.text)
    $(VIRTUALENV): requirements.txt  
            @import subprocess;run_cmd=lambda s:subprocess.call(s.split())  
            run_cmd("virtualenv --distribute $(VIRTUALENV)")  
            activate_this = 'venv/bin/activate_this.py'  
            execfile(activate_this, dict(__file__=activate_this))  
            run_cmd("pip install -r requirements.txt")  
            run_cmd("touch $(VIRTUALENV)") # Update the timestamp
    freeze: venv  
            @import os;run_cmd=lambda s:os.execvp(s.split()[0],s.split()[0:])  
            activate_this = 'venv/bin/activate_this.py'  
            execfile(activate_this, dict(__file__=activate_this))  
            run_cmd("pip freeze")
    .ONESHELL:  
    .PHONY: freeze get

Think of the possibilities.

One of the limitations of .ONESHELL is that if it is defined, it is defined
globally (for that makefile). Unlike .PHONY, .ONESHELL cannot (yet?) be given
a list of targets that it will act upon. That's why, for now, I need to use
those fancy 'run_cmd' lines because, now that I've switched to python, I no
longer have bash.