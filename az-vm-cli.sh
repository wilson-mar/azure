#!/usr/bin/env bash

# az-vm-cli.sh
# This script was adapted from https://github.com/fouldsy/azure-mol-samples-2nd-ed/blob/master/02/azure_cli_sample.sh
# released under the MIT license. See https://github.com/fouldsy/azure-mol-samples-2nd-ed/blob/master/LICENSE
# and chapter 2 of the ebook "Learn Azure in a Month of Lunches - 2nd edition" (Manning Publications) by Iain Foulds,
# Purchase at https://www.manning.com/books/learn-azure-in-a-month-of-lunches-second-edition

set -o errexit

# Create a resource group. This is a logical container to hold your resources.
# You can specify any name you wish, so long as it's unique with your Azure
# subscription and location
echo "MY_RG=$MY_RG MY_LOC=${MY_LOC}"
az group create --name "${MY_RG}" --location "${MY_LOC}"

# Ensure a .ssh folder is available to hold key pairs:
if [ ! -d ~/.ssh ]; then  # directory not found:
   mkdir ~/.ssh
fi 
cd ~/.ssh

if [   -f ~/.ssh/"${SSH_KEY_FILE_NAME}" ]; then  # directory not found:
   rm -rf ~/.ssh/"${SSH_KEY_FILE_NAME}"
fi 

# Generate SSH key pair using built-in Linux ssh-keygen program in folder
# /home/wilson/.ssh/"${SSH_KEY_FILE_NAME}"  # (instead of file id_rsa)
# SSH keys are used to securely authenticate with a Linux VM
# This is somewhat optional, as the Azure CLI can generate keys for you
ssh-keygen -t rsa -b 2048 -f "${SSH_KEY_FILE_NAME}" -N ""
   # -N ""  makes the command not prompt for manual input.

# View the public part of your SSH key pair:
# From the CLI, you don't really need this. But if you use the Azure portal or
# Resource Manager templates (which we look at in chapter 6), you need to
# provide this public key
ls -al ~/.ssh/"${SSH_KEY_FILE_NAME}"

# Create a Linux VM
# You specify the resoure group from the previous step, then provide a name.
# This VM uses Ubuntu LTS as the VM image, and creates a user name `azuremol`
# The `--generate-ssh-keys` checks for keys you may have created earlier. If
# SSH keys are found, they are used. Otherwise, they are created for you:
az vm create \
    --name "${MY_VM_NAME}" \
    --image UbuntuLTS \
    --admin-username "${MY_ADMIN_USER_NAME}" \
    --generate-ssh-keys \
    --resource-group "${MY_RG}"

# Obtain the public IP address of your VM. Enter the name of your resource
# group and VM if you changed them
publicIp=$(az vm show \
    --name "${MY_VM_NAME}" \
    --show-details \
    --query publicIps \
    --output tsv \
    --resource-group "${MY_RG}" )

# TODO: if publicIp is blank, stop

# SSH to your VM with the username and public IP address for your VM
#ssh "${MY_ADMIN_USER_NAME}"@$publicIp 'uname -a; sudo apt update && sudo apt install -y lamp-server^; exit'
   # uname -a  # Display information to verify entry in the Linux machine:
   # Once logged in to your VM, install the LAMP web stack with apt-get
   # sudo apt update && sudo apt install -y lamp-server^

# Open port 80 to your webserver (not HTTPS) while testing:
az vm open-port --name "${MY_VM_NAME}" --port 80 --resource-group "${MY_RG}"
# TODO: Enable TLS for port 443?

# Now you can access the basic website in your web browser
echo "To see your web server in action, enter the public IP address in to your web browser: http://$publicIp"

# In Portal, list Virtual Machines at https://portal.azure.com/#blade/HubsExtension/BrowseResource/resourceType/Microsoft.Compute%2FVirtualMachines

# More VM CLI commands are at https://docs.microsoft.com/en-us/azure/virtual-machines/linux/cli-manage

