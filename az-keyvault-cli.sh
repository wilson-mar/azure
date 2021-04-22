#!/usr/bin/env bash

# ./az-keyvault-cli.sh
# This script was adapted from https://github.com/fouldsy/azure-mol-samples-2nd-ed/blob/master/15/azure_cli_sample.sh
# released under the MIT license. See https://github.com/fouldsy/azure-mol-samples-2nd-ed/blob/master/LICENSE
# and chapter 15 of the ebook "Learn Azure in a Month of Lunches - 2nd edition" (Manning Publications) by Iain Foulds,
# Purchase at https://www.manning.com/books/learn-azure-in-a-month-of-lunches-second-edition

set -o errexit

# Create a resource group
az group create --name "${MY_RG}" --location "${MY_LOC}"

# Define a unique name for the Key Vault done by caller of this script:
# MY_KEYVAULT_NAME="${MY_KEYVAULT_NAME}"$RANDOM

echo ">>> Create a Key Vault:"
# Parameters are in order shown on the Portal GUI screen https://portal.azure.com/#create/Microsoft.KeyVault
# https://docs.microsoft.com/en-us/cli/azure/keyvault?view=azure-cli-latest#az_keyvault_create
# The vault is enabled for soft delete, which allows deleted keys to recovered,
# and is also enable for deployment which allows VMs to use the keys stored.
az keyvault create \
    --resource-group "${MY_RG}" \
    --name $MY_KEYVAULT_NAME \
    --location "${MY_LOC}" \
    --retention-days 90 \
    --enabled-for-deployment \
    --default-action Deny  # Default action to apply when no rule matches.
    
  # --sku Standard \ # command not found
  # --retention-days 90 \. # 90 is max allowed.
  # --sku Standard  # or Premium (includes support for HSM backed keys) HSM: Standard_B1, Custom_B32. Default: Standard_B1.
  # Argument 'enable_soft_delete' has been deprecated and will be removed in a future release.
  # --enable-purge-protection false # during test env usage when Vault is rebuilt between sessions.
  # See https://docs.microsoft.com/en-us/azure/key-vault/general/soft-delete-overview
  # TODO: Add VNET rules 
# RESPONSE: Resource provider 'Microsoft.KeyVault' used by this operation is not registered. We are registering for you.


az keyvault list -o table

# az keyvault show # RESPONSE: The HSM 'None' not found within subscription.


echo ">>> Create (generate) a secret in Key Vault:"
# This secret is a basic password that is used to install a database server
az keyvault secret set \
    --vault-name $MY_KEYVAULT_NAME \
    --name "${MY_KEY_NAME}" \
    --value "${MY_KEY_SECRET}" \
    --description "Database password"  # = GUI Content Type (optional)
  # Upload options: Manual as Certificate, which is deprecated.
  # Set activation date?
  # Set expiration date?
  # Enabled: Yes
  # Use PowerShell to set multi-line secrets.

echo ">>> Show the secret stored in Key Vault:"
az keyvault secret show \
    --name "${MY_KEY_NAME}" \
    --vault-name $MY_KEYVAULT_NAME

echo ">>> Delete the secret:"
az keyvault secret delete \
    --name "${MY_KEY_NAME}" \
    --vault-name $MY_KEYVAULT_NAME
# RESPONSE: Secret databasepassword is currently being deleted.

# Wait 5 seconds for the secret to be successfully deleted before recovering
sleep 5

echo ">>> Recover the deleted secret:"
# As the vault was enabled for soft delete, key are secret metadata is retained
# for a period of time. This allows keys and secrets to be recovered back to
# the vault.
az keyvault secret recover \
    --name "${MY_KEY_NAME}" \
    --vault-name $MY_KEYVAULT_NAME


echo ">>> Use Managed Identity to read secret:"
# VIDEO DEMO https://app.pluralsight.com/course-player?clipId=2308c37d-0804-4834-86f3-2f38937170c2


