So, a friend of mine wants to learn a programming language. I oblige and tell
them to try C. He's been learning for a while now, and has the basics that can
be found easily in the first chapters of resources normally given to those new
to programming.

I could use this moment to take time to explain fundamentals and underlying
theory, but perhaps diving straight in would be best.  
  

    /** main.c  
     * compile with: [gcc](http://gcc.gnu.org) -o hello main.c  
     */
    #include <stdio.h>  
    int main(void) {  
        printf("hello ");  
        printf("world\n");  
        return 0;  
    }

  

There we go, a simple [hello world
program](http://en.wikipedia.org/wiki/Hello_world_program). First step is to
break up the code into functions. In larger programs, the main() function is
usually reserved to control program flow. This leaves the real work to be
delegated to other functions that are called from main().

  

    /** main.c  
     * compile with: gcc -o hello main.c  
     */
    #include <stdio.h>  
    void hello(void) {  
        printf("hello ");  
        printf("world\n");  
    }
    int main(void) {  
        hello();  
        return 0;  
    }

  
Now that the program has been broken into two logical parts, it is now
possible to place them in two separate compilation units.  

    /** main.c  
     * compile with hello.c: gcc -o hello hello.c main.c  
     */
    void hello(void);  
    int main(void) {  
        hello();  
        return 0;  
    }

  

    /** hello.c  
     * compile with main.c  
     */
    #include <stdio.h>  
    void hello(void) {  
        printf("hello ");  
        printf("world\n");  
    }

  
It is still possible to compile this program in one command, however this
becomes very inconvenient for large projects. A practical solution is to
compile the source files into an intermediate form known as object files.
Object files can then be combined into the final program, this process is
called linking.  

    gcc -c main.c  
    gcc -c hello.c  
    gcc -o hello hello.o main.o

  
The -c flag tells the compiler to generate object (.o files) from source
files. The third command is the link stage that generates the executable.

So, what's the point? The only difference between the last line and the
original is that .c is replaced with .o AND you still have to generate the
object files. The good news is that all of this typing can be cut down by
making use of a build system.  

#### The Makefile

  
Without Makefiles, software development would be a lot more tedious than it
needs to be.  

    # Makefile  
    OBJECTS = main.o hello.o
    all: hello
    %.o: %.c  
        gcc -c -o $@ $<
    hello: $(OBJECTS)  
        gcc -o $@ $^
    clean:  
        rm -f $(OBJECTS)
    .PHONY: clean

  
Put this file in the same directory as the above source code, and here's how
to use it.  

    make

  
This four letter command will parse the Makefile and use it to 'make' the
output executable. The cool thing about make is that it will only update what
it needs to. Make a trivial change to one of the .c files then give the 'make'
command another twirl. This time, make knows that the timestamp of the source
file is after the timestamp of the executable and executes only the needed
targets.

Using this simple tool, your project can grow into as many files that you
need. If you add more source files (eg. anotherfile.c), just remember to add
the new file to OBJECTS variable.  

    OBJECTS = main.o hello.o anotherfile.o

  
If you want more details, there's a comments section below. I haven't covered
everything here, there's still more stuff like header files, library files and
not to mention the intricacies of the build system. Enjoy.  
