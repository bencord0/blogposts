In my last post, I showed the basics of the new asyncio module brings to
python programming. What a coroutine is, how to run them and getting the
results back in ways that should be readable by most python programmers. The
routines are quick examples how to get started, and hopefully can be used to
eliminate some of the waiting that io-bound programs have.

This time, I'm going to go into a few of the extra APIs that are part of
asyncio. These will form a toolbox of ways that a programmer now has when
solving concurrent problems.

We'll start with some boilerplate functions of different "speeds" with some
artificial waiting involved.

    from asyncio import *
    def a():
        yield from sleep(3)
        print("a")
        return "a"
    def b(B):
        yield from sleep(1)
        print(B)
        return B

Starting simple, pretend to be completely synchronous.

    def main():
        a_result = yield from a()
        b1_result = yield from b("b1")
        b2_result = yield from b("b2")
        return [a_result, b1_result, b2_result]
    if __name__ == '__main__':
        loop = get_event_loop()
        result = loop.run_until_complete(main())
        print(result)

In the rest of my examples, I'll use the same idiom of getting the default
event loop, completing the main() function and printing the result. You should
try out the examples yourself to get a fee for how they run. Pay attention to
the order that functions get called, how long they take relative to each other
and their basic interactions. Asynchronous programming can quickly become non
deterministic.

Non deterministic? Basically, we can choose to run coroutines in whatever
order we like.

    def main():
        a_coro = a()
        b1_coro = b("b1")
        b2_coro = b("b2")
        results = []
        for coro in b1_coro, b2_coro, a_coro:
            result = yield from coro
            results.append(result)
        return results

This is a very manual way of showing what will be a common convention which is
split into three stages. Preparing a bunch of coroutines to be run, iterating
over all of them and retrieving their results.

The trick in asynchronous programming, is that these functions can all be
running at the same time, so some coroutines might finish before others.

    def main():
        coros = [
            async(a()),
            async(b("b1")),
            async(b("b2"))]
        results = []
        for f in coros:
            result = yield from f
            results.append(result)
        return results

With the asyncio.async function, we can pre-schedule a coroutine in the event
loop. When we start waiting for one of the coroutines, the can all be running
in parallel.

However, this examples does have a problem when scaling up to larger programs.
There is a head-of-line blockage if coroutines at the start take longer than
other coroutines in the iterable.

Thus, asyncio has a tool that will let us iterate over some coroutines, and
let us handle them as they complete. asyncio.as_completed()

    def main():
        coros = [
            async(a()),
            async(b("b1")),
            async(b("b2"))]
        results = []
        for f in as_completed(coros):
            result = yield from f
            results.append(result)
        return results

The three step scatter/gather/return idiom is so common in parallel
programming, that asyncio even has a tool to simplify all of this.

    def main():
        results = yield from gather(a(), b("b1"), b("b2"))
        return results

This is useful for most circumstances, however it too has a flaw. What happens
if one of the coroutines throws an exception?

To handle this, asyncio borrows from the concurrent.futures module a slightly
modified version of the Future class.

The Future, is a class that can encapsulate the result of a coroutine;
protecting the calling function from mishappen exceptions. Futures provide an
API that we can inspect at any point during their execution to find out, if
the task has completed, what was the result if it did, and what went wrong.

The methods tend to come in pairs: .set_exception(exp) and .set_result(res)
.exception() and .result() .cancelled() and .done()

I won't go into detail here, except that I'll be using the .result() with
another of the tools that asyncio gives us. The wait() function.

    def main():
        results, _ = yield from wait([a(), b("b1"), b("b2")])
        results = [r.result() for r in results]
        return results

Unlike gather(), wait() gives us a little bit more control and introspection
over what happened when the coroutines executed. The list comprehension here
is one way of analysing the results, but I think that other extra checks can
be performed here too.

One of the useful features of wait(), is that it does not have to block
waiting for all of the provided coroutines to finish. In essence, we can treat
it as a glorified select() function and implement our own higher order event
loop.

    def main():
        pending = [a(), b("b1"), b("b2")]
        results = set()
        while pending:
            done, pending = yield from wait(pending, return_when=FIRST_COMPLETED)
            results.update([d.result() for d in done])
        return results

In fact, wait is much more flexible than gather().

    def main():
        pending = [a(), b("b1"), b("b2")]
        extra = [b("b3"), a(), b("b4"), b("b5")]
        results = []
        while pending:
            done, pending = yield from wait(pending, return_when=FIRST_COMPLETED)
            results.extend([d.result() for d in done])
            if extra:
                pending.update([extra.pop(0)])
        return results

Finally, we can combine all of this into a fully evented main loop that can
have tasks added externally without needing to wait for the long lived tasks
to have finished.

    def main():
        done = set()
        pending = {a(), b("b1"), b("b2")}
        extras = {a(), b("b3"), b("b4")}
        while pending:
            just_done, pending = yield from wait(pending, timeout=0.2)
            done.update(just_done)
            if extras:
                pending.add(extras.pop())
        return [d.result() for d in done]

Here is it important to realise that at any iteration during the loop,
just_done or pending could be empty sets. just_done could be empty if no
coroutine that we are waiting for has finished yet and the timeout expired.
This lets us inject more tasks by dequeuing the extras.

It isn't hard to see that this could easily be extended to become a full blown
WSGI stack.

