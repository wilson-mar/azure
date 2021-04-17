#!/bin/bash

# az-aks-cli.sh
# This script was adapted from https://github.com/fouldsy/azure-mol-samples-2nd-ed/blob/master/19/azure_cli_sample.sh
# released under the MIT license. See https://github.com/fouldsy/azure-mol-samples-2nd-ed/blob/master/LICENSE
# and chapter 21 of the ebook "Learn Azure in a Month of Lunches - 2nd edition" (Manning Publications) by Iain Foulds,
# Purchase at https://www.manning.com/books/learn-azure-in-a-month-of-lunches-second-edition

# Create a Dockerfile:
cat <<EOF > Dockerfile
FROM nginx:1.17.5
EXPOSE 80:80
COPY index.html /usr/share/nginx/html
EOF

exit  # DURING DEBUGGING

# Create a resource group
az group create --name "${MY_RG}" --location "${MY_LOC}"

# Create an Azure Container Instance
# A public image from Dockerhub is used as the source image for the container,
# and a public IP address is assigned. To allow web traffic to reach the 
# container instance, port 80 is also opened
az container create \
    --name azuremol \
    --image iainfoulds/azuremol \
    --ip-address public \
    --ports 80 \
    --resource-group "${MY_RG}"

# Show the container instance public IP address
az container show \
    --name azuremol \
    --query ipAddress.ip \
    --output tsv \
    --resource-group "${MY_RG}"

# Create an Azure Container Service with Kubernetes (AKS) cluster
# Two nodes are created. 
az aks create \
  --name azuremol \
  --node-count 2 \
  --vm-set-type VirtualMachineScaleSets \
  --zones 1 2 3 \
    --resource-group "${MY_RG}"
# It can take ~10 minutes for this operation to successfully complete.

# Get the AKS credentials
# This gets the Kuebernetes connection information and applies to a local
# config file. You can then use native Kubernetes tools to connect to the
# cluster.
az aks get-credentials \
    --name azuremol \
    --resource-group "${MY_RG}"
    
# Install the kubectl CLI for managing the Kubernetes cluster
az aks install-cli

# Start an Kubernetes deployment
# This deployment uses the same base container image as the ACI instance in
# a previous example. Again, port 80 is opened to allow web traffic.
kubectl run azuremol \
    --generator=deployment/v1beta1 \
    --image=docker.io/iainfoulds/azuremol:latest \
    --port=80 \
    --generator=run-pod/v1

# Create a load balancer for Kubernetes deployment
# Although port 80 is open to the deployment, external traffic can't reach the
# Kubernetes pods that run the containers. A load balancer needs to be created
# that maps external traffic on port 80 to the pods. Although this is a
# Kubernetes command (kubectl) under the hood an Azure load balancer and rules
# are created
kubectl expose deployment/azuremol \
    --type="LoadBalancer" \
    --port 80
    
# View the public IP address of the load balancer
# It can take 2-3 minutes for the load balancer to be created and the public
# IP address associated to correctly direct traffic to the pod
kubectl get service

# Scale out the number of nodes in the AKS cluster
# The cluster is scaled up to 3 nodes
az aks scale \
    --name azuremol \
    --node-count 3 \
    --resource-group "${MY_RG}"

# Scale up the number of replicas
# When our web app container was deployed, only one instance was created. Scale
# up to 5 instances, distributed across all three nodes in the cluster
kubectl scale deployment azuremol --replicas 5

