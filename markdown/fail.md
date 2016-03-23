There's nothing like a fresh start. Unfortunately last weekend's reinstall of
juniper went less happily than I expected.

A source based distro notices problems quickly. It starts as simple
compilation errors. The linker being unable to create a final executable, or
being unable to spawn a new shell instance. A bunch of random errors in tasks
that usually work.

You start to question your sanity in choosing this OS, it's been historically
reliable. It must be some other reason. But deep down the probability counters
are incrementing towards the conclusion that means that no fancy fingerwork
will fix. Presenting, **The Hardware Problem**.

#### 1/. Admit that you're going to have downtime.
  
It broke. It didn't work. Now something needs to be done.

There are multiple possibilities that you can do at this stage. The Developer
in me would go through some logs, find the config typo and increment the
version string.  
The Tester in me would keep the system in a confused state and grab as much
persistent data as possible.

This is a setup that should just work™. So the SysAdmin in me takes over.
Reboots into memtest and starts poking around.  

#### 2/. Diagnose the problem
  
Memtest reports errors. I knew there were some, but it's nice to confirm this
properly. Better fire up the external music player, it's going to be another
hour or so of hunting down the specific RAM chip. Then praying that it's only
one.

Extra points if you work around the broken bios because the POST was loaded
into faulty RAM chips on your positive diagnostic run. oops.  

#### 3/. Put in a temporary fix

In a more prepared environment there would be a hot standby (just reprogram
the load balancers), or replacement hardware in a nearby cupboard. This is a
home system, so just remove the broken chip, and run with what's left.  

#### 4/. Resume what you were doing
  
The problem was fixed. All is right with the world. We can now continue from
where we started.  
Oh wait, LVM is complaining about IO errors now.  

#### 5/. Back into diagnostic mode
  
Fire up the LiveUSB environment again. This runs in RAM (now proven to be
safe). smartctl to the rescue.

3 HDDs, 1 has 14 errors logged, and the other 2 are about to fail. dmesg
reports that they're taking a little longer to start up too.  

#### 5/. Resign a sigh

  
[Amazon.co.uk](http://www.amazon.co.uk/gp/product/B006KCX0UE/ref=oh_details_o01_s00_i00)  
