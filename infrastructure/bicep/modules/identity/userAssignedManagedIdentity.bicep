param userAssignedManagedIdentityName string

@description('The Azure region where the resources should be deployed')
param location string

@description('A collection of tags to apply to the resources')
param tags object

resource userAssignedManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: userAssignedManagedIdentityName
  location: location
  tags: tags
}

output id string = userAssignedManagedIdentity.id
output principalId string = userAssignedManagedIdentity.properties.principalId
output clientId string = userAssignedManagedIdentity.properties.clientId
