targetScope = 'subscription'

param environment string = 'dev'
param slot string = 'blue'
param vnetAddressPrefixBase string = '10.10'
param timestamp string = utcNow('ddMMyyyyhhmmss')

resource baseRg 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: 'iac-${environment}-rg'
  location: deployment().location
}

resource slotRg 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: 'iac-${environment}-${slot}-rg'
  location: deployment().location
}

module nsg 'nsg.bicep' = {
  name: 'nsg-${timestamp}'
  scope: slotRg
  params: {
    environment: environment
    slot: slot
    vnetAddressPrefixBase: vnetAddressPrefixBase
  }
}

module vnet 'vnet.bicep' = {
  name: 'vnet-${timestamp}'
  scope: slotRg
  dependsOn: [
    nsg
  ]
  params: {
    environment: environment
    slot: slot
    vnetAddressPrefixBase: vnetAddressPrefixBase
    aksNsgid: nsg.outputs.aksNsgId
  }
}
