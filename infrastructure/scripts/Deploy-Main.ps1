# Write a Powershell script that accepts a single parameter, 'ResourceGroup'.  The script should
# deploy the bicep template named 'main.bicep', located in the ./infrastructure/bicep/ directory to
# the resource group specified by the 'ResourceGroup' parameter.  The script should use the parameter
# file named main.bicepparam located in the ./infrastructure/bicep/paramters directory.  The deployment
# name should be set to a random 6 digit character string based on a guid.

param(
    [string]$ResourceGroup
)

$scriptPath = $PSScriptRoot

# Deploy the bicep template
$deploymentName = [guid]::NewGuid().ToString().Substring(0,6)

az deployment group create `
    --name $deploymentName `
    --resource-group $ResourceGroup `
    --template-file "$scriptPath\..\bicep/main.bicep" `
    --parameters "$scriptPath\..\bicep/parameters/main.bicepparam" `
    --mode Incremental
