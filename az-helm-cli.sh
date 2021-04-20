#!/bin/bash

# az-helm-cli.sh
# This script contains all that's needed to, from a MacOS laptop, establish Docker, ACR, etc. to
# run a Helm v3 chart 
# which create resources in Azure to:
# ???
# Based on # https://docs.microsoft.com/en-us/azure/container-registry/container-registry-oci-artifacts
#    0. Define environment variables before invoking this script
#       MY_LOC, MY_RG, MY_ACR, --username $SP_APP_ID --password $SP_PASSWD, MY_ACR_REPO
#    1. Navigate/create container folder and download this repo into it
#    2. Install and start the Docker client if it's not already installed and started
#    3. Install and use CLI to log into Azure
#    4. Create your private ACR (Azure Container Registry)
#    5. Login into your ACR

#    6. Create a Dockerfile (instead of reference one pre-created).
#    7. Create a Docker container image from Dockerfile and images.
#   08. Tag Docker image:"
#   09. Install https://github.com/deislabs/oras to use the OCI Registry as Storage (ORAS) tool:">
#   10. Create a Service Principal with push rights.
#   11. Sign in ORAS

#   12. Install https://github.com/deislabs/oras to use the OCI Registry as Storage (ORAS) tool to
#   13. Use ORAS to push the new image into your ACR (Azure Container Registry), instead of DockerHub.
#   14. Remove the image tag from your local Docker environment.
#   15. List repos (artifacts) in ACR, to confirm:
#   16. List tags in ACR, to confirm:"
#   17. Get attributes of an artifact in ACR, to confirm.

#   18a. Run individual Docker image or "
#   18b. Reference Helm3 charts as OCI artifacts in the ACR (Azure Container Registry). 
#          The OCI (Open Container Initiative) Image Format Specs is at https://github.com/opencontainers/distribution-spec
#   19. Use ACR tasks to build and test container images.
#   20. Install Helm, get helm version.
#   21. Push change into Helm to trigger run which establishes services in Azure.
#   22. Validate automation.
#   23. Have Azure Defender Security Center scan images in ACR:"
#
# Authenticate with your registry using the helm registry login command.
# Use helm chart commands in the Helm CLI to push, pull, and manage Helm charts in a registry
# Use helm install to install charts to a Kubernetes cluster from a local repository cache.
#
# CAUTION: Delete the Azure Resource Group after this so they don't accumulate charges without your supervision.
# Adapted from https://docs.microsoft.com/en-us/azure/container-registry/container-registry-helm-repos

set -o errexit

echo ">>> 01. Create Resource Group"
az group create --name "${MY_RG}" --location "${MY_LOC}"

echo ">>> 01. Create/recreate container folder and download this repo into it:"
# TODO: WILSON:

echo ">>> 02. Install and start the Docker client if it's not already installed and started:"
# TODO: WILSON:

echo ">>> 03. Install and use CLI to log into Azure:"
az --version
# TODO: if not installed: install it
az login  # pops-up browser

echo ">>> 04. Create your private ACR (Azure Container Registry):"
# https://docs.microsoft.com/en-us/azure/container-registry/container-registry-get-started-azure-cli
# https://docs.microsoft.com/en-us/azure/container-registry/container-registry-tutorial-prepare-registry

# See https://docs.microsoft.com/en-us/cli/azure/acr?view=azure-cli-latest
RESPONSE=$( az acr check-name -n "${MY_ACR}" )
# if RESPONSE = exists:
   az acr create --sku Basic \
      --name "${MY_ACR}" \
      --resource-group "${MY_RG}"
# For more parms, see https://docs.microsoft.com/en-us/cli/azure/acr?view=azure-cli-latest


# TODO: In output, capture to $GEND_ACR_LOGIN_SERVER
  # "loginServer": "mycontainerregistry007.azurecr.io",
#fi

