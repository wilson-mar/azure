# azure

These files are adapted from various others generous with sharing their code:
   * https://github.com/fouldsy/azure-mol-samples-2nd-ed
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

