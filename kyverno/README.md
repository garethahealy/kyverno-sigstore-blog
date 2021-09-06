# Self-signed router certs
If the OCP router is using a self-signed cert, you'll need to extend the kyverno base image to include the router-ca.

Simply run:
- get-registry-cert.sh
- build.sh