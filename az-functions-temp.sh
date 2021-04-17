#!/usr/bin/env bash

# az-functions-temp.sh
# This script was adapted from https://github.com/fouldsy/azure-mol-samples-2nd-ed/blob/master/21/azure_cli_sample.sh
# released under the MIT license. See https://github.com/fouldsy/azure-mol-samples-2nd-ed/blob/master/LICENSE
# and chapter 21 of the ebook "Learn Azure in a Month of Lunches - 2nd edition" (Manning Publications) by Iain Foulds,
# Purchase at https://www.manning.com/books/learn-azure-in-a-month-of-lunches-second-edition
#
# There are quite a few components here that aren't available in the Azure CLI
# The complete examples from chapter 21 fill in the gaps with the use of the
# Azure portal.
# As such, this is not a complete example script that provides a functional end
# result at the end of the script.

# Create a resource group
az group create --name "${MY_RG}" --location "${MY_LOC}"

# Define a unique name for the Service Bus namespace
serviceBusNamespace=azuremol$RANDOM

# Create a Service Bus namespace
# This namespace is used to then create a queue that allows messages to be
# transmitted between your Azure IoT Hub and applications such as Logic Apps
# and Function Apps
az servicebus namespace create --resource-group azuremolchapter21 --name $serviceBusNamespace

# Create a Service Bus queue
# This queue is used to connect Azure IoT Hub with your serverless applications
# to pass messages back and forth
az servicebus queue create \
    --namespace-name $serviceBusNamespace \
    --name azuremol \
    --resource-group "${MY_RG}"
    
# Define a unique name for the Storage account
storageAccount=mystorageaccount$RANDOM

# Create an Azure Storage account
# The Function App requires a Storage account
az storage account create \
   --resource-group azuremolchapter21 \
   --name $storageAccount \
   --sku standard_lrs \
   --resource-group "${MY_RG}"
    
# Define a unique name for the Function App
functionAppName=azuremol$RANDOM

# Create a Function App
# A consumption plan is used, which means you are only charged based on the
# memory usage while your app is running. The Function App is set up to be
# manually connected to a sample app in GitHub
az functionapp create \
    --name $functionAppName \
    --storage-account $storageAccount \
    --consumption-plan-location eastus \
    --deployment-source-url https://raw.githubusercontent.com/fouldsy/azure-mol-samples/master/21/analyzeTemperature.js \
    --resource-group "${MY_RG}"
    
