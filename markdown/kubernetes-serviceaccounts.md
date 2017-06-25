If you are setting up your own kubernetes cluster, it is easy to miss configuration that allows your pods to access the apiserver. The documentation isn't too obvious about this feature and is not enabled by default.

## What is the default service account?

In kubernetes, resources can discover more about their environment by making REST requests to the cluster iteself. The apiserver component exposes a http endpoint to operators/users (authenticated by TLS certs) and the same API is available to pods/containers (authenticated by Bearer tokens).

The controller-manager service needs to be started with the `--service-account-private-key-file` and `--root-ca-file` flags. The apiserver service needs to be started with `--admission-control=...,ServiceAccount,..` and either point `--tls-private-key-file` at the same private key file or `--service-account-key-file` at the public (or private) key. Kubernetes allows you to use a different signing key for TLS connections and signing admission control tokens.

If you don't provide your own service account to your pods, kubernetes can inject a default credential which has read only access to the apiserver.

## Using the service account
From inside your pods, you can now send http requests to the cluster.

    import os
    import requests
    from requests_toolbelt.adapters import host_header_ssl

    # Verify the certificate using the cluster name of the apiserver
    session = requests.Session()
    session.mount('https://', host_header_ssl.HostHeaderSSLAdapter())

    host, port = os.getenv('KUBERNETES_SERVICE_HOST'), os.getenv('KUBERNETES_SERVICE_PORT')
    baseurl = f'https://{host}:{port}'

    # Read the bearer token signed by the controller-manager
    with open('/run/secrets/kubernetes.io/serviceaccount/token') as f:
        token = f.read()
    with open('/run/secrets/kubernetes.io/serviceaccount/namespace') as f:
        namespace = f.read()

    headers = {
        'Host': 'cluster.condi.me',
        'Authorization': f'Bearer {token}',
    }

    # CA for TLS verification is passed into the container by the controller manager
    capath = '/run/secrets/kubernetes.io/serviceaccount/ca.crt'

    def apicall(path):
        r = session.get(baseurl + path, headers=headers, verify=capath)
        return r.json()

    blog_endpoints = apicall(f'/api/v1/namespaces/{namespace}/endpoints/blog/')

    # do stuff
    [address['ip'] for address in blog_endpoints['subsets'][0]['addresses']]

You can now do pod/service discovery, without needing to setup DNS records or outsourcing to an external service.
