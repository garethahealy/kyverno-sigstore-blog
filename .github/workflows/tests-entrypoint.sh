#!/usr/bin/env bash

if [[ -z "${GHCR_USERNAME}" ]]; then
    echo "GHCR_USERNAME is empty. Exiting."
    exit 1
fi

if [[ -z "${GHCR_TOKEN}" ]]; then
    echo "GHCR_TOKEN is empty. Exiting."
    exit 1
fi

if [[ -z "${REGISTRY_URL}" ]]; then
    echo "REGISTRY_URL is empty. Exiting."
    exit 1
fi

kubectl cluster-info || return $?

echo ""
echo "Updating registry references..."
yq --yaml-output --in-place --arg GHCR_USERNAME "${GHCR_USERNAME}" --arg REGISTRY_URL "${REGISTRY_URL}" '.items[0].spec.template.spec.containers[0].image |= ($REGISTRY_URL + "/" + $GHCR_USERNAME + "/kyverno-signed:latest")' policy/check-image/test_data/unit/accept.yml
yq --yaml-output --in-place --arg GHCR_USERNAME "${GHCR_USERNAME}" --arg REGISTRY_URL "${REGISTRY_URL}" '.items[0].spec.template.spec.containers[0].image |= ($REGISTRY_URL + "/" + $GHCR_USERNAME + "/kyverno-unsigned:latest")' policy/check-image/test_data/unit/reject.yml
yq --yaml-output --in-place --arg GHCR_USERNAME "${GHCR_USERNAME}" --arg REGISTRY_URL "${REGISTRY_URL}" '.spec.rules[].verifyImages[0].image |= ($REGISTRY_URL + "/" + $GHCR_USERNAME + "/kyverno-signed:latest")' policy/check-image/src.yaml
yq --yaml-output --in-place --arg GHCR_USERNAME "${GHCR_USERNAME}" --arg REGISTRY_URL "${REGISTRY_URL}" '.spec.rules[].verifyImages[1].image |= ($REGISTRY_URL + "/" + $GHCR_USERNAME + "/kyverno-unsigned:latest")' policy/check-image/src.yaml

echo ""
echo "Installing..."
test/deploy-kyverno.sh deploy_kyverno
test/deploy-kyverno.sh deploy_policy

# Currently, no way to know if a policy has been accepted by the controller.
# Future: https://docs.google.com/document/d/1Y7_7ow4DgCLyCFQcFVz1vHclghazAKZyolIfprtNURc/edit#heading=h.zcvgnccy18ar
sleep 10s

echo ""
echo "Starting tests..."
bats test/kyverno-unittests.sh
exec bats test/kyverno-integrationtests.sh