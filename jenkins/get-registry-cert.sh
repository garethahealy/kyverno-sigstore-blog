#!/usr/bin/env bash

oc get secrets/router-certs-default -n openshift-ingress -o jsonpath="{.data.tls\.crt}" | base64 -d > jenkins/router-certs-default.pem
oc get secrets/router-ca -n openshift-ingress-operator -o jsonpath="{.data.tls\.crt}" | base64 -d > jenkins/router-ca.pem

openssl x509 -in jenkins/router-certs-default.pem -text -noout
openssl x509 -in jenkins/router-ca.pem -text -noout

exec curl -vvv "https://$(oc get route/default-route -n openshift-image-registry -o jsonpath='{.status.ingress[0].host}')" --cacert jenkins/router-ca.pem