@description('The principal ID of the identity to assign to the key vault')
param identityPrincipalId string

@description('The name of the key vault')
param keyVaultName string

resource kv 'Microsoft.KeyVault/vaults@2024-04-01-preview' existing = {
  name: keyVaultName
  scope: resourceGroup()
}

var kvSecretsUserRoleId = '4633458b-17de-408a-b874-0445c86b69e6'

resource kvSecretsUserRole 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' existing = {
  name: kvSecretsUserRoleId
  scope: subscription()
}

resource kvRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().subscriptionId, kvSecretsUserRoleId, identityPrincipalId)
  scope: kv
  properties: {
    principalId: identityPrincipalId
    roleDefinitionId: kvSecretsUserRole.id
    principalType: 'ServicePrincipal'
  }
}
