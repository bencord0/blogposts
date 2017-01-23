This is a follow up to my previous post [Exploring Kubernetes](/exploring-kubernetes/). This time, I have expanded to a multi-node cluster. Here are a few notes and problems that I found along the way.

#### Enable containers to send packets off-host

and receive the reply back from the host.

    sysctl -w net.ipv4.conf.enp1s0.forwarding=1
    sysctl -w net.ipv4.conf.docker0.forwarding=1

It's not enough to set `net.ipv4.conf.all.forwarding`, the docker daemon creates it's own bridge, but doesn't enable packet forwarding correctly. This is slightly understandable, as the docker "solution" for this is to spawn a "docker-proxy" process that proxies packets from docker containers to be exposed in the host's network namespace.

    `Kubernetes approaches networking somewhat differently than Docker does by default.`
    
It says so right there in [the docs](https://kubernetes.io/docs/admin/networking/).

[Update] I tested this again after the recent release of docker-1.13 was released, and it's all working now.

Also note that forwarding packets from the docker internal brigde and the host's external bridge is not the same problem that is solved by [flannel](https://coreos.com/flannel/docs/latest/reservations.html). Flannel is the DHCP of subnets. How you route between the subnets is a different problem. I'm using host-gw mode, which is a simple loop to read values out of etcd to create static routes in the kernel.

In a more complex network, I would consider using hardware switches to create VLANs between my hosts. I don't think that the CoreOS team need to solve this problem.

Otherwise, assigning a v6 subnet (/72 maybe?) per docker node would also work, and not need any overlay at all.

#### Get Service discovery working

        kube-dns --kube-master-url http://localhost:8080
        dig <svc>.<ns>.svc.cluster.local.

Kube-dns is a MITM DNS resolver. (it mixes authorititave and forwarding) and I can't specify which upstream DNS kube-dns uses. It reads `/etc/resolv.conf` on startup, but doesn't handle any changes later on.

I need to check the code, but a better technique would be to run kube-dns standalone as the host's upstream resolver or specify which upstream dns server to use on the command line.

See below for my per-node nginx config, which uses kube-dns instead of the system's resolver to find service endpoints. Pods inside kubernetes use nginx (by setting the `Host` header) to talk to other services without needing to parse the kubernetes api themselves.

#### Get Host discovery working
All `kube-apiserver`s need DNS and TCP visibility to all `kubelet`s to proxy for commands such as `kubectl exec`.

        docker container -> kubelet -> kube-apiserver -> [proxy/lb] -> kubectl

This is completely orthogonal to the service discovery solved by kube-dns.

The problem is when an apiserver on host A tries to attach to a container on host B. The apiserver creates a TCP connection to host B using the node's `name` (or maybe it's `kubernetes.io/hostname` or the node's `addresss` of type `Hostname`), I'm not sure.

In any case, you'll have to make sure that hostnames are configured outside of kubernetes correctly. I tried calling everything `localhost`, it didn't like that. Dropping some entries into `/etc/hosts` will work, but I already have an internal DNS solution, and this makes me sad.

#### Ingress is complicated

unnecessarily complicated.

Right now, I cannot recommend using kubernetes in an environment that is not controled by [Google](https://cloud.google.com/). Once you get a cluster running, and you get apps running on the cluster, *and* you get deployments/replication controllers/services to expose your application as a single, load balanced (virtual) service IP. You still can't use it from outside of the kubernetes cluster.

The `--type=LoadBalancer` setting for exposing services is literally meaningless outside of a hosted environment. It works on GCE/GKE and the AWS hacks work too. Trying this anywhere else will need a custom integration.

Ingress is a [mess](https://github.com/kubernetes/contrib/tree/master/ingress/controllers).

Exposing a service externally (aka. "running containers in production"), requires layers of helper containers to forward packets to each other, deciding what service the request is for, which endpoints make up that service and then hopping to the containers that serve the request. The only consolation is that they don't use a NAT (oh wait, services are NATs. nevermind.)

In the end, I created some manual mappings between externally visible FQDNs (and their Let's Encrypt certificate), and this nifty nginx config running on each node.

    server {
            server_name ~^(?<appname>\w+).cluster.condi.me$;

            location / {
                    resolver 127.0.0.1;
                    set $backend $appname.default.svc.cluster.local;
                    proxy_pass http://$backend;
            }
    }
