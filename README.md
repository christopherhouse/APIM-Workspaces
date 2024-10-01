# Azure API Management Workspaces

## Overview
This repo provides a set of Bicep templates to deploy **Premium** SKU Azure API Management with Workspace and a Gateway resource.  Note that the templates in this repo are intended for a simple proof of concept deployment, not production-grade deployments.  These templates do not include things like virtual network isolation, WAF protection, dev portal Entra configuration, etc, that are considered best practices.

## Resources Deployed
Deploying the templates in this repo will create the following resources inside a single Azure Resource Group:

- Azure API Management Service
  - Azure API Management Gateway
  - Azure API Management Workspace
  - Named Value pointing to Key Vault secret w/ App Insights key
  - App Insights logger
  - App Insights diagnostic settings to log all APIs to App Insights
- User Assigned Managed Identity for API Management
  - Identity is granted Key Vault Secrets User RBAC role over Key Vault
- Log Analytics Workspace
- Application Insights
  - Application Insights Instrumentation Key stored in Key Vault

## Template Deployment

### Prerequisites
- Powershell (any version)
- Azure CLI (any version)
- `Contributor` access to a Resource Group in an Azure Subscription
- `User Access Administrator` access over a Resource Group in an Azure Subscription (required since templates grant Key Vault access to the API Management Managed Identity)

### Parameters

Before deploying, review and update the parameters in the file [`main.bicepparam`](./infrastructure/bicep/parameters/main.bicepparam)

The table below lists the parameters in the file

| Parameter Name                          | Data Type | Required | Description                                                                                                         |
|-----------------------------------------|-----------|----------|---------------------------------------------------------------------------------------------------------------------|
| `workloadName`                          | string    | Yes      | The workload name. Used to generate names for resources in the form of [resource type abbrev.]-[workload name]-[environment suffix]. |
| `environmentSuffix`                     | string    | Yes      | The environment suffix. Used to generate names for resources in the form of [resource type abbrev.]-[workload name]-[environment suffix]. |
| `location`                              | string    | Yes      | The Azure region where the resources should be deployed.                                                            |
| `apiManagementPublisherName`            | string    | Yes      | The name of the publisher for the API Management service.                                                           |
| `apiManagementPublisherEmailAddress`    | string    | Yes      | The email address of the publisher administrator.                                                                   |
| `apimWorkspaceName`                     | string    | Yes      | The name of the APIM workspace to create.                                                                           |
| `apimWorkspaceDisplayName`              | string    | Yes      | The display name of the workspace.                                                                                  |
| `apimWorkspaceDescription`              | string    | Yes      | The description of the workspace.                                                                                   |
| `tags`                                  | object    | No       | A collection of tags to apply to the resources.                                                                     |

### Deployment Script

The [`Deploy-Main.ps1`](./infrastructure/scripts/Deploy-Main.ps1) script located in the `infrastructure/scripts` directory is used to deploy the Bicep template `main.bicep` to a specified Azure resource group. The script uses the parameter file `main.bicepparam` to provide necessary parameters for the deployment.

#### What the Script Does

- Accepts a single parameter, `ResourceGroup`, which specifies the Azure resource group where the resources will be deployed.
- Generates a random 6-digit deployment name based on a GUID.
- Deploys the Bicep template `main.bicep` located in the `./infrastructure/bicep/` directory.
- Uses the parameter file `main.bicepparam` located in the `./infrastructure/bicep/parameters/` directory.
- Sets the deployment mode to `Incremental`.

#### How to Execute the Script

To execute the script, open a PowerShell terminal and run the following command, replacing `<ResourceGroupName>` with the name of your Azure resource group:

```powershell
# Deploy main.bicep to the specified resource group
$resourceGroupName = "[Your RG name here]"
./infrastructure/scripts/Deploy-Main.ps1 -ResourceGroup $resourceGroupName