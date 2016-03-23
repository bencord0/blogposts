It's dawned on me that I can also use this place to express some of my
feelings about the current state of technology. So, here's a small ditty about
why I'm very much a fan of the [Qt framework](http://qt.nokia.com/).

Qt (pronounced 'cute') first came to my attention when I started to use
[KDE](http://www.kde.org/), one of the main desktop environments in Linux. Qt
is the toolkit that makes the buttons, graphics, text and layouts. KDE is
responsible for using Qt to make full applications and, in general, the
complete experience of using a computer to do day-to-day tasks.

The other main desktop environment is called [gnome](http://www.gnome.org/),
based on [Gtk](http://www.gtk.org/)+. There are others, such as the long-
awaited [enlightenment](http://www.enlightenment.org/p.php?p=about/e17)
project which is build upon its own libraries. When learning to program, I
started as most others did by writing little programs that don't do very much.
Most of them we're just things to make the computer do what I could do by
hand, but faster. Quadratic equations, matrix solvers, time keepers,
calculators and all those fun things that don't require architecture specific
dependencies.

However, there are at least two drawbacks of using the C language.

1. Graphics
2. Networking
3. Unicode

The primary reason that these are drawbacks, is because the C language pre-
dates such technologies and therefore does not handle them in the language
itself. In order to make use of them, wrapper libraries have been written to
bring graphics and networking (and a lot of nice things) to C.

Qt and Gtk+ are examples of these libraries. Actually, Qt is a set of
libraries for C++ but also comes with the meta-object system which extends C++
even further by adding some extra keywords (e.g. foreach) and signals/slots
connections.

As I got used to writing small programs that would be forever destined never
to leave the command line, I reached out to third-party libraries to see what
they could offer.

Next: Why I chose Qt.

C++ isn't the most wieldy of languages, some would call it bloated. Maybe in
another post I'll show you why some of the Qt extensions might make it a nicer
(maybe even beautiful) language if one limits oneself to a subset of C++
features. The tag line for Qt has for a long time been 'Code Less, Create
More, Deploy Everywhere'.

My example to you is the Hello World GUI application.  

#### Qt Hello World

    #include <QApplication>  
    #include  <QPushButton>
    int main(int argc, char *argv[])  
    {  
        QApplication app(argc, argv);  
        QPushButton hello("Hello world!");  
        hello.resize(100, 30);hello.show();  
        return app.exec();  
    }
  
To build it, send these commands.  

    $ qmake -project  
    $ qmake  
    $ make

#### Gtk Hello World

    #include <gtk/gtk.h> 
    void  
    hello (void)  
    {  
        g_print ("Hello World\n");  
    }
    void  
    destroy (void)  
    {  
        gtk_main_quit ();  
    }  
    int  
    main (int argc, char *argv[])  
    {  
        GtkWidget *window;  
        GtkWidget *button;
        gtk_init (&argc, &argv);
        window = gtk_window_new (GTK_WINDOW_TOPLEVEL);  
        gtk_signal_connect (GTK_OBJECT (window), "destroy",  
                                    GTK_SIGNAL_FUNC (destroy), NULL);  
        gtk_container_border_width (GTK_CONTAINER (window), 10);
        button = gtk_button_new_with_label ("Hello World");
        gtk_signal_connect (GTK_OBJECT (button), "clicked",  
                                    GTK_SIGNAL_FUNC (hello), NULL);  
        gtk_signal_connect_object (GTK_OBJECT (button), "clicked",  
                                              GTK_SIGNAL_FUNC (gtk_widget_destroy),  
                                              GTK_OBJECT (window));  
        gtk_container_add (GTK_CONTAINER (window), button);  
        gtk_widget_show (button);
        gtk_widget_show (window);
        gtk_main ();
        return 0;  
    }

  
And build it with this makefile.  

    GTK_INCLUDE = -I/usr/local/include  
    GTK_LIB = -L/usr/local/lib  
    X11_LIB = -L/usr/X11R6/lib  
    CC = gcc -g -Wall  
    CFLAGS = $(GTK_INCLUDE)  
    LDFLAGS = $(GTK_LIB) $(X11_LIB) -lgtk -lgdk -lglib -lX11 -lXext -lm
    OBJS = helloworld.o
    helloworld:	$(OBJS)  
    #	$(CC) $(GTK_LIB) $(X11_LIB) $(OBJS) -o helloworld $(LDFLAGS)
    clean:  
    rm -f *.o *~ helloworld

  
The win32 version is so horrendously long, that I'll just refer you to
[google: win32-helloworld](http://www.google.co.uk/search?q=windows+win32+c+he
llo+world).

The same Qt code (just compiled differently) will work on Windows, Linux and
Mac (and some other UNIX flavours). I feel obliged to also tell you that
Nokia, who now own Qt, have added support for both symbian and meego phones
and devices. There's an [android-lighthouse](http://code.google.com/p/android-
lighthouse/) project which hopes to bring Qt to the Android platform.

Now can you see why I like Qt so much?  