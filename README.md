There are several ways to automate provisioning of resources in Azure:
   1. portal.azure.com GUI
   2. Bash CLI shell (az commands)
   3. PowerShell (Az modules)
   4. JSON Template and parameter files
   5. PowerShell DSC (Desired State Configuration) automation
   6. REST API (which the above calls behind the scenes), written in curl, C# .NET, Java, Python, NodeJs, etc.
   7. REST API calls in program generated from Swagger/OpenAPI JSON
   8. Terraform HCL (with templating features and advanced logic features)
   9. Helm charts referencing DockerHub or Azure Container Registry (ACR) images
   10. <a target="_blank" href="https://wilsonmar.github.io/pulumi">Pulumi</a> programming in Python
   11. Bicep (from Microsoft)
   <br /><br />

The contribution of <a target="_blank" href="https://github.com/wilson-mar/azure-your-way/">this repo (at https://github.com/wilson-mar/azure-your-way)</a>
are Bash scripts which have been <strong>generalized</strong> for productive use.
Scripts here are adapted from various experts generous with sharing their code:
   * https://github.com/fouldsy/azure-mol-samples-2nd-ed by Iain Foulds, explained in https://aka.ms/monthoflunches published 4/30/2020.

   Microsoft Learning:
   * https://github.com/MicrosoftLearning/AZ-303-Microsoft-Azure-Architect-Technologies
   * https://github.com/MicrosoftLearning/AZ500-AzureSecurityTechnologies
   * https://github.com/Azure/azure-cli by Microsoft

   * https://github.com/timothywarner/az400 & az303 by Tim Warner
   * https://github.com/zaalion/oreilly-azure-app-security by Reza Salehi 
   
   * https://github.com/Azure/azure-quickstart-templates (ARM Templates)
   * https://github.com/johnthebrit/AzureMasterClass PowerShell scripts
   * https://github.com/terraform-providers/terraform-provider-azurerm

   * Skylines Academy
   * Gruntwork (Terraform)
   * CloudPosse (Terraform for AWS)
   <br /><br />

1. Be in https://shell.azure.com

1. If you ran these scripts for <strong>training or testing</strong>, (to save disk space) remove the repo before and after the next step (download):

   <pre><strong>cd ~/clouddrive
   rm -rf azure-your-way
   </strong></pre>

1. Download this repo to establish a run enviornment:

   <pre><strong>cd clouddrive
   git clone https://github.com/wilson-mar/azure-your-way.git --depth 1 
   cd azure-your-way
   ls
   chmod +x *.sh
   export PS1="\n  \w\[\033[33m\]\n$ "
   </strong></pre>

1. Copy environment variable definitions and paste in the command line for bash scripts to reference:

   <pre>export MY_LOC="westus"               # aka region
   export MY_RG="mol"
   export MY_GIT_CONTAINER="$HOME/clouddrive"      # "clouddrive" in Cloud Shell
   export MY_REPO="azure-your-way"           # repo name in my GitHub.com/wilson-mar
   export MY_SCRIPT="az-helm-cli.sh"         # the script being called
   export MY_SCRIPT_VERSION="0.1.4"    
   export MY_ACR="jollygoodacr"    
   export MY_VM_NAME="mol-westus2"
   export MY_APPNAME="azuremol"              # 
   export MY_ADMIN_USER_NAME="johndoe" # admin user name cannot contain upper case character A-Z, special characters \/"[]:|<>+=;,?*@#()! or start with $ or -
   export MY_SVC_BUS_NAME="azuremol"
   export MY_STORAGE_ACCT="AzureSaves12345"  # globally unique in front of /file.core.windows.net
   export FUNC_APP_NAME="Bulwinkle12345"     # globally unique in front of .azurewebsites.net
   export SSH_KEY_FILE_NAME="id_rsa".        # default is id_rsa.
   export MY_KEYVAULT_NAME="keyvault-$MY_RG-$RANDOM"   # globally unique
   export MY_KEY_NAME="databasepassword"
   export MY_KEY_SECRET="SecureP@ssw0rd"     # for saving into Key Vault
   export MY_DOCKERHUB_ACCT="iainfoulds"     # globally unique in Docker.io (DockerHub)
   export MY_CONTAINER="azuremol"            # within DockerHub
   </pre>

   The above are example values. CAUTION: Do not save your secrets unencrypted in GitHub (even if it has Private visibility).
   Save them to a local file such as <tt>$HOME/.secrets.sh</tt> so that you can 
   copy and paste them at the beginning of each CLI session.
   
   PROTIP: Use of a variable by various scripts and commands avoids typos and misconfigurations.
   
1. PROTIP: Use environment variables to <strong>delete resource groups</strong> created to stop charges from accumulating on Virtual Servers, etc.: 

   <pre><strong>MY_RG="mol"
   az group delete --name "${MY_RG}" --yes   # takes several minutes
   </strong></pre>

   <tt>--yes</tt> before the az command feeds a "y" to automatically answer the request:<br />
   Are you sure you want to perform this operation? (y/n): y

1. Invoke an individual Bash script with a command like this to create various resources within Azure:

* Use Helm charts

   <pre><strong>MY_RG="helm-$MY_LOC"
   ./<a href="https://github.com/wilson-mar/azure-your-way/blob/main/az-helm-cli.sh">az-helm-cli.sh</a>
   </strong></pre>

* Create a VM with a public IP address:

   <pre><strong>MY_RG="azuremolchapter2-$MY_LOC"
   ./<a href="https://github.com/wilson-mar/azure-your-way/blob/main/az-vm-cli.sh">az-vm-cli.sh</a>
   </strong></pre>

* Create an App Service Plan, Azure Web App, Deployment, to show MY_APPNAME.

   <pre><strong>MY_RG="azuremolchapter3-$MY_LOC"
   ./<a target="_blank" href="https://github.com/wilson-mar/azure-your-way/blob/main/az-webapp-cli.sh">az-webapp-cli.sh</a>
   </strong></pre>

* Create a network with two subnets and a network security group that secures inbound traffic. One subnet is for remote access traffic, one is web traffic for VMs that run a web server. Two VMs are then created. One allows SSH access and has the appropriate network security group rules applied. You use this VM as an <strong>SSH jumpbox</strong> to then connect to the the second VM which can be used an web server:

   <pre><strong>MY_RG="azuremolchapter5-$MY_LOC"
   ./<a target="_blank" href="https://github.com/wilson-mar/azure-your-way/blob/main/az-vm-jumpbox-cli.sh">az-vm-jumpbox-cli.sh</a>
   </strong></pre> 

* Create a VM with a public IP address. Enabled are a storage account, boot diagnostics with the VM diagnostics extension applied:

   <pre><strong>MY_RG="azuremolchapter12-$MY_LOC"
   ./<a target="_blank" href="https://github.com/wilson-mar/azure-your-way/blob/main/az-vm-diag-cli.sh">az-vm-diag-cli.sh</a>
   </strong></pre>

* Create a VM; Recovery Services vault, a backup policy, then creates a VM and applies the backup policy before starting the initial backup job.

   <pre><strong>MY_RG="azuremolchapter13-$MY_LOC"
   ./<a target="_blank" href="https://github.com/wilson-mar/azure-your-way/blob/main/az-vm-backup-cli.sh">az-vm-backup-cli.sh</a>
   </strong></pre>

* Create an Azure Key Vault; put a secret in it; show secret; delete secret; recover secret; create a vm; Managed Service Identity; update permissions; Custom Script Extension; Apply the Custom Script Extension:

   <pre><strong>MY_RG="azuremolchapter15-$MY_LOC"
   ./<a target="_blank" href="https://github.com/wilson-mar/azure-your-way/blob/main/az-keyvault-cli.sh">az-keyvault-cli.sh</a>
   </strong></pre>
   
* Create a Docker container from a Dockerfile; Create AKS; Scale up replicas 

   <pre><strong>MY_RG="azuremolchapter19-$MY_LOC"
   ./<a target="_blank" href="https://github.com/wilson-mar/azure-your-way/blob/main/az-aks-cli.sh">az-aks-cli.sh</a>
   </strong></pre>
   
   The IP shows the "Month of Pizza Lunches in a container" website (load balanced).

* Create Azure Functions:

   <pre><strong>MY_RG="azuremolchapter21-$MY_LOC"
   ./<a target="_blank" href="https://github.com/wilson-mar/azure-your-way/blob/main/az-functions-temp.sh">az-functions-temp.sh</a>
   </strong></pre>

   Several Functions components are not available in the Azure CLI, so manual actions are needed on Azure portal to fill in the gaps.
   See the "Month of Lunches" ebook.

Bash scripts here are written with coding conventions defined at <a target="_blank" href="https://wilsonmar.github.io/bash-codng">https://wilsonmar.github.io/bash-coding</a> which include:

   * <tt>set -o errexit</tt> so that the script stops on the first error (instead of running on).
   <br /><br />
   
   
