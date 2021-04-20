#!/bin/bash

# az-helm-cli.sh
# This script contains all that's needed to, from a MacOS laptop, establish Docker, ACR, etc. to
# run a Helm v3 chart 
# which create resources in Azure to:
# ???
# Based on # https://docs.microsoft.com/en-us/azure/container-registry/container-registry-oci-artifacts
#   00. Define environment variables before invoking this script
#       MY_GIT_CONTAINER, MY_REPO, MY_LOC, MY_RG, MY_ACR, --username $SP_APP_ID --password $SP_PASSWD, MY_ACR_REPO
#   01. Navigate/create container folder and download this repo into it
#       After you obtain a Terminal (console) in your environment,
#       cd to folder, copy this line and paste in the terminal:
#       bash -c "$(curl -fsSL https://raw.githubusercontent.com/wilson-mar/$MY_REPO/master/az-helm-cli.sh)" -v -i

#   02. Install and start the Docker client if it's not already installed and started
#   03. Install and use CLI to log into Azure
#   04. Log into Azure

#   05. Create Azure Resource Group"
#   06. Create your private ACR (Azure Container Registry)
#   07. Login into your ACR

#   08. Create a Dockerfile (instead of reference one pre-created).
#   09. Create a Docker container image from Dockerfile and images.
#   10. Tag Docker image:"
#   11. Install https://github.com/deislabs/oras to use the OCI Registry as Storage (ORAS) tool:">
#   12. Create a Service Principal with push rights.
#   13. Sign in ORAS
#   14. Use ORAS to push the new image into your ACR (Azure Container Registry), instead of DockerHub.
#   15. Remove the image tag from your local Docker environment.
#   16. List repos (artifacts) in ACR, to confirm:
#   17. List tags in ACR, to confirm:"
#   18. Get attributes of an artifact in ACR, to confirm.

#   19. Have Azure Defender Security Center scan images in ACR:"

#   20a. Run individual Docker image or "
#   20b. Reference Helm3 charts as OCI artifacts in the ACR (Azure Container Registry). 
#          The OCI (Open Container Initiative) Image Format Specs is at https://github.com/opencontainers/distribution-spec
#   21. Use ACR tasks to build and test container images.
#   22. Install Helm, get helm version.
#   23. Push change into Helm to trigger run which establishes services in Azure.
#   24. Validate automation.
#   25. List resource group:"
#   26. List resources under resource group:"
#   27. Clean up resource group, ACR, images:"
        # Delete the Azure Resource Group after this so they don't accumulate charges without your supervision.
#
# Authenticate with your registry using the helm registry login command.
# Use helm chart commands in the Helm CLI to push, pull, and manage Helm charts in a registry
# Use helm install to install charts to a Kubernetes cluster from a local repository cache.
#
# Adapted from https://docs.microsoft.com/en-us/azure/container-registry/container-registry-helm-repos
# and https://gaunacode.com/publishing-helm-3-charts-to-azure-container-registry-using-azure-devops-part-1

set -o errexit

echo ">>> 01. Create/recreate container folder and download this repo into it:"
echo "MY_SCRIPT_VERSION=$MY_SCRIPT_VERSION"
# TODO: WILSON:

echo ">>> 02. Install and start the Docker client if it's not already installed and started:"
cd
if [ !   -d "${MY_GIT_CONTAINER}" ]; then  # folder not found, so make it:
   mkdir -p "${MY_GIT_CONTAINER}"    # in Cloud Shell ?
fi
         cd "${MY_GIT_CONTAINER}"
if [   -d "${MY_REPO}" ]; then  # folder found, so remove it:
   # TODO: Assume delete previous version of GitHub:
   rm -rf "${MY_REPO}"
fi
git clone https://github.com/wilson-mar/"${MY_REPO}".git --depth 1 
cd "${MY_REPO}"
ls
chmod +x *.sh   # make shell files executable.

