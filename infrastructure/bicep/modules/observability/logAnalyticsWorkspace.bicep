@description('Log Analytics Workspace resource name')
param logAnalyticsWorkspaceName string

@description('Azure region where the resource should be deployed')
param location string

@description('A collection of tags to apply to the resources')
param tags object

resource law 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

output id string = law.id
