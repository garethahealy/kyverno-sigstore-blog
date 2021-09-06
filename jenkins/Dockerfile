FROM quay.io/redhat-cop/jenkins-agent-python:v1.0

USER root

## NOTE: If the router is using a self-signed, run: get-registry-cert.sh and uncomment the below
#COPY router-ca.pem /etc/pki/ca-trust/source/anchors/router-ca.pem
#COPY router-certs-default.pem /etc/pki/ca-trust/source/anchors/router-certs-default.pem
#RUN update-ca-trust force-enable && \
#    update-ca-trust extract

RUN dnf install --assumeyes --nodocs tar wget && \
    dnf clean all && \
    tar --version && \
    wget --version && \
    python3 --version && \
    git --version && \
    diff --version && \
    bc --version

RUN mkdir -p /tmpcmds
RUN export JQ_VERSION=1.6 && \
    wget --no-verbose --directory-prefix=/tmpcmds https://github.com/stedolan/jq/releases/download/jq-${JQ_VERSION}/jq-linux64 && \
    chmod +x /tmpcmds/jq-linux64 && \
    ln -s /tmpcmds/jq-linux64 /usr/local/bin/jq && \
    jq --version

RUN export HELM_VERSION=3.5.3 && \
    wget --no-verbose https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz && \
    tar -C /tmpcmds -xzf helm-v${HELM_VERSION}-linux-amd64.tar.gz && \
    ln -s /tmpcmds/linux-amd64/helm /usr/local/bin/helm && \
    helm version

RUN export OC_VERSION=4.7.0 && \
    wget --no-verbose https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${OC_VERSION}/openshift-client-linux.tar.gz && \
    tar -C /tmpcmds -xzf openshift-client-linux.tar.gz && \
    ln -s /tmpcmds/oc /usr/local/bin/oc && \
    ln -s /tmpcmds/kubectl /usr/local/bin/kubectl && \
    oc version && \
    kubectl version

RUN export COSIGN_VERSION=v1.1.0 && \
    wget --no-verbose --directory-prefix=/tmpcmds https://github.com/sigstore/cosign/releases/download/${COSIGN_VERSION}/cosign-linux-amd64 && \
    chmod +x /tmpcmds/cosign-linux-amd64 && \
    ln -s /tmpcmds/cosign-linux-amd64 /usr/local/bin/cosign && \
    cosign version

RUN pip3 install yq && \
    yq --version

USER 1001