echo ">>> 03. Install CLI to log into Azure:"
# TODO: if not installed: install it
az --version  # 2.22.0 and extensions

echo ">>> 04. Use az login # to Azure:"
# See https://docs.microsoft.com/en-us/cli/azure/ad/signed-in-user?view=azure-cli-latest
az login  # pops-up browser
      # Cloud Shell is automatically authenticated under the initial account signed-in with. Run 'az login' only if you need to use a different account
      # To sign in, use a web browser to open the page https://microsoft.com/devicelogin and enter the code RTGDJB9TN to authenticate.
RESPONSE=$( az ad signed-in-user show --query "accountEnabled" -o json )
if [[ "$RESPONSE" != *"true"* ]]; then  # TODO: state": "Enabled", userPrincipalName
   echo ">>> RESPONSE after az login not Enabled"
   abort
fi

echo ">>> 05. Create Resource Group:"
az group create --name "${MY_RG}" --location "${MY_LOC}"
   #    "provisioningState": "Succeeded"

echo ">>> 06. Create your private ACR (Azure Container Registry):"
# https://docs.microsoft.com/en-us/azure/container-registry/container-registry-get-started-azure-cli
# https://docs.microsoft.com/en-us/azure/container-registry/container-registry-tutorial-prepare-registry

# See https://docs.microsoft.com/en-us/cli/azure/acr?view=azure-cli-latest
RESPONSE=$( az acr check-name -n "${MY_ACR}" )
# if RESPONSE = exists:
   # fall thru
# "message": null,  # not created.
# if "nameAvailable": false   # abort to pick another ACR name.
# true,
   az acr create --sku Basic \
      --name "${MY_ACR}" \
      --resource-group "${MY_RG}"
# For more parms, see https://docs.microsoft.com/en-us/cli/azure/acr?view=azure-cli-latest

# TODO: In output, capture to $GEND_ACR_LOGIN_SERVER
  # "loginServer": "litthouse.azurecr.io",
#fi

# Service Tier: see https://docs.microsoft.com/en-us/azure/container-registry/container-registry-skus#changing-tiers
# az acr update --name "${MY_ACR}" --sku Standard
         # or --sku Premium   
         # or --sku Standard  # for increased storage and image throughput
         # or --sku Basic     # for best cost savings

echo ">>> 07. Login into your ACR:"
# If running Docker:
   # az acr login --name "${MY_ACR}"
# If running Cloud Shell, get an access token, which does not require Docker to be installed:
   RESPONSE=$( az acr login -n "${MY_ACR}" --expose-token )
   echo "$RESPONSE" | head -c 70   # first 70 characters of variable
   echo "\n"
   
echo ">>> 08. Create a Dockerfile (instead of reference one pre-created):"
# echo "FROM mcr.microsoft.com/hello-world" > hello-world.dockerfile # ???

echo ">>> 09. Use a Dockerfile to create a Docker container image:"


echo ">>> 10. Tag Docker image:"
# TODO: docker tag mcr.microsoft.com/hello-world <login-server>/hello-world:v1

echo ">>> 11. Install in ${MY_GIT_CONTAINER}/${MY_REPO} the OCI Registry as Storage (ORAS) tool:"
# On MacOS:
cd
cd "${MY_GIT_CONTAINER}"/"${MY_REPO}"  # use github repo.
pwd

   curl -LO https://github.com/deislabs/oras/releases/download/v0.11.1/oras_0.11.1_darwin_amd64.tar.gz
   tar -zxf oras_0.11.1_*.tar.gz      # unzip
   rm -rf oras_0.11.1_*.tar.gz
   ls -al oras
   chmod +x oras

if ! command -v oras; then  # not installed, so:
   echo "oras not found after install!"
   abort
fi

echo ">>> 12. Create a Service Principal with push rights:"
# TODO: 

echo ">>> 13. Sign in ORAS:"
oras login "${MY_ACR}".azurecr.io --username $SP_APP_ID --password $SP_PASSWD

