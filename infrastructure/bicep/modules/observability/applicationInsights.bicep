@description('Application Insights resource name')
param applicationInsightsName string

@description('Azure region where the resource should be deployed')
param location string

@description('The resource ID of the Log Analytics workspace to link to the Application Insights resource')
param logAnalyticsWorkspaceResourceId string

resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: applicationInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Bluefield'
    Request_Source: 'rest'
    WorkspaceResourceId: logAnalyticsWorkspaceResourceId
  }
}

output id string = appInsights.id
