@description('The name of the secret to create in the key vault')
param secretName string

@description('The name of the key vault')
param keyVaultName string

@secure()
@description('The value of the secret to store in the key vault')
param secretValue string


resource kv 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: keyVaultName
  scope: resourceGroup()
}

resource secret 'Microsoft.keyvault/vaults/secrets@2021-11-01-preview' = {
  name: secretName
  parent: kv
  properties: {
    value: secretValue
  }
}

output secretUri string = secret.properties.secretUri
