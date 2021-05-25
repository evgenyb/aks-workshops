targetScope = 'subscription'

param environment string = 'dev'
param slot string = 'blue'
param vnetAddressPrefixBase string = '10.10'

var rgName = 'iac-${environment}-${slot}-rg'

resource rg 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: rgName
  location: deployment().location
}

module vnet 'vnet.bicep' = {
  name: 'vnet'
  scope: rg
  params: {
    environment: environment
    slot: slot
    vnetAddressPrefixBase: vnetAddressPrefixBase
  }
}

module agw 'agw.bicep' = {
  name: 'agw'
  scope: rg
  dependsOn: [
    vnet
  ]
  params: {
    environment: environment
    slot: slot
    agwSubnetid: vnet.outputs.agwSubnetId
  }
}

module aks 'aks.bicep' = {
  name: 'aks'
  scope: rg
  dependsOn: [
    vnet
    agw
  ]
  params: {
    environment: environment
    slot: slot
    aksSubnetid: vnet.outputs.aksSubnetId
  }
}
