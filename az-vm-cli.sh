#!/usr/bin/env bash

# This script is adapted from "Learn Azure in a Month of Lunches - 2nd edition" (Manning
# Publications) by Iain Foulds.
#
# This sample script covers the exercises from chapter 2 of the book. For more
# information and context to these commands, read a sample of the book and
# purchase at https://www.manning.com/books/learn-azure-in-a-month-of-lunches-second-edition
#
# This script sample is released under the MIT license. For more information,
# see https://github.com/fouldsy/azure-mol-samples-2nd-ed/blob/master/LICENSE

# Generate SSH keys
# SSH keys are used to securely authenticate with a Linux VM
# This is somewhat optional, as the Azure CLI can generate keys for you
ssh-keygen -t rsa -b 2048

# View the public part of your SSH key
# From the CLI, you don't really need this. But if you use the Azure portal or
# Resource Manager templates (which we look at in chapter 6), you need to
# provide this public key
cat .ssh/id_rsa.pub

# Create a resource group. This is a logical container to hold your resources.
# You can specify any name you wish, so long as it's unique with your Azure
# subscription and location
az group create --name "${MY_RG}" --location "${MY_LOC}"

# Create a Linux VM
# You specify the resoure group from the previous step, then provide a name.
# This VM uses Ubuntu LTS as the VM image, and creates a user name `azuremol`
# The `--generate-ssh-keys` checks for keys you may have created earlier. If
# SSH keys are found, they are used. Otherwise, they are created for you
az vm create \
    --name webvm \
    --image UbuntuLTS \
    --admin-username azuremol \
    --generate-ssh-keys \
    --resource-group "${MY_RG}"

# Obtain the public IP address of your VM. Enter the name of your resource
# group and VM if you changed them
publicIp=$(az vm show \
    --name webvm \
    --show-details \
    --query publicIps \
    --output tsv) \
    --resource-group "${MY_RG}"

# TODO: if publicIp is blank, stop

# SSH to your VM with the username and public IP address for your VM
ssh azuremol@$publicIp

# Once logged in to your VM, install the LAMP web stack with apt-get
sudo apt update && sudo apt install -y lamp-server^
logout

# Open port 80 to your webserver
az vm open-port --name webvm --port 80 --resource-group "${MY_RG}"

# Now you can access the basic website in your web browser
echo "To see your web server in action, enter the public IP address in to your web browser: http://$publicIp"
