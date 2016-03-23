I can't believe that I haven't posted about this before, and I google around
for it every time.

So here it is.

# Prerequisites

#### Access to a certificate authority

Do it properly and don't make your own CA. Use a public CA, or your company's
internal CA. I reccommend [StartSSL](http://www.startssl.org/) or
[CACert](http://www.cacert.org/).

#### OpenSSL

Any linux box will do, windows binaries are availble if you really need to.

#### An email account

Typically, the CA will email you the final certificate, or offer a webportal
to download it.

### Security considerations

Don't send your secret key to the CA and don't get the CA to generate the key
for you.

Generate the secret key and csr on the server, don't send it around the
network. If possible, don't even print the key to the screen. If you misplace
it, or the key is compromised just generate a new key.

# The commands you need to generate an SSL certificate

Generate a secret key (encrypt it if you want to, but that isn't necessary
unless you are moving the key around)

    openssl genrsa 4096 > server.key

Generate a certificate request

    openssl req -new -key server.key > server.csr

Answer the questions, probably, only the CN is important. Send the .csr to the
CA

CA will reply with a .crt or .pem that you can give to your application.