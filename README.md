# Azure API Management Workspaces

## Overview
This repo provides a set of Bicep templates to deploy **Premium** SKU Azure API Management with Workspace and a Gateway resource.  

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

## Deploying

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
