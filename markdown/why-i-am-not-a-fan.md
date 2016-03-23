[Flannel](https://github.com/coreos/flannel), [Weave](https://github.com/weaveworks/weave), [Pipework](https://github.com/jpetazzo/pipework), [libnetwork](https://github.com/docker/libnetwork), [docknet](https://github.com/helander/docknet) and now [The Fan](https://insights.ubuntu.com/2015/06/22/fan-networking/). Why are we so allergic to large address spaces?

When I first started playing with docker after the demo from pycon13 one piece was startling worrying to me. The default configuration requires that docker spawned containers attach themselves to the network via a host only, IPv4 NATed bridge device.

(By default) docker containers cannot communicate with other containers hosted on a different machine. Open a socket, and what address do you connect to? Docker containers behind a NAT mean that the IP address that you see does not correlate to anything that another machine can route to.

Listen on a socket, and what address do you bind to? You can't use a well-known-port because I should be able to run multiple instances of the same container (or versions thereof) they can't all bind to port 80 on the host.
Instead, docker has the PORT/EXPOSE abstraction which dynamically (at container startup time, which is hardly dynamic at all) maps a host external ephemeral port to the well port that nobody else can see.

Fundamentally, this prevents me from running a microservice based container ecosystem on distributed hosts.

The common answer is to run some kind of service discovery layer, and introduce some app-side code that can register it's location to the centralised service. Etcd, consul, kubernetes or even plain old DNS. You have to somehow discover or ask the docker api for what your own external IP/PORT mapping is because the traditional getsockname() is lying to you.

Another common paradigm is to use an overlay network. Sacrifice some bits in layer 4 and lie some more to your services by placing them in some fictitious  /8 network that, while it may be visible between hosts, is still non-routable to any external network. That is, your clients.

This is unacceptable.

The expectation when using OS level virtualization, containers, is that a traditional server host can now run hundreds, if not thousands, of distinct instances. Each one could be a standalone website that needs port 80 and a publicly routable address for clients to connect with. Yes, I know about TLS SNI and virtual hosting, but those are just address exhaustion mitigation techniques too. Even if you did use a dedicated load balancer or front end proxy, which address does that now need to connect to?

Clearly, the correct answer is to give each container instance it's own IP address, but the NAT solution (or 8-bitshift to the left in the case of The Fan) does not go anywhere to solve the true problem of uniquely addressable services.

In fact, I would argue that nothing in the IPv4 space solves this issue, especially for containers. There is however, a simple and elegant solution in IPv6.

Imagine, each time you 'docker run', the docker daemon allocates a new IPv6 address for your container based on the RA prefix (it could even do Duplicate Address Detection too). Under Linux, docker could drop you into a network namespace and attach a veth directly to the host's network, you don't even need a bridge device! It would howver be quite dangerous to start broadcasting for DHCP, the /24 in typical networks just isn't big enough for the kinds of scale and, for safety reasons, we should stop doing that.

What would this solve?

 * Containers get an address. A real address, and you can bind to any port.
 * Better performance and a larger MTU. No more NAT. No more overlay.
 * Meaningful addresses. getsockname() and getpeername() that an application can use directly, or report back to your coveted service discovery services.
 * I can have millions of containers, hosted on multiple hosts, all within the same L2 subnet (e.g. a few racks of a datacenter) that can talk to each other using normal networking.
 * I can have those containers distributed in other datacenters over L3, and the normal networking rules apply.
 * We could even extend this so that you aren't limited to EXPOSEing tcp or udp. Network protocol development just got easier.

What would this break?

 * Short IP addresses. Boo hoo, what is this? 1997?
 * Hosts that can't speak IPv6. Use a load balancer or other jump host (such as STUN/TURN for UDP), you would already need to be doing this anyway.
 * ???

An IPv6 address is a 128-bit naming scheme with collision detection already built in -- let's do more of those!
