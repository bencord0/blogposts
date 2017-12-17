3 Missing Pieces

I'm still hesitant to jump into kubuernetes in production. Here are three blockers.

## Naked networking

I like the networking model, each pod has it's own IP.
I don't like the overlay networking, Service/Ingress hacks, and that proprietary load balancers are required in essentially all deployments. Proprietary, or roll-your-own nginx-controled-by-python-loop stuff.

This will be unblocked when I can write socket code that works whether or not I am inside the cluster.
```
import socket
s = socket.socket(socket.AF_INET6)  # See socket.create_connection for the AF agnostic client code
s.bind(("service", 0))
s.listen(5)
register_service_in_consul(s.getsockname())  # Or broadcast/multicast this to the network
c, a = s.accept()
```

## Deployment by branch

You can launch a Pod with a specific Docker container.
As of 1.9, you can (with a stable API) use a Deployment to upgrade containers from version X to version X+1.

However, to track a `master` branch, you still need a lot of glue code to shuttle your Docker build from CI, and update the Deployment.

[kube-metacontroller](https://github.com/GoogleCloudPlatform/kube-metacontroller) is an out of tree mechanism written by Anthony Yeh, who lead the 1.9 release team. This is a potential way that we could use to implement this style of deployment.

This will be unblocked when I can click the green merge button on GitHub, wait for CI, and have new code running in the cluster.

## RBAC defaults

Kubernetes, taken as a whole, is a powerful piece of modern sofware infrastructure.

Too powerful. So powerful that, to safely share kubernetes-as-a-service, cloud providers will give you an entire (read: isolated by the VM) cluster. As a cluster admin, this breaks any belief that multi-tenancy works at all.

This will be unblocked when I can provision a single kubernetes cluster, and give per-user credentials to teams (tens, not hundreds) who are deploying apps (hundreds, not millions) without stepping on each other's toes.

I'm not too worried about malicious intent or secret hiding, but a clear delineation between who is responsible for which Service, without worrying about the Pods that are behind it. I don't want to have to teach all engineers about how all of the cluster works. There's just too much to keep track of, let the computers do that.
Namespaces help, but "namespace admins" are no better a solution than "cluster admins".
