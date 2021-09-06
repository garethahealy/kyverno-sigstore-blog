#!/usr/bin/env bash

command -v oc &> /dev/null || { echo >&2 'ERROR: oc not installed - Aborting'; exit 1; }
command -v helm &> /dev/null || { echo >&2 'ERROR: helm not installed - Aborting'; exit 1; }

# Two versions of yq exist, check its the correct one
[[ $(yq --help | grep -c "jq wrapper") -eq 1 ]] || { echo >&2 'ERROR: found yq installed but not the jq wrapper version (https://github.com/kislyuk/yq) - Aborting'; exit 1; }

deploy_kyverno() {
  echo ""
  echo "Collecting control-plane related namespaces..."

  excludedNamespaces=()
  for namespace in $(oc get namespaces -o jsonpath='{.items[*].metadata.name}' | xargs); do
    if [[ "${namespace}" =~ openshift.* ]] || [[ "${namespace}" =~ kube.* ]] || [[ "${namespace}" =~ default ]]; then
      excludedNamespaces+=("[*,${namespace},*]")
    fi
  done

  local excludedNamespacesList
  excludedNamespacesList=$(echo "${excludedNamespaces[@]}" | tr -d "[:space:]")

  local defaultResourceFilters="[Event,*,*][Node,*,*][APIService,*,*][TokenReview,*,*][SubjectAccessReview,*,*][SelfSubjectAccessReview,*,*][Binding,*,*][ReplicaSet,*,*][ReportChangeRequest,*,*][ClusterReportChangeRequest,*,*][*,kyverno,*]"
  local resourceFilters=$(echo "${defaultResourceFilters}${excludedNamespacesList}" | sed 's/,/\\,/g')

  echo ""
  echo "Deploying kyverno..."
  helm repo add kyverno https://kyverno.github.io/kyverno
  helm repo update

  helm install kyverno kyverno/kyverno --namespace kyverno --create-namespace --set=replicaCount=3,podSecurityStandard=custom,config.resourceFilters="$resourceFilters"

  echo ""
  echo "Waiting for kyverno to be ready..."
  oc rollout status Deployment/kyverno -n kyverno --watch=true
}

deploy_policy() {
  echo ""
  echo "Deploying policies..."

  if [[ ! -f cosign.pub ]]; then
      echo "cosign.pub file not found. Exiting."
      exit 1
  fi

  # shellcheck disable=SC2038
  for file in $(find policy/* -name "src.yaml" -type f | xargs); do
    # HACK: Must be a nicer way to add pub to key
    yq --yaml-output --in-place --rawfile pubkey cosign.pub '.spec.rules[].verifyImages[].key |= $pubkey' ${file}
    sed -i "/^$/d;s/key: */key: |-\n            /;s/'//" ${file}

    name=$(oc create -f "${file}" -n kyverno -o name || exit $?)
    echo "${name}"
  done
}

# Process arguments
case $1 in
  deploy_kyverno)
    deploy_kyverno
    ;;
  deploy_policy)
    deploy_policy
    ;;
  *)
    echo "Not an option"
    exit 1
esac
