FROM ghcr.io/kyverno/kyverno:v1.4.2
# https://github.com/kyverno/kyverno/blob/main/cmd/kyverno/Dockerfile

## NOTE: If the router is using a self-signed, run: get-registry-cert.sh and uncomment the below
COPY router-ca.pem /etc/ssl/certs/router-ca.pem
COPY router-certs-default.pem /etc/ssl/certs/router-certs-default.pem

