@description('Api Management resource name')
param apiManagementServiceName string

@description('Azure region where the resource should be deployed')
param location string

@description('The name of the publisher for the API Management service')
param apimPublisherName string

@description('The email address of the publisher administrator')
param apimPublisherEmailAddress string

@description('The number of capacity units to allocate to the API Management service')
param apimCapacityUnits int = 1

@description('The resource ID of the user-assigned managed identity to assign to the API Management service')
param apimUserAssignedManagedIdentityResourceId string

@description('The resource ID of the Log Analytics workspace to link to the API Management service')
param logAnalyticsWorkspaceResourceId string

resource apim 'Microsoft.ApiManagement/service@2024-05-01' = {
  name: apiManagementServiceName
  location: location
  identity: {
    type: 'SystemAssigned, UserAssigned'
    userAssignedIdentities: {
      '${apimUserAssignedManagedIdentityResourceId}': {}
    }
  }
  sku: {
    name: 'Premium'
    capacity: apimCapacityUnits
  }
  properties: {
    apiVersionConstraint: {
      minApiVersion: '2021-08-21'
    }
    customProperties: {
      // Disable weak/insecure cipher suites
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TripleDes168': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_128_CBC_SHA': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_256_CBC_SHA': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_128_CBC_SHA256': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_256_CBC_SHA256': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA' : 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_128_GCM_SHA256' : 'False'
    }
    publisherEmail: apimPublisherEmailAddress
    publisherName: apimPublisherName
  }
}

resource diag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'apim-diagnostics'
  scope: apim
  properties: {
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
      {
        categoryGroup: 'audit'
        enabled: true
      }
    ]
    workspaceId: logAnalyticsWorkspaceResourceId
  }
}
