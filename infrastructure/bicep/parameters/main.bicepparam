using '../main.bicep'

param workloadName = 'cmhworkspacepoc'
param environmentSuffix = 'dev'
param location = 'eastus2'
param apiManagementPublisherName = 'Contoso'
param apiManagementPublisherEmailAddress = 'apis@contoso.net'
param apimWorkspaceDescription = 'The workspace that will be used for the proof of concept'
param apimWorkspaceDisplayName = 'Workspace POC'
param apimWorkspaceName = 'pocworkspace'
param tags = {
  environment: 'dev'
  projectName: 'API Management Workspace POC'
  costCenter: 'XYZ-123ABC'
}
