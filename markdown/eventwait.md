Here's an interesting consequence of threaded programming that I found in
python today.

The idea is that you have some worker thread (or threads), managed by the main
thread. If the workers finish or fail, the main thread fires up more jobs for
them to do unless the user Ctrl+C's (or otherwise interrupts) the main thread,
signaling the workers to cleanup and exit.

This is a fairly standard problem so long as the tasks are not CPU bound and
if your tasks are CPU bound, then see the note at the bottom of this post. And
even if you are CPU bound, the meat of this post is still relavent.

#### threading.Event()

Here is a program that spawns up the task in a thread, blocks until
interrupted, then cleans up and exits.

    def main():  
        t = MyTask()  
        t.start()  
        try:  
            t.wait()  
        except KeyboardInterrupt:  
            t.stop()  
            t.wait()  
    if __name__ == '__main__':  
        main()

We'll pretend that the MyTask class is doing all of the threading magic for
us. The useful thing about this approach, is that I can spawn multiple tasks,
and have them do things in parallel.

    def main():  
        tasks = [MyTask() for t in range(5)]  
        [t.start() for t in tasks]  
        try:  
            [t.wait() for t in tasks]  
        except KeyboardInterrupt:  
            [t.stop() for t in tasks]  
            [t.wait() for t in tasks]

List comprehensions are fun.

So, what does the MyTask class actually look like, and what happens in .start,
.stop and .wait?

    import threading  
    class MyTask(object):  
        def __init__(self):  
            self.task = get_task() # defined elsewhere, returns a callable  
            self.thread = None # thread to run task in  
            self.stopped = threading.Event() # threadsafe way to findout when to stop  
        def monitor_task(self):  
            while not stopped.wait(1):  
                # Pretend this is a perfect world, with no exceptions.  
                self.task()  
                self.task = get_task()  
        def start(self):  
            self.thread = threading.Thread(target=self.monitor_task)  
            self.thread.daemon = True  
            self.stopped.clear()  
            self.thread.start()  
        def stop(self):  
            self.stopped.set()  
            # we'll pretend that this has some meaning too   
            self.monitored_task.cleanup()  
        def wait(self, timeout=None):  
            return self.thread.join(timeout)

Well, that was easy. But there hides a subtle bug.

If the callable returned by _get_task()_ runs forever, then there is no way to
stop the program. The subtlety is that the _wait()_ in the main function's try
block. According to the
[documentation](http://docs.python.org/3/library/threading.html#event-objects)
"The `wait()` method blocks until the flag is true", and they mean it.

Ctrl-C, SIGTERM, raising other exceptions are all blocked until another thread
calls self.stopping.set() on the event. SIGKILL works, but there's no cleanup.

#### My solution

Eventually, I settled for the less elegant method of thread counting.

    import itertools  
    def main():  
        ...  
           try:  
                   # Block until all tasks have ended  
                   for t in itertools.cycle(tasks):  
                           t.stopped.wait(1) # Non-blocking, doesn't eat CPU time  
                           if threading.active_count() <= 1:  
                    # Only really occurs if the tasks truly finish  
                                   raise KeyboardInterrupt  
        except KeyboardInterrupt:  
            ...

I'm not sure I can think of a neater way right now.

#### Appendinx A: CPU bound tasks in Python

The popular interpreters in python (CPython, pypy) have something known as the
GIL. Essentially, to make the implementation easier, only one bit of bytecode
is being interpreted at any given moment. This is not a problem with Python
the language, as JPython and IronPython don't have a GIL, and many other
interpreters also have a GIL too.

The effect is that this requires a small change in programming style to make
the best use of a modern multicore system.

In Jython and IronPython, just keep using threads. CPU intensive tasks will
scale with the number of cores present.

In GILed interpreters, it is best to spawn extra processes, which can live on
different cores, and do the work there. Python's standard library offers two
ways of doing this. The subprocess module, which offers a pythonic API over
the unix process model and InterProcess Communication (IPC) using pipes to
stdin/out/err. There is also the multiprocessing module, which offers an API
compatible with the threading module. Porting threaded code to use
multiprocessing is easy enough.

The downside is that processes do no share memory, unlike threads which allows
for reading and writing to variables from different threads easy.

There is an effort to remove the GIL from pypy (and possibly port that to
cpython) using a technique known as Transactional Memory. You can donate to
the project at [pypy.org](/admin/blog/blogpost/add/pypy.org/tmdonate.html)