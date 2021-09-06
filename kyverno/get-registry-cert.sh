#!/usr/bin/env bash

oc get secrets/router-certs-default -n openshift-ingress -o jsonpath="{.data.tls\.crt}" | base64 -d > kyverno/router-certs-default.pem
oc get secrets/router-ca -n openshift-ingress-operator -o jsonpath="{.data.tls\.crt}" | base64 -d > kyverno/router-ca.pem

openssl x509 -in kyverno/router-certs-default.pem -text -noout
openssl x509 -in kyverno/router-ca.pem -text -noout

exec curl -vvv "https://$(oc get route/default-route -n openshift-image-registry -o jsonpath='{.status.ingress[0].host}')" --cacert kyverno/router-ca.pem