targetScope = 'subscription'
param tags object

param location string
param prefix string = 'iac-ws4'
param slot string = 'blue'
param tenantId string
param vnetAddressPrefix string
param aksSubnetAddressPrefix string
param aadProfileAdminGroupObjectIDs string
param deployBase bool = true

var baseResourceGroupName = '${prefix}-rg'

resource baseResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = if (deployBase) {
  name: baseResourceGroupName
  location: location
  tags: tags
}

module base 'base.bicep' = if (deployBase) {
  scope: baseResourceGroup
  name: 'base'
  params: {
    prefix: prefix
  }
}

var aksResourceGroupName = '${prefix}-${slot}-rg'
resource aksResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: aksResourceGroupName
  location: location
  tags: tags
}

module aks 'aks.bicep' = {
  scope: aksResourceGroup
  name: 'aks'
  params: {
    prefix: prefix
    slot: slot
    tenantId: tenantId
    vnetAddressPrefix: vnetAddressPrefix
    aksSubnetAddressPrefix: aksSubnetAddressPrefix
    aadProfileAdminGroupObjectIDs: aadProfileAdminGroupObjectIDs
    logAnalyticsWorkspaceId: base.outputs.logAnalyticsWorkspaceId
  }
}
