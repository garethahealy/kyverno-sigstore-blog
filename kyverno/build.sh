#!/usr/bin/env bash

if [[ -z "${GHCR_TOKEN}" ]]; then
    echo "GHCR_TOKEN is empty. Exiting."
    exit 1
fi

if [[ -z "${GHCR_USERNAME}" ]]; then
    echo "GHCR_USERNAME is empty. Exiting."
    exit 1
fi

echo "${GHCR_TOKEN}" | docker login ghcr.io --username ${GHCR_USERNAME} --password-stdin

echo ""
echo "Building new kyverno image with certs included..."

podman build . -t kyverno:latest
podman tag kyverno:latest ghcr.io/${GHCR_USERNAME}/kyverno:v1.4.2
podman push ghcr.io/${GHCR_USERNAME}/kyverno:v1.4.2

oc patch Deployment/kyverno --type json -p='[{"op":"replace","path":"/spec/template/spec/containers/0/image","value":"ghcr.io/'$GHCR_USERNAME'/kyverno:v1.4.2"}]' -n kyverno

echo ""
echo "Waiting for kyverno to be ready..."
oc rollout status Deployment/kyverno -n kyverno --watch=true