# Service Tier: see https://docs.microsoft.com/en-us/azure/container-registry/container-registry-skus#changing-tiers
# az acr update --name "${MY_ACR}" --sku Standard
         # or --sku Premium   
         # or --sku Standard  # for increased storage and image throughput
         # or --sku Basic     # for best cost savings

echo ">>> 05. Login into your ACR:"
az acr login --name "${MY_ACR}"

# echo "Here is an artifact" > artifact.txt

echo ">>> 06. Create a Dockerfile (instead of reference one pre-created):"
echo "FROM mcr.microsoft.com/hello-world" > hello-world.dockerfile

echo ">>> 07. Use a Dockerfile to create a Docker container image:"

echo ">>> 08. Tag Docker image:"
# TODO: docker tag mcr.microsoft.com/hello-world <login-server>/hello-world:v1

echo ">>> 09. Install https://github.com/deislabs/oras to use the OCI Registry as Storage (ORAS) tool:"

echo ">>> 10. Create a Service Principal with push rights:"
# TODO: 

echo ">>> 11. Sign in ORAS:"
oras login "${MY_ACR}".azurecr.io --username $SP_APP_ID --password $SP_PASSWD

echo ">>> 12. Install https://github.com/deislabs/oras to use the OCI Registry as Storage (ORAS) tool to"

echo ">>> 13. Use ORAS to push the new image into your ACR (Azure Container Registry), instead of DockerHub:">
# docker push <login-server>/hello-world:v1
oras push "${MY_ACR}".azurecr.io/samples/artifact:1.0 \
    --manifest-config /dev/null:application/vnd.unknown.config.v1+json \
    ./artifact.txt:application/vnd.unknown.layer.v1+txt
#
   # SAMPLE OUTPUT:
   # Uploading 33998889555f artifact.txt
   # Pushed myregistry.azurecr.io/samples/artifact:1.0
   # Digest: sha256:xxxxxxbc912ef63e69136f05f1078dbf8d00960a79ee73c210eb2a5f65xxxxxx

echo ">>> 14. Remove the image tag from your local Docker environment."
# (Note that this docker rmi command does not remove the image from the hello-world repository in your Azure container registry.)
docker rmi <login-server>/hello-world:v1

echo ">>> 15. List repos (artifacts) in ACR, to confirm:"
az acr repository list --name "${MY_ACR}" --output table

echo ">>> 16. List tags in ACR, to confirm:"
az acr repository show-tags --name "${MY_ACR}" --repository "${MY_ACR_REPO}" --output table

export registry="jasonacrr.azurecr.io"
export user="jasonacrr"
export password="t4AH+K86xxxxxxx2SMxxxxxzjNAMVOFb3c" 
export operation="/v2/aci-helloworld/tags/list" 
export credentials=$(echo -n "$user:$password" | base64 -w 0) 
export catalog=$(curl -s -H "Authorization: Basic $credentials" https://$registry$operation)
echo "Catalog"
echo $catalog


echo ">>> 17. Get attributes of an artifact in ACR, to confirm:"
az acr repository show \
    --name "${MY_ACR}" \
    --image samples/artifact:1.0.  # ???

echo ">>> 18a. Run individual Docker image or "
docker run <login-server>/hello-world:v1

echo ">>> 18b. Reference Helm3 charts as OCI artifacts in the ACR (Azure Container Registry):"
#          The OCI (Open Container Initiative) Image Format Specs is at https://github.com/opencontainers/distribution-spec"

echo ">>> 19. Use ACR tasks to build and test container images."
echo ">>> 20. Install Helm, get helm version."
echo ">>> 21. Push change into Helm to trigger run which establishes services in Azure."
echo ">>> 22. Validate automation."

echo ">>> 23. Have Azure Defender Security Center scan images in ACR:"
# https://docs.microsoft.com/en-us/azure/security-center/defender-for-container-registries-introduction?bc=/azure/container-registry/breadcrumb/toc.json&toc=/azure/container-registry/toc.json

echo ">>> 24. Clean up resource group, ACR, images, then list Resource Groups:"
az group delete --name "${MY_RG}"
az group list

