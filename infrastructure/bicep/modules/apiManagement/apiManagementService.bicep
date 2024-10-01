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

@description('The resource ID of the Application Insights resource to link to the API Management service')
param appInsightsResourceId string

@description('The URI of the secret in the key vault that contains the Application Insights instrumentation key')
param appInsightsKeySecretUri string

@description('A collection of tags to apply to the resources')
param tags object

resource mi 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' existing = {
  name: last(split(apimUserAssignedManagedIdentityResourceId, '/'))
  scope: resourceGroup()
}

resource apim 'Microsoft.ApiManagement/service@2023-09-01-preview' = {
  name: apiManagementServiceName
  location: location
  tags: tags
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

resource appInsightsKeyNv 'Microsoft.ApiManagement/service/namedValues@2023-09-01-preview' = {
  name: 'appInsightsLoggerKey'
  parent: apim
  properties: {
    displayName: 'appInsightsLoggerKey'
    keyVault: {
      identityClientId: mi.properties.clientId
      secretIdentifier: appInsightsKeySecretUri
    }
    secret: true
  }
}

resource aiLogger 'Microsoft.ApiManagement/service/loggers@2023-09-01-preview' = {
  name: 'appInsightsLogger'
  parent: apim
  properties: {
    loggerType: 'applicationInsights'
    resourceId: appInsightsResourceId
    isBuffered: true
    credentials: {
      instrumentationKey: '{{ ${appInsightsKeyNv.name} }}'
    }
  }
}

resource appInsightsDiags 'Microsoft.ApiManagement/service/diagnostics@2023-09-01-preview' = {
  name: 'applicationinsights'
  parent: apim
  properties: {
    alwaysLog: 'allErrors'
    httpCorrelationProtocol: 'W3C'
    loggerId: aiLogger.id
    logClientIp: true
    sampling: {
      samplingType: 'fixed'
      percentage: 100
    }
    frontend: {
      request: {
        headers: [
        ]
        body: {
          bytes: 0
        }
      }
      response: {
        headers: [
        ]
        body: {
          bytes: 0
        }
      }
    }
    backend: {
      request: {
        headers: [
        ]
        body: {
          bytes: 0
        }
      }
      response: {
        headers: [
        ]
        body: {
          bytes: 0
        }
      }
    }
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
  name: '${gatewayName}-2'
  location: location
  tags: tags
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
