This is <a target="_blank" href="https://github.com/wilson-mar/azure-your-way/">https://github.com/wilson-mar/azure-your-way</a>

The contribution of this repo are Bash scripts which have been generalized with these external system variables:

   <ul><pre>export MY_LOC="westus2"   # aka region
export MY_RG="mol"
export MY_ADMIN_USER_NAME="JohnDoe"
export MY_VM_NAME="webvm1"
export MY_APPNAME="thismustbeunique2"
export MY_VAULT_NAME="secretplace"
export MY_SVC_BUS_NAME="azuremol"
export MY_STORAGE_ACCT="AzureSaves"
export FUNC_APP_NAME="Bulwinkle"
export SSH_KEY_FILE_NAME="id_rsa"
export MY_KEYVAULT_NAME="specialplace2"
export MY_KEY_NAME="databasepassword"
export MY_KEY_SECRET="SecureP@ssw0rd"   # safely saved in Key Vault
</pre></ul>

The above are example values. CAUTION: Do not save your secrets unencrypted in GitHub (even if it has Private visibility).
Save them to a local file such as <tt>$HOME/.secrets.sh</tt> 
so that you can copy and paste them at the beginning of each CLI session.

The above variable are referenced within Bash scripts adapted from various experts generous with sharing their code:
   * https://github.com/fouldsy/azure-mol-samples-2nd-ed by Iain Foulds 
   * https://github.com/timothywarner/az400 & az303 by Tim Warner
   * https://github.com/zaalion/oreilly-azure-app-security
   * https://github.com/johnthebrit/AzureMasterClass PowerShell scripts
   * Skylines Academy
   * Gruntwork (Terraform)
   * CloudPosse (Terraform for AWS)
   
   Microsoft labs:
   * https://github.com/MicrosoftLearning/AZ-303-Microsoft-Azure-Architect-Technologies
   * https://github.com/MicrosoftLearning/AZ500-AzureSecurityTechnologies
   <br /><br />

Make this repo availble on https://shell.azure.com

   <ul><pre><strong>cd clouddrive
   git clone https://github.com/wilson-mar/azure-your-way.git --depth 1 
   cd azure-your-way
   ls
   chmod +x *
   </strong></pre></ul>

When you're done, remove the repo:

   <ul><pre><strong>cd ~/clouddrive
   rm -rf azure-your-way
   </strong></pre></ul>

Invoke an individual Bash script with a command like this to create various resources within Azure:

* Create a VM with a public IP address:

   <pre><strong>MY_RG="azuremolchapter2-$MY_LOC"
   az-vm-cli.sh -v</strong></pre>

* Create an App Service Plan, Azure Web App, Deployment, to show MY_APPNAME.

   <pre><strong>MY_RG="azuremolchapter3-$MY_LOC"
   az-webapp-cli.sh -v 
   </strong></pre>

* Create a network with two subnets and a network security group that secures inbound traffic. One subnet is for remote access traffic, one is web traffic for VMs that run a web server. Two VMs are then created. One allows SSH access and has the appropriate network security group rules applied. You use this VM as an <strong>SSH jumpbox</strong> to then connect to the the second VM which can be used an web server:

   <pre><strong>MY_RG="azuremolchapter5-$MY_LOC"
   az-vm-jumpbox-cli.sh -v
   </strong></pre> 

* Create a VM with a public IP address. Enabled are a storage account, boot diagnostics with the VM diagnostics extension applied:

   <pre><strong>MY_RG="azuremolchapter12-$MY_LOC"
   az-vm-diag-cli.sh -v
   </strong></pre>

* Create a VM; Recovery Services vault, a backup policy, then creates a VM and applies the backup policy before starting the initial backup job.

   <pre><strong>MY_RG="azuremolchapter13-$MY_LOC"
   az-vm-backup-cli.sh -v
   </strong></pre>

* Create an Azure Key Vault; put a secret in it; show secret; delete secret; recover secret; create a vm; Managed Service Identity; update permissions; Custom Script Extension; Apply the Custom Script Extension:

   <pre><strong>MY_RG="azuremolchapter15-$MY_LOC"
   az-keyvault-cli.sh -v
   </strong></pre>
   
* Create a Docker container, AKS, Lastly, scale up replicas:

   <pre><strong>MY_RG="azuremolchapter19-$MY_LOC"
   az-aks-cli.sh -v
   </strong></pre>

* Create Azure Functions:

   <pre><strong>MY_RG="azuremolchapter21-$MY_LOC"
   az-functions-temp.sh -v
   </strong></pre>

   Several Functions components are not available in the Azure CLI, so manual actions are needed on Azure portal to fill in the gaps.
   See the "Month of Lunches" ebook.
