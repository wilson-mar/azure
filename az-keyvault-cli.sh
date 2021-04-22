#!/usr/bin/env bash

# ./az-keyvault-cli.sh
# This script was adapted from https://github.com/fouldsy/azure-mol-samples-2nd-ed/blob/master/15/azure_cli_sample.sh
# released under the MIT license. See https://github.com/fouldsy/azure-mol-samples-2nd-ed/blob/master/LICENSE
# and chapter 15 of the ebook "Learn Azure in a Month of Lunches - 2nd edition" (Manning Publications) by Iain Foulds,
# Purchase at https://www.manning.com/books/learn-azure-in-a-month-of-lunches-second-edition
# Also referenced: 
# https://app.pluralsight.com/library/courses/microsoft-azure-security-engineer-configure-manage-key-vault Sep 08, 2020
# https://app.pluralsight.com/library/courses/microsoft-azure-key-vault-configuring-managing Nov 18, 2020
   # https://github.com/ned1313/Configure-and-Manage-Key-Vault

set -o errexit

#echo ">>> Setup enviornment variables:"
#sh $HOME/setup.sh
#echo "MY_RG=$MY_RG in ./az-keybault-cli.sh"

echo ">>> Delete Resource Group \"$MY_RG\" if it already exists before recreating ..."
# Deleting RG deletes KeyVault and objects in it; Storage Acct.
if [ $(az group exists --name "${MY_RG}") = true ]; then
    az group delete --resource-group "${MY_RG}" --yes
fi
    az group create --name "${MY_RG}" --location "${MY_LOC}"


# Define a unique name for the Key Vault done by caller of this script:
MMDD=$( date +%m%d )  # No room for %Y = 2021
MY_KEYVAULT_NAME="Keyvault-${MY_RG}-$MMDD-$RANDOM"  
   # Example: Keyvault-mol-1230-3537  # LIMIT: Max 24 characters.
echo ">>> Create Key Vault \"$MY_KEYVAULT_NAME\":"

# Parameters are in order shown on the Portal GUI screen https://portal.azure.com/#create/Microsoft.KeyVault
# CLI DOCS: https://docs.microsoft.com/en-us/cli/azure/keyvault?view=azure-cli-latest#az_keyvault_create
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


MY_STORAGE_ACCT="storage${MMDD}$RANDOM"   # LIMIT: Max. 24 lower-case characters/numbers, no dashes.
echo ">>> Create Storage Account Name \"$MY_STORAGE_ACCT\" for Function App:"
az storage account create \
   --name "${MY_STORAGE_ACCT}" \
   --sku standard_lrs \
   --resource-group "${MY_RG}"
   # RESPONSE: 


echo ">>> Create a Function App:"
# Instead of Port GUI https://portal.azure.com/#blade/HubsExtension/BrowseResource/resourceType/Microsoft.Web%2Fsites/kind/functionapp
# PORTAL VIDEO DEMO: https://app.pluralsight.com/course-player?clipId=2308c37d-0804-4834-86f3-2f38937170c2
# CLI DOCS: https://docs.microsoft.com/en-us/cli/azure/functionapp?view=azure-cli-latest#az_functionapp_create
# The Function App is set up to be manually connected to a sample app in GitHub
az functionapp create \
    --name "${FUNC_APP_NAME}" \
    --storage-account "${MY_STORAGE_ACCT}" \
    --consumption-plan-location "${MY_LOC}" \
    --deployment-source-url https://raw.githubusercontent.com/wilson-mar/azure-your-way/main/analyzeTemperature.js \
    --resource-group "${MY_RG}"
  # -p $MY_PLAN  # Region, SKU Dynamic, Operating System: Windows
     # Consumption plan is used, which means you are only charged based on memory usage while your app is running. 
  # Publish: Code (not Docker Container)
  # Runtime Stack: .NET Core
  # Version: 3.1


echo ">>> Create a Service Principal:"


echo ">>> Add a Managed Identity:"
# https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/qs-configure-cli-windows-vm



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

echo ">>> Add Access Policy:"
# To avoid these error messages:
   # Client address is not authorized and caller is not a trusted service.
   # Client address: 13.64.246.36
   # Caller: appid=b677c290-cf4b-4a8e-a60e-91ba650a4abe;oid=58a1c620-bcd5-4d6e-8001-9b86c6fb1baf;iss=https://sts.windows.net/92543348-f7f0-4cc2-addc-11021d882720/
   # Vault: keyvault-mol-15032;location=westus


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


