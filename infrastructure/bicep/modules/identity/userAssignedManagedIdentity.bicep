param userAssignedManagedIdentityName string

@description('The Azure region where the resources should be deployed')
param location string

resource userAssignedManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: userAssignedManagedIdentityName
  location: location
}

output id string = userAssignedManagedIdentity.id
output principalId string = userAssignedManagedIdentity.properties.principalId
output clientId string = userAssignedManagedIdentity.properties.clientId
