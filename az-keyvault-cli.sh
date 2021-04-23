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
# https://newsignature.com/articles/azure-devops-with-a-firewall-enabled-key-vault/

set -o errexit

echo ">>> Delete Resource Group \"$MY_RG\" if it already exists before recreating ..."
# Deleting RG deletes KeyVault and objects in it; Storage Acct.
if [ $(az group exists --name "${MY_RG}") = true ]; then
    az group delete --resource-group "${MY_RG}" --yes
fi
    az group create --name "${MY_RG}" --location "${MY_LOC}"


echo ">>> Create Key Vault \"$MY_KEYVAULT_NAME\":"
# Parameters are in order shown on the Portal GUI screen https://portal.azure.com/#create/Microsoft.KeyVault
# CLI DOCS: https://docs.microsoft.com/en-us/cli/azure/keyvault?view=azure-cli-latest#az_keyvault_create
# The vault is enabled for soft delete, which allows deleted keys to recovered,
# and is also enable for deployment which allows VMs to use the keys stored.
az keyvault create \
    --name "${MY_KEYVAULT_NAME}" \
    --location "${MY_LOC}" \
    --retention-days 90 \
    --enabled-for-deployment \
    --default-action Deny \
    --resource-group "${MY_RG}" 

  # --default-action Deny # Default action to apply when no rule matches.
  # --sku Standard \ # command not found
  # --retention-days 90 \. # 90 is max allowed.
  # --sku Standard  # or Premium (includes support for HSM backed keys) HSM: Standard_B1, Custom_B32. Default: Standard_B1.
  # Argument 'enable_soft_delete' has been deprecated and will be removed in a future release.
  # --enable-purge-protection false # during test env usage when Vault is rebuilt between sessions.
  # See https://docs.microsoft.com/en-us/azure/key-vault/general/soft-delete-overview
# RESPONSE: Resource provider 'Microsoft.KeyVault' used by this operation is not registered. We are registering for you.

echo ">>> Add network rule to Key Vault \"$MY_KEYVAULT_NAME\":"
  # CLI DOCS: https://docs.microsoft.com/en-us/cli/azure/keyvault/network-rule?view=azure-cli-latest
  # --network-acls # Network ACLs. It accepts a JSON filename or a JSON string. JSON format: {"ip":[<ip1>, <ip2>...],"vnet":[<vnet_name_1>/<subnet_name_1>,<subnet_id2>...]}.
  # --network-acls-ips  # Network ACLs IP rules. Space-separated list of IP addresses.
  # --network-acls-vnets  # Network ACLS VNet rules. Space-separated list of Vnet/subnet pairs or subnet resource ids.
az keyvault network-rule add --name "${MY_KEYVAULT_NAME}"  \
                             --ip-address "${MY_CLIENT_IP}"

az keyvault list -o table
# az keyvault show # RESPONSE: The HSM 'None' not found within subscription.


echo ">>> Create new Storage Account \"$MY_STORAGE_ACCT\" for Function App:"
az storage account create \
   --name "${MY_STORAGE_ACCT}" \
   --sku standard_lrs \
   --resource-group "${MY_RG}"

az storage account list --resource-group "${MY_RG}" --output table 
   # --query [*].{Name:name,Location:primaryLocation,Kind:kind}  CreationTime
   # grep to show only on created to filter out cloud-shell-storage account

echo ">>> Add tag \"${MY_STORAGE_TAG}\" to Storage account \"$MY_STORAGE_ACCT\":"
az storage account update --name "${MY_STORAGE_ACCT}" --resource-group "${MY_RG}" --tags “${MY_STORAGE_TAGS}”


echo ">>> Create App Service Plan \"$MY_PLAN\":"
# CLI DOC: https://docs.microsoft.com/en-us/cli/azure/appservice/plan?view=azure-cli-latest
az appservice plan create --name "${MY_PLAN}" \
   --resource-group "${MY_RG}"
#   --is-linux --number-of-workers 1 --sku S1
#   --hyper-v --sku P1V3

echo ">>> Create Function App \"$MY_FUNC_APP_NAME\":"
# Instead of Port GUI https://portal.azure.com/#blade/HubsExtension/BrowseResource/resourceType/Microsoft.Web%2Fsites/kind/functionapp
# PORTAL VIDEO DEMO: https://app.pluralsight.com/course-player?clipId=2308c37d-0804-4834-86f3-2f38937170c2
# CLI DOCS: https://docs.microsoft.com/en-us/cli/azure/functionapp?view=azure-cli-latest#az_functionapp_create
# The Function App is set up to be manually connected to a sample app in GitHub
az functionapp create \
    --name "${MY_FUNC_APP_NAME}" \
    --storage-account "${MY_STORAGE_ACCT}" \
    --consumption-plan-location "${MY_LOC}" \
    --plan "${MY_PLAN}" \
    --deployment-source-url "${MY_FUNC_APP_URL}" \ 
    --functions-version "${MY_FUNC_APP_VER}" \
    --resource-group "${MY_RG}"
  # -p $MY_PLAN  # Region, SKU Dynamic, Operating System: Windows
     # Consumption plan is used, which means you are only charged based on memory usage while your app is running. 
  # Publish: Code (not Docker Container)
  # Runtime Stack: .NET Core
  # Version: 3.1


# echo ">>> Create a Service Principal (service acct):"
# Instead # See https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli
# See https://docs.microsoft.com/en-us/cli/azure/ad/sp?view=azure-cli-latest#az_ad_sp_create_for_rbac


echo ">>> Add Managed Identity \"${MY_MANAGED_IDENTITY}\":"  # using tokens from Azure Active Directory, instead of Service Principal (service acct)  credentials
# See https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview
# See https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/qs-configure-cli-windows-vm
# System-assigned identidfy to specific resource means when that resource is deleted, Azure automatically deletes the identity.
# CLI DOC: https://docs.microsoft.com/en-us/cli/azure/identity?view=azure-cli-latest
az identity create --name "${MY_MANAGED_IDENTITY}" \
                   --resource-group "${MY_RG}"


#echo ">>> Add Access Policy:"
# See https://docs.microsoft.com/en-us/azure/key-vault/general/network-security
# To avoid these error messages:
   # Client address is not authorized and caller is not a trusted service.

echo ">>> Create (generate) secret named \"${MY_KEY_NAME}\" in Key Vault \"${MY_KEYVAULT_NAME}\":"
# This secret is a basic password that is used to install a database server
az keyvault secret set \
    --vault-name "${MY_KEYVAULT_NAME}" \
    --name "${MY_KEY_NAME}" \
    --value "${MY_KEY_SECRET}" \
    --description "${MY_KEY_CONTENT_TYPE}"  # such as "Database password"  # = GUI Content Type (optional)
  # Upload options: Manual as Certificate, which is deprecated.
  # Set activation date?
  # Set expiration date?
  # Enabled: Yes
  # Use PowerShell to set multi-line secrets.
   # ERROR RESPONSE: Client address is not authorized and caller is not a trusted service.

echo ">>> Show the secret stored in Key Vault:"
az keyvault secret show \
    --name "${MY_KEY_NAME}" \
    --vault-name "${MY_KEYVAULT_NAME}"

exit
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

# https://www.youtube.com/watch?v=PgujSug1ZbI use KeyVault in Logic App, ADF 
