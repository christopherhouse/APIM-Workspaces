@description('Log Analytics Workspace resource name')
param logAnalyticsWorkspaceName string

@description('Azure region where the resource should be deployed')
param location string

resource law 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

output id string = law.id
