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

var baseNameSuffix = '-${workloadName}-${environmentSuffix}'

var logAnalyticsWorkspaceName = 'log${baseNameSuffix}'
var logAnalyticsWorkspaceDeploymentName = '${logAnalyticsWorkspaceName}${deployment().name}'

var apimServiceName = 'apim${baseNameSuffix}'
var apimServiceDeploymentName = '${apimServiceName}${deployment().name}'
var apimUserAssignedManagedIdentityName = 'id${apimServiceName}'
var apimUserAssignedManagedIdentityDeploymentName = '${apimUserAssignedManagedIdentityName}${deployment().name}'

module log './modules/observability/logAnalyticsWorkspace.bicep' = {
  name: logAnalyticsWorkspaceDeploymentName
  params: {
    location: location
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
  }
}

module apimMi './modules/identity/userAssignedManagedIdentity.bicep' = {
  name: apimUserAssignedManagedIdentityDeploymentName
  params: {
    location: location
    userAssignedManagedIdentityName: apimUserAssignedManagedIdentityName
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
  }
}
