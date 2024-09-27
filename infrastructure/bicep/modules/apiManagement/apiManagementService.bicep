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

@description('The name of the workspace to create')
param workspaceName string

@description('The display name of the workspace')
param workspaceDisplayName string

@description('The description of the workspace')
param workspaceDescription string

@description('The name of the gateway to create')
param gatewayName string

resource apim 'Microsoft.ApiManagement/service@2023-09-01-preview' = {
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
      minApiVersion: '2021-08-01'
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

resource ws 'Microsoft.ApiManagement/service/workspaces@2023-09-01-preview' = {
  name: workspaceName
  parent: apim
  properties: {
    displayName: workspaceDisplayName
    description: workspaceDescription
  }
}

resource gw 'Microsoft.ApiManagement/gateways@2023-09-01-preview' = {
  name: gatewayName
  location: location
  sku: {
    name: 'WorkspaceGatewayPremium'
    capacity: 1
  }
  properties: {
    backend: {}
    frontend: {}
    virtualNetworkType: 'None'
  }
}

resource gwConfig 'Microsoft.ApiManagement/gateways/configConnections@2023-09-01-preview' = {
  name: '${gatewayName}${uniqueString(gatewayName)}'
  parent: gw
  properties: {
    sourceId: ws.id
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

output id string = apim.id
output workspaceId string = ws.id
