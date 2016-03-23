Python 3.4 is out [today](https://mail.python.org/pipermail/python-dev/2014-March/133193.html)!
So here is the third and final part in my series about some of the new shiny
that comes with. The end goal is to be able to write non-blocking code without
changing our synchronous habits. I'll start with a simple TCP server that
listens for connections and spits out whatever is received. This should be
familiar to anyone who is new to socket programming.

    import asyncio
    import socket
    def main():
        s = socket.socket(socket.AF_INET6, socket.SOCK_STREAM)
        s.bind(("::", 8888))
        s.listen(5)
        print("Listening on: {}".format(s.getsockname()))
        while True:
            c, a = s.accept()
            print("Connection from: {}".format(a))
            while True:
                print("Receiving from: {}".format(a))
                data = c.recv(1024)
                if not data:
                    break
                print(data.decode())
            c.close()
            print("Connection closed")
            print("Next connection...")
    if __name__ == '__main__':
        main()

Python is already quite good at abstracting away most of the hard bits when
doing socket programming over plain C sockets. In order to run this routine in
parallel, we need to chop it into individual tasks. Clearly, accepting client
connections, and receiving data from them are two independent things, so we
can separate out the loops into functions.

    def main():
        s = socket.socket(socket.AF_INET6, socket.SOCK_STREAM)
        s.bind(("::", 8888))
        s.listen(5)
        print("Listening on: {}".format(s.getsockname()))
        def accept_connections():
            while True:
                c, a = s.accept()
                print("Connection from: {}".format(a))
                recv_all(c, a)
                print("Next connection...")
        def recv_all(c, a):
            print("Receiving from: {}".format(a))
                while True:
                    data = c.recv(1024)
                    if not data:
                        break
                    print(data.decode())
                c.close()
                print("Connection closed")
        accept_connections()

Partitioning sequential work is crucial to any parallel programming. It also
makes the code much easier to follow. Finally, replace all blocking socket
operations, with non blocking equivalents. The useful thing about the asyncio
module is that it lets us keep the code looking like the blocking/synchronous
versions.

    def main():
        s = socket.socket(socket.AF_INET6, socket.SOCK_STREAM)
        s.setblocking(0)
        s.bind(("::", 8888))
        s.listen(5)
        print("Listening on: {}".format(s.getsockname()))
        loop = asyncio.get_event_loop()
        def accept_connections():
            while True:
                c, a = yield from loop.sock_accept(s)
                print("Connection from: {}".format(a))
                asyncio.async(recv_all(c, a))
                print("Next connection...")
        def recv_all(c, a):
            print("Receiving from: {}".format(a))
            while True:
                data = yield from loop.sock_recv(c, 1024)
                if not data:
                    break
                print(data.decode())
            c.close()
            print("Connection closed: {}".format(a))
        asyncio.async(accept_connections())
        loop.run_forever()

I've added 's.setblocking(0)' on the listening socket. Prior to asyncio, any
socket operations might throw exceptions if the operating system is not yet
ready to process them. We also need an instance of the event loop. This will
let us trampoline between the running tasks.

's.accept()' is replaced with the coroutine 'loop.sock_accept()' and
's.recv()' is replaced with 'loop.sock_recv()'.

"Yield from" lets us suspend executing code here, and jump to any other task
that can make progress, i.e. when receiving data from another connection, when
there is a new connection available. When the .accept() or .recv() would have
returned, execution is resumed.

Calling 'asyncio.async(coroutine())' is a construction seen from my previous
blog post. It returns immediately and schedules a coroutine to be executed in
the event loop. This is analogous to the "go" statement or the "&" shell
operator.

Finally, keep the event loop running. It can be stopped from any task by
calling 'loop.close()'. Something that this simple server is is not handling.
Ctrl+C still works to kill the service, but you should provision a way to
close client connections, otherwise the socket might end up in TIME_WAIT
state.

#### Conclusion

New super powers of concurrency. Can handle multiple connections
simultaneously, and we don't have to wait for the first one to finish (and
close) before processing the next. Try spawning up a few instances of netcat
to test the server.

    (while true;do sleep 1;echo a;done)|nc localhost 8888 &
    (while true;do sleep 1;echo b;done)|nc localhost 8888 &
    (while true;do sleep 1;echo c;done)|nc localhost 8888 &
    (while true;do sleep 1;echo d;done)|nc localhost 8888 &

Try it against the synchronous and asynchronous versions of the server.

