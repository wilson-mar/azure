#!/usr/bin/env bash

# az-keyvault-cli.sh
# This script was adapted from https://github.com/fouldsy/azure-mol-samples-2nd-ed/blob/master/15/azure_cli_sample.sh
# released under the MIT license. See https://github.com/fouldsy/azure-mol-samples-2nd-ed/blob/master/LICENSE
# and chapter 15 of the ebook "Learn Azure in a Month of Lunches - 2nd edition" (Manning Publications) by Iain Foulds,
# Purchase at https://www.manning.com/books/learn-azure-in-a-month-of-lunches-second-edition

# Create a resource group
az group create --name "${MY_RG}" --location "${MY_LOC}"

# Define a unique name for the Key Vault
keyVaultName="${MY_KEYVAULT_NAME}"$RANDOM

# Create a Key Vault
# The vault is enabled for soft delete, which allows deleted keys to recovered,
# and is also enable for deployment. Being enabled for deployments allows VMs
# to use the keys stored within
az keyvault create \
    --name $keyVaultName \
    --enable-soft-delete \
    --enabled-for-deployment \
    --resource-group "${MY_RG}"

# Create a secret in Key Vault
# This secret is a basic password that is used to install a database server
az keyvault secret set \
    --vault-name $keyVaultName \
    --name "${MY_KEY_NAME}" \
    --description "Database password" \
    --value "${MY_KEY_SECRET}" 

# Show the secret stored in Key Vault
az keyvault secret show \
    --name "${MY_KEY_NAME}" \
    --vault-name $keyVaultName

# Delete the secret
az keyvault secret delete \
    --name "${MY_KEY_NAME}" \
    --vault-name $keyVaultName

# Wait 5 seconds for the secret to be successfully deleted before recovering
sleep 5

# Recover the deleted secret
# As the vault was enabled for soft delete, key are secret metadata is retained
# for a period of time. This allows keys and secrets to be recovered back to
# the vault.
az keyvault secret recover \
    --name "${MY_KEY_NAME}" \
    --vault-name $keyVaultName

# Create a VM
az vm create \
    --name molvm \
    --image ubuntults \
    --admin-username "${MY_ADMIN_USER_NAME}" \
    --generate-ssh-keys \
    --resource-group "${MY_RG}"

# Define the scope for upcoming Managed Service Identity tasks
# The scope is set to the resource group of the VM. This scope limits what
# access is granted to the identity
scope=$(az group show --query id --output tsv) \
    --resource-group "${MY_RG}"

# Create a Managed Service Identity
# The VM is assigned an identity, scoped to its resource group. The ID of this
# identity, the systemAssignedIdentity, is then stored as a variable for use
# in remaining commands
read systemAssignedIdentity <<< $(az vm identity assign \
    --name molvm \
    --role reader \
    --scope $scope \
    --query systemAssignedIdentity \
    --output tsv) \
    --resource-group "${MY_RG}"

# List the service principal name of the identity
# This identity is stored in Azure Active Directory and is used to actually
# assign permissions on the Key Vault. The VM's identity is queried within
# Azure Active directory, then the SPN is assigned to a variable
spn=$(az ad sp list \
    --query "[?contains(objectId, '$systemAssignedIdentity')].servicePrincipalNames[0]" \
    --output tsv) 

# Update permissions on Key Vault
# Add the VM's identity, based on the Azure Active Directory SPN. The identity
# is granted permissions to get secrets from the vault.
az keyvault set-policy \
    --name $keyVaultName \
    --secret-permissions get \
    --spn $spn

# Apply the Custom Script Extension
# The Custom Script Extension runs on the VM to execute a command that obtains
# the secret from Key Vault using the Instance Metadata Service, then uses the
# key to perform an unattended install of MySQL Server that automatically
# provides a password
az vm extension set \
    --publisher Microsoft.Azure.Extensions \
    --version 2.0 \
    --name CustomScript \
    --vm-name molvm \
    --settings '{"fileUris":["https://raw.githubusercontent.com/fouldsy/azure-mol-samples-2nd-ed/master/15/install_mysql_server.sh"]}' \
    --protected-settings '{"commandToExecute":"sh install_mysql_server.sh $keyVaultName"}' \
    --resource-group "${MY_RG}"

