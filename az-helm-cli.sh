#!/bin/bash

# az-helm-cli.sh
# This script contains all that's needed to, from a MacOS laptop, establish Docker, ACR, etc. to
# run a Helm v3 chart 
# which create resources in Azure to:
# ???
# Based on # https://docs.microsoft.com/en-us/azure/container-registry/container-registry-oci-artifacts
#    0. Manually define environment variables:
#       MY_RG, MY_ACR, --username $SP_APP_ID --password $SP_PASSWD
#    1. Navigate/create container folder and download this repo into it
#    2. Install and start the Docker client if it's not already installed and started
#    3. Install and use CLI to log into Azure
#    4. Create your private ACR (Azure Container Registry)
#    5. Login into your ACR

#    6. Create a Dockerfile (instead of reference one pre-created).
#    7. Create a Docker container image from Dockerfile and images.
#    8. Install https://github.com/deislabs/oras to use the OCI Registry as Storage (ORAS) tool:">
#    9. Create a Service Principal with push rights.
#   10. Sign in ORAS

#   11. Install https://github.com/deislabs/oras to use the OCI Registry as Storage (ORAS) tool to
#   12. Use ORAS to push the new image into your ACR (Azure Container Registry), instead of DockerHub.
#   13. Get attributes of an artifact in ACR, to confirm.

#   14. Reference Helm3 charts as OCI artifacts in the ACR (Azure Container Registry). 
#          The OCI (Open Container Initiative) Image Format Specs is at https://github.com/opencontainers/distribution-spec
#   15. Use ACR tasks to build and test container images.
#   16. Install Helm, get helm version.
#   17. Push change into Helm to trigger.
#   18. Validate automation.
#
# Authenticate with your registry using the helm registry login command.
# Use helm chart commands in the Helm CLI to push, pull, and manage Helm charts in a registry
# Use helm install to install charts to a Kubernetes cluster from a local repository cache.
#
# CAUTION: Delete the Azure Resource Group after this so they don't accumulate charges without your supervision.
# Adapted from https://docs.microsoft.com/en-us/azure/container-registry/container-registry-helm-repos

set -o errexit

echo ">>> 1. Create/recreate container folder and download this repo into it:"

echo ">>> 2. Install and start the Docker client if it's not already installed and started:"

echo ">>> 3. Install and use CLI to log into Azure:"
az login

echo ">>> 4. Create your private ACR (Azure Container Registry):"

echo ">>> 5. Login into your ACR:"
az acr login --name "${MY_ACR}"

# echo "Here is an artifact" > artifact.txt

echo ">>> 6. Create a Dockerfile (instead of reference one pre-created):"
echo "FROM mcr.microsoft.com/hello-world" > hello-world.dockerfile

echo ">>> 7. Use a Dockerfile to create a Docker container image:"

echo ">>> 8. Install https://github.com/deislabs/oras to use the OCI Registry as Storage (ORAS) tool:"

echo ">>> 9. Create a Service Principal with push rights:"

echo ">>> 10. Sign in ORAS:"
oras login myregistry.azurecr.io --username $SP_APP_ID --password $SP_PASSWD

echo ">>> 10. Use ORAS to push the new image into your ACR (Azure Container Registry), instead of DockerHub:">
oras push myregistry.azurecr.io/samples/artifact:1.0 \
    --manifest-config /dev/null:application/vnd.unknown.config.v1+json \
    ./artifact.txt:application/vnd.unknown.layer.v1+txt
#
   # SAMPLE OUTPUT:
   # Uploading 33998889555f artifact.txt
   # Pushed myregistry.azurecr.io/samples/artifact:1.0
   # Digest: sha256:xxxxxxbc912ef63e69136f05f1078dbf8d00960a79ee73c210eb2a5f65xxxxxx

echo ">>> 10. Get attributes of an artifact in ACR:"
az acr repository show \
    --name "${MY_ACR}" \
    --image samples/artifact:1.0.  # ???

echo ">>> xx. Have Azure Defender Security Center scan images in ACR:"
# https://docs.microsoft.com/en-us/azure/security-center/defender-for-container-registries-introduction?bc=/azure/container-registry/breadcrumb/toc.json&toc=/azure/container-registry/toc.json

