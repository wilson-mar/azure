# azure

These files are adapted from various others generous with sharing their code:
   * https://github.com/fouldsy/azure-mol-samples-2nd-ed by Ian 
   * https://github.com/timothywarner/az400 by Tim Warner
   * https://github.com/zaalion/oreilly-azure-app-security
   * https://github.com/johnthebrit/AzureMasterClass PowerShell scripts
   * Skylines Academy
   * Gruntwork (Terraform)
   * CloudPosse (Terraform for AWS)
   
   Microsoft labs:
   * https://github.com/MicrosoftLearning/AZ-303-Microsoft-Azure-Architect-Technologies
   * https://github.com/MicrosoftLearning/AZ500-AzureSecurityTechnologies
   <br /><br />

A Bash script is invoked with a command like this to create various services:
   * az-all-cli.sh is run 

The script references external system variables:

   * $MY_LOC="westus2"
   * $MY_RG="whatever2"
   * $MY_APPNAME="thisisunique2"
   <br /><br />

The above variable values are defined in file or by JIT command parameters specified at run-time.
 
The script calls other scripts which
 
* az-webapp-cli.sh creates an App Service Plan, Azure Web App, Deployment, to show a hostName.

