If you go potholing in the kubernetes releases, it isn't so bad. Here are my adventures trying to package, deploy and run containers on top of kubernetes (on Gentoo).

The classical method to install kubernetes is through their `curl|bash` scripts on get.k8s.io. I instead elected to read that script, and figure out what it's trying to do instead. Once you get past the distro/arch detection, the installer is simply unpacking a tarball of Golang binaries and moving them into the right place on your filesystem.

## Installation (via ebuilds)

I have encoded the necessary guts of the process into my personal [overlay](https://github.com/bencord0/portage-overlay/tree/master/sys-cluster/kubernetes). For me, it is a simple matter of `emerge kubernetes docker etcd flannel` (with the needed keywording) and boom. Onto the configuration.

## Configuration

But first a digression on networking.

I choose to install the networking using the simplest style to get my head around. Full MTU, no overlays and the IP in the container is the correct IP to use outside the container. Flannel should really just be called kube-netd, as it really is quite integrated into the kubernetes eco-system. I don't know of any other projects that are seriously considering using it. Especially since, with host-gw mode, you might as well dedicate a linux bridge on all of your hosts to a VLAN.

Fire up etcd, and confirm your network choices. 

    $ etcdctl set /coreos.com/network/config '{"Network": "10.0.0.0/16", "Backend": {"Type": "host-gw"}}'

Start up flanneld, and it will drop some environment variables into `/run/flannel`
To get docker to pick up a subnet within the specified range, adjust systemd's unit files with overrides accordingly.

    # /etc/systemd/system/docker.service.d/flannel.conf
    [Service]
    EnvironmentFile=-/run/flannel/docker
    # /etc/systemd/system/docker.service.d/override.conf
    [Service]
    ExecStart=
    ExecStart=/usr/bin/dockerd -H fd:// $DOCKER_NETWORK_OPTIONS

## Poor decision made in 2013 that we have to live with

Restart docker to pick up the new configuration (you may need a `systemctl daemon-reload` if not using `systemctl edit`).

    $ systemctl stop docker.service && systemctl start docker.socket

Run some docker containers via the docekr cli to test everything works as normal. You may notice that your containers have the `10.0.` prefix instead of the usual `172.17.` on the `docker0` bridge. That's good.

Once problem that I noticed when testing on a laptop is that flannel will get incredibly confused if you move between networks and your host's primary IP address changes. Specifically, if your host changes, the mapping stored in etcd/flanneld is royally screwed up since docker can only pick it's bridge IP on startup.

Take some time to poke around to see what flannel and docker have done to your routes and iptables. Things are going to get more interesting as we turn on more kubernetes binaries.

## The kubernetes services

    # /etc/systemd/system/kube-apiserver.service
    [Service]
    ExecStart=/usr/bin/kube-apiserver --etcd-servers=http://localhost:2379 --service-cluster-ip-range 10.0.0.0/16

    # /etc/systemd/system/kube-controller-manager.service
    [Service]
    ExecStart=/usr/bin/kube-controller-manager --master=http://localhost:8080

    # /etc/systemd/system/kube-proxy.service
    [Service]
    ExecStart=/usr/bin/kube-proxy --master=http://localhost:8080 --cluster-cidr=10.0.0.0/16

    # /etc/systemd/system/kube-scheduler.service
    [Service]
    ExecStart=/usr/bin/kube-scheduler --master=http://localhost:8080

    # /etc/systemd/system/kubelet.service
    [Service]
    ExecStart=/usr/bin/kubelet --pod-manifest-path=/etc/kubernetes/manifests --api-servers=http://localhost:8080

Yes, I'm just single hosting this deploy right now. I have to play around a bit before I decide to expand those `http://localhost` entries to `https://realdomains`. Fire them all up with the following command.

    $ systemctl start kube*.service

Monitor the cluster with this command.

    $ watch 'for i in svc ep deploy pods; do kubectl get $i; done'

And fire up your first container with.

    $ kubectl run webapp --image nginx
    $ kubectl expose deploy webapp --port 80

Which creates a kubernetes deployment named `nginx` using the `docker.io/library/nginx:latest` image. Then, assigns a service to the nginx deployment (a process known as exposing).

    $ kubectl get svc/nginx
    NAME      CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
    webapp     10.0.221.141   <none>        80/TCP    14s

Test it works with curl

    $ curl 10.0.221.141
    <!DOCTYPE html>
    <html>
    <head>
    <title>Welcome to nginx!</title>
    <style>
        body {
            width: 35em;
            margin: 0 auto;
            font-family: Tahoma, Verdana, Arial, sans-serif;
        }
    </style>
    </head>
    <body>
    <h1>Welcome to nginx!</h1>
    <p>If you see this page, the nginx web server is successfully installed and
    working. Further configuration is required.</p>

    <p>For online documentation and support please refer to
    <a href="http://nginx.org/">nginx.org</a>.<br/>
    Commercial support is available at
    <a href="http://nginx.com/">nginx.com</a>.</p>

    <p><em>Thank you for using nginx.</em></p>
    </body>
    </html>
    
## Exposing the outside world to Kubernetes
There's a lot more to kubernetes. You'll have to see their documentation for more information. I haven't even demonstrated how to drive the more declarative features with the `kubectl apply` command, or delved into service discovery so that kubernetes can instruct your containers how to talk to each other.

In the meantime, you can use that RFC1918 IP that `kubectl get svc` returns, and `proxy_pass` it with nginx on your host as a poor man's load balancer. 

        server {
            listen 80;
            location / {
                proxy_pass http://10.0.221.141;
            }
        }

Maybe a small python script can be useful to poll kubernetes's API `http://localhost:8080/api/v1/services`, generate an nginx config from a template and SIGHUP's the nginx process.

There is also another "hack" to expose host ports to kubernetes pods (but not the services) in this [gist](https://github.com/kubernetes/contrib/tree/master/for-demos/proxy-to-service) which explains the problem in more detail. Note that services are only routable from the host, they're created by iptables rules, whereas pods are real entities in your routing table established by flannel.

On GCE and AWS, kubernetes has integrations with their cloud load balancers, which will connect straight to the pods.

The ClusterIP is stickly for the life of the kubernetes service, independent of the kubernetes deployment which means that you can change the docker image, scale across nodes, inject environment variables and the kubernetes selector will handle the zero-downtime upgrade for you.

## Service discovery

I haven't written much about kube-dns here. It appears to be a continuation of skydns, a simple etcd->udp wrapper which translates kubernetes services into DNS entries. It has been wholly unreliable for me (see above note about dynamic IPs). I don't think that I will be using that, as I already have a BIND9 deployment and can script that perfectly fine.

Service discovery in kubernetes is about as mature as service discovery in other container managers. URLs to kubernetes services are injected into pods environment variables as `NAME_SERVICE_HOST` and `NAME_SERVICE_PORT` for all pods created after the service is created. All of which is useless, because service IPs are only available in the host namespace.

So it's best to 'kubectl apply' your services first, then the deployments. Feel free to add your own service discovery outside of this, either spin up consul or store TCP/IP addresses in a database. The nice thing about the kubernetes's network model is that `getsockname()` and `getpeername()` are no longer lying, and pods can connect to each other directly. Think of the service/cluster IP as just a NAT or floating-IP, and we'll all be fine.
