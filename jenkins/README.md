# Self-signed router certs
If the OCP router is using a self-signed cert, you'll need to include the router-ca.

Simply run:
- get-registry-cert.sh
- uncomment update-ca-trust in Dockerfile
- commit/push
- run build for: CosignBuildConfig.yaml