#!/usr/bin/env bash

command -v podman &> /dev/null || { echo >&2 'ERROR: podman not installed (See: https://marcusnoble.co.uk/2021-09-01-migrating-from-docker-to-podman) - Aborting.'; exit 1; }
command -v cosign &> /dev/null || { echo >&2 'ERROR: cosign not installed - Aborting.'; exit 1; }

if [[ -z "${GHCR_TOKEN}" ]]; then
    echo "GHCR_TOKEN is empty. Exiting."
    exit 1
fi

if [[ -z "${GHCR_USERNAME}" ]]; then
    echo "GHCR_USERNAME is empty. Exiting."
    exit 1
fi

if [[ -z "${REGISTRY_URL}" ]]; then
    echo "REGISTRY_URL is empty. Exiting."
    exit 1
fi

echo ""
echo "Authing to ${REGISTRY_URL}..."
echo "${GHCR_TOKEN}" | docker login ${REGISTRY_URL} --username ${GHCR_USERNAME} --password-stdin
podman login ${REGISTRY_URL}

echo ""
echo "About to start building the image..."
podman build policy/check-image/test_data/unit/signed --tag kyverno-signed:latest
podman build policy/check-image/test_data/unit/unsigned --tag kyverno-unsigned:latest

echo ""
echo "About to publish the image to ${REGISTRY_URL}..."
podman tag localhost/kyverno-signed:latest ${REGISTRY_URL}/${GHCR_USERNAME}/kyverno-signed:latest
podman tag localhost/kyverno-unsigned:latest ${REGISTRY_URL}/${GHCR_USERNAME}/kyverno-unsigned:latest
podman push ${REGISTRY_URL}/${GHCR_USERNAME}/kyverno-signed:latest
podman push ${REGISTRY_URL}/${GHCR_USERNAME}/kyverno-unsigned:latest

oc process --local -f test/resources/namespace-under-test.yml -p=PROJECT_NAME=kyverno-verifyimages-blog | oc create -f -

echo ""
echo "Running cosign..."
export COSIGN_PASSWORD=secretsquirrel
cosign generate-key-pair k8s://kyverno-verifyimages-blog/cosign
cosign sign -key k8s://kyverno-verifyimages-blog/cosign ${REGISTRY_URL}/${GHCR_USERNAME}/kyverno-signed:latest