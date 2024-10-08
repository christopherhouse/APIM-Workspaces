@description('The workload name.  Used to generate names for resources in the form of [resource type abbrev.]-[workload name]-[environment suffix]')
param workloadName string

@description('The environment suffix.  Used to generate names for resources in the form of [resource type abbrev.]-[workload name]-[environment suffix]')
param environmentSuffix string

@description('The Azure region where the resources should be deployed')
param location string

@description('The name of the publisher for the API Management service')
param apiManagementPublisherName string

@description('The email address of the publisher administrator')
param apiManagementPublisherEmailAddress string

@description('The name of the APIM workspace to create')
param apimWorkspaceName string

@description('The display name of the workspace')
param apimWorkspaceDisplayName string

@description('The description of the workspace')
param apimWorkspaceDescription string

@description('A collection of tags to apply to the resources')
param tags object = {}

var baseNameSuffix = '-${workloadName}-${environmentSuffix}'

var logAnalyticsWorkspaceName = 'log${baseNameSuffix}'
var logAnalyticsWorkspaceDeploymentName = '${logAnalyticsWorkspaceName}${deployment().name}'

var apimServiceName = 'apim${baseNameSuffix}'
var apimServiceDeploymentName = '${apimServiceName}${deployment().name}'
var apimUserAssignedManagedIdentityName = 'id-${apimServiceName}'
var apimUserAssignedManagedIdentityDeploymentName = '${apimUserAssignedManagedIdentityName}${deployment().name}'
var apimUserRbacAssignmentDeploymentName = '${apimUserAssignedManagedIdentityName}rbac${deployment().name}'
var apimWorkspaceGatewayName = 'gw-${apimWorkspaceName}'

var keyVaultName = 'kv${baseNameSuffix}'
var keyVaultDeploymentName = '${keyVaultName}${deployment().name}'

var appInsightsName = 'appi${baseNameSuffix}'
var appInsightsDeploymentName = '${appInsightsName}${deployment().name}'

module kv './modules/keyVault/keyVault.bicep' = {
  name: keyVaultDeploymentName
  params: {
    keyVaultName: keyVaultName
    location: location
    logAnalyticsWorkspaceResourceId: log.outputs.id
    tags: tags
  }
}

module log './modules/observability/logAnalyticsWorkspace.bicep' = {
  name: logAnalyticsWorkspaceDeploymentName
  params: {
    location: location
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    tags: tags
  }
}

module appInsights './modules/observability/applicationInsights.bicep' = {
  name: appInsightsDeploymentName
  params: {
    location: location
    applicationInsightsName: appInsightsName
    logAnalyticsWorkspaceResourceId: log.outputs.id
    keyVaultName: kv.outputs.name
    tags: tags
  }
}

module apimMi './modules/identity/userAssignedManagedIdentity.bicep' = {
  name: apimUserAssignedManagedIdentityDeploymentName
  params: {
    location: location
    userAssignedManagedIdentityName: apimUserAssignedManagedIdentityName
    tags: tags
  }
}

module apimMiSecretsUser './modules/keyVault/keyVaultSecretsUserAssignment.bicep' = {
  name: apimUserRbacAssignmentDeploymentName
  params: {
    identityPrincipalId: apimMi.outputs.principalId
    keyVaultName: kv.outputs.name
  }
}

module apim './modules/apiManagement/apiManagementService.bicep' = {
  name: apimServiceDeploymentName
  params: {
    location: location
    apiManagementServiceName: apimServiceName
    apimPublisherEmailAddress: apiManagementPublisherEmailAddress
    apimPublisherName: apiManagementPublisherName
    apimUserAssignedManagedIdentityResourceId: apimMi.outputs.id
    logAnalyticsWorkspaceResourceId: log.outputs.id
    gatewayName: apimWorkspaceGatewayName
    workspaceName: apimWorkspaceName
    workspaceDisplayName: apimWorkspaceDisplayName
    workspaceDescription: apimWorkspaceDescription
    apimCapacityUnits: 1
    appInsightsKeySecretUri: appInsights.outputs.instrumentationKeySecretUri
    appInsightsResourceId: appInsights.outputs.id
    tags: tags
  }
  dependsOn: [
    // Setup a manual depdency since no natural depdency exists to ensure that the MI RBAC assignment
    // happens before APIM gets deployed
    apimMiSecretsUser
  ]
}