echo ">>> 14. Use ORAS to push the new image into your ACR (Azure Container Registry), instead of DockerHub:">
# docker push <login-server>/hello-world:v1
oras push "${MY_ACR}".azurecr.io/samples/artifact:1.0 \
    --manifest-config /dev/null:application/vnd.unknown.config.v1+json \
    ./artifact.txt:application/vnd.unknown.layer.v1+txt
#
   # SAMPLE OUTPUT:
   # Uploading 33998889555f artifact.txt
   # Pushed myregistry.azurecr.io/samples/artifact:1.0
   # Digest: sha256:xxxxxxbc912ef63e69136f05f1078dbf8d00960a79ee73c210eb2a5f65xxxxxx

echo ">>> 15. Remove the image tag from your local Docker environment."
# (Note that this docker rmi command does not remove the image from the hello-world repository in your Azure container registry.)
docker rmi <login-server>/hello-world:v1

echo ">>> 16. List repos (artifacts) in ACR, to confirm:"
az acr repository list --name "${MY_ACR}" --output table

echo ">>> 17. List tags in ACR, to confirm:"
az acr repository show-tags --name "${MY_ACR}" --repository "${MY_ACR_REPO}" --output table

export registry="jasonacrr.azurecr.io"
export user="jasonacrr"
export password="t4AH+K86xxxxxxx2SMxxxxxzjNAMVOFb3c" 
export operation="/v2/aci-helloworld/tags/list" 
export credentials=$(echo -n "$user:$password" | base64 -w 0) 
export catalog=$(curl -s -H "Authorization: Basic $credentials" https://$registry$operation)
echo "Catalog"
echo $catalog


echo ">>> 18. Get attributes of an artifact in ACR, to confirm:"
az acr repository show \
    --name "${MY_ACR}" \
    --image samples/artifact:1.0.  # ???

echo ">>> 19. Have Azure Defender Security Center scan images in ACR:"
# https://docs.microsoft.com/en-us/azure/security-center/defender-for-container-registries-introduction?bc=/azure/container-registry/breadcrumb/toc.json&toc=/azure/container-registry/toc.json

echo ">>> 20a. Run individual Docker image or "
docker run <login-server>/hello-world:v1

echo ">>> 20b. Reference Helm3 charts as OCI artifacts in the ACR (Azure Container Registry):"
#          The OCI (Open Container Initiative) Image Format Specs is at https://github.com/opencontainers/distribution-spec"
# https://docs.fluxcd.io/projects/helm-operator/en/1.0.0-rc9/references/helmrelease-custom-resource.html

echo ">>> 21. Use ACR tasks to build and test container images."

echo ">>> 22. Install Helm, get helm version."

echo ">>> 23. Push change into Helm to trigger run which establishes services in Azure."

echo ">>> 24. Validate automation."

echo ">>> 25. List resource group:"
az group list -o table
   # Ignore "cloud-shell-storage-westus" and "NetworkWatcherRG"

echo ">>> 26. List resources under resource group:"
az resource list --resource group "${MY_RG}" --location "${MY_LOC}"
   # Alternative: a. Install Python environment
   # python --version
   # Install b. In requirements.txt azure-mgmt-resource>=1.15.0 & azure-identity>=1.5.0
   # pip install -r requirements.txt
   # Bring in code from https://docs.microsoft.com/en-us/azure/developer/python/azure-sdk-example-list-resource-groups 
      # to 3b. List resources within a specific resource group
   # Authenticate Python apps with Azure services: https://docs.microsoft.com/en-us/azure/developer/python/azure-sdk-authenticate
   # Run: python list_resources.py "${MY_RG}"
   
   # https://vincentlauzon.com/2016/01/21/listing-resources-under-resource-group-with-azure-powershell/
   
echo ">>> 27. Clean up resource group, ACR, images, then list Resource Groups:"
az group delete --name "${MY_RG}"

