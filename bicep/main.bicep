targetScope =  'resourceGroup'

@description('Region for the resources')
param location string = resourceGroup().location

@description('Enable purge protection for the key vault')
param enableKeyVaultPurgeProtection bool = false

var suffix = substring(uniqueString(resourceGroup().id), 0, 6)
var deployerPrincipalId = deployer().objectId
var keyVaultAdministratorRole = roleDefinitions('Key Vault Administrator')
var acrPullRole = roleDefinitions('AcrPull')
var acrPushRole = roleDefinitions('AcrPush')

resource keyVault 'Microsoft.KeyVault/vaults@2026-02-01' = {
  name: 'kv-daa-${suffix}'
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    enablePurgeProtection: enableKeyVaultPurgeProtection ? true : null // to disable purge protection the value must not be set
    tenantId: tenant().tenantId
    enableRbacAuthorization: true
    publicNetworkAccess: 'Enabled'
  }
}


resource containerRegistry 'Microsoft.ContainerRegistry/registries@2025-11-01' = {
  name: 'crdaa${suffix}'
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: false
    publicNetworkAccess: 'Enabled'
  }
}

resource roleAssignmentKeyVaultAdministrator 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVault.id, deployerPrincipalId, keyVaultAdministratorRole.id)
  scope: keyVault
  properties: {
    principalId: deployerPrincipalId
    roleDefinitionId: keyVaultAdministratorRole.id
    principalType: 'User'
  }
}

resource roleAssignmentAcrPush 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(containerRegistry.id, deployerPrincipalId, acrPushRole.id)
  scope: containerRegistry
  properties: {
    principalId: deployerPrincipalId
    roleDefinitionId: acrPushRole.id
    principalType: 'User'
  }
}

resource roleAssignmentAcrPull 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(containerRegistry.id, deployerPrincipalId, acrPullRole.id)
  scope: containerRegistry
  properties: {
    principalId: deployerPrincipalId
    roleDefinitionId: acrPullRole.id
    principalType: 'User'
  }
}

output keyVaultName string = keyVault.name
output acrName string = containerRegistry.name
output acrLoginServer string = containerRegistry.properties.loginServer
