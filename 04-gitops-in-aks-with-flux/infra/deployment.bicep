targetScope = 'subscription'
param tags object

param location string
param prefix string = 'iac-ws4'
param slot string = 'blue'
param vnetAddressPrefix string
param aksSubnetAddressPrefix string

var baseResourceGroupName = '${prefix}-rg'

resource baseResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: baseResourceGroupName
  location: location
  tags: tags
}

module base 'base.bicep' = {
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
    vnetAddressPrefix: vnetAddressPrefix
    aksSubnetAddressPrefix: aksSubnetAddressPrefix
    logAnalyticsWorkspaceId: base.outputs.logAnalyticsWorkspaceId
  }
}
