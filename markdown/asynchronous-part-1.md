I've been itching to play with some of the new features of python 3.4. The
most anticipated feature is the new asynchronous module which should, the hope
is, let us run concurrent code without going insane. This will be a code heavy
post, with some very new features that the community at large hasn't really
decided on any best practices yet. This will probably be a multi part series
getting deeper into the intricacies of async programming in python. I haven't
yet seen a good series of idioms yet, so this is mostly exploratory. This post
will serve as an introduction to using async programming for the synchronously
minded. Later I'll go into some of the extra APIs that let you really make the
most of async programming. After that I'll try to make a third post about
using these techniques to do something more practical than waiting for
sleep().

    import asyncio
    import contextlib
    import time
    @contextlib.contextmanager
    def timer(msg):
        print(msg)
        T = time.time()
        yield
        print(time.time() - T)

We'll do some simple context manager based benchmarks to figure out if we're
doing things right.

    #notacoroutine
    def a(A="a"):
        time.sleep(1)
        return A
    @asyncio.coroutine
    def b(B="b"):
        yield from asyncio.sleep(1)
        return B

Define some functions, a() is a normal synchronous python function that every
one is used to, b() is a coroutine. By observation, they do the same thing
except that b() has a "yield from" statement turning this into a generator.
"yield from" is valid in python 3.3 onwards. The "asyncio" module is in the
standard library in 3.4, but available in PyPI for 3.3. Here's how to use
them.

    def main():
        with timer("Normal synchronous code"):
            for x in range(5):
                print(a())
    if __name__ == '__main__':
        main()
    ## 5.005340099334717

These examples are going to call a function 5 times, and time how log it takes
overall.

    def main():
        loop = asyncio.get_event_loop()
        with timer("Using asynchronous code synchronously"):
            for x in range(5):
                retval = loop.run_until_complete(b())
                print(retval)
    if __name__ == '__main__':
        main()
    ## 5.007107496261597

With coroutines, you have to use them inside a function which is why my
examples will be wrapped in a main() construct. This is because generators,
and the yield function is that need something to yield to, the event loop.
"loop" will be the default event loop, which has a pluggable interface so that
the implementation can be changed without changing the API. We can then tell
the loop to run the b() coroutine until completion and return as if this was
synchronous code. If you ever need to convert a coroutine to a normal blocking
function, then this is a useful construct as a last resort. It is a little bit
messier than the synchronous calls, but anyone can follow this logic. There is
no speed increase.

    def main():
        loop = asyncio.get_event_loop()
        with timer("Separate function call, and code running"):
            tasks = []
            for x in range(5):
                task = b()
                tasks.append(task)
            for task in tasks:
                retval = loop.run_until_complete(task)
                print(retval)
    ## 5.006737232208252

Using generators lets us split up defining functions, calling them and running
them. It might be useful to do it this way, but the real benefit comes if we
can run tasks in parallel.

    def main():
        loop = asyncio.get_event_loop()
        with timer("Briefer concurrency with map"):
            tasks = [asyncio.async(b()) for x in range(5)]
            print(*map(loop.run_until_complete, tasks))
    ## 1.002532958984375

The key ingredient here is that we can call async() on the generator. This
schedules the coroutine into the event loop and we can assume that it is
running, but have no idea if it has finished. Calling run_until_complete() on
each task in turn will drop out the results. While this is quick and quite
readable, I think we can do a bit better.

    def async_map(func, *iterables, event_loop=None):
        loop = event_loop or asyncio.get_event_loop()
        args_iter = zip(*iterables)
        tasks = [asyncio.async(func(*args)) for args in args_iter]
        for task in tasks:
            yield loop.run_until_complete(task)
    def main():
        with timer("Async map, not using the event loop directly"):
            tasks = [b for x in range(5)]
            retvals = [r for r in async_map(lambda x: x(), tasks)]
            print(*retvals)
    ## 1.0016822814941406

It's useful to hide slightly tricky idioms behind convenience functions such
as an asynchronous version of map(). Event loop handling boilerplate can be
moved out and we're back to quick and readable code again.

    def async_map(func, *iterables, event_loop=None):
        loop = event_loop or asyncio.get_event_loop()
        args_iter = zip(*iterables)
        if asyncio.iscoroutinefunction(func):
            coro = func
        else:
            @asyncio.coroutine
            def coro(*args):
                return func(*args)
        tasks = [asyncio.async(coro(*args)) for args in args_iter]
        for task in tasks:
            yield loop.run_until_complete(task)
    def main():
        with timer("It still works with synchronous functions"):
            tasks = [a for x in range(5)]
            retvals = [r for r in async_map(lambda x: x(), tasks)]
            print(*retvals)
    ## 5.006326913833618

I've added a conditional so that this still works with normal functions.

    def main():
        apply = lambda x: x()
        with timer("Mixin' it up"):
            tasks = [b, a, b ,a, b]
            retvals = [r for r in async_map(apply, tasks)]
            print(*retvals)
    ## 3.004204511642456

And you can even mix synchronous and asynchronous code. Lessons learnt, we can
use any paradigm we want. But there are potential speed-ups to be had in IO-
bound code.

