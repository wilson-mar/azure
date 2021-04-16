This is <a target="_blank" href="https://github.com/wilson-mar/azure/">https://github.com/wilson-mar/azure/</a>

In this repo are files adapted from various experts generous with sharing their code:
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

My Bash scripts references external system variables defined before scripts are invoked:

   <pre>MY_LOC="westus2"
MY_RG="whatever2"
MY_APPNAME="thismustbeunique2"</pre>

The above variable values are defined in file or by JIT command parameters specified at run-time.
   <ul><tt>source ~/secrets.sh -v </tt></ul>
 
My contribution is a Bash script is invoked with a command like this to create various services:
* To create a VM with a public IP address:

   <tt>az-vm-cli.sh</tt> 

* To create an App Service Plan, Azure Web App, Deployment, to show MY_APPNAME.

   <tt>az-webapp-cli.sh</tt> 

* To create a network with two subnets and a network security group that secures inbound traffic. One subnet is for remote access traffic, one is web traffic for VMs that run a web server. Two VMs are then created. One allows SSH access and has the appropriate network security group rules applied. You use this VM as an <strong>SSH jumpbox</strong> to then connect to the the second VM which can be used an web server:

   <tt>az-vm-jumpbox-cli.sh</tt> 


