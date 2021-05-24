param environment string = 'dev'
param slot string = 'blue'
param vnetAddressPrefixBase string = '10.10'

module nsg 'nsg.bicep' = {
  name: 'nsg'
  params: {
    environment: environment
    slot: slot
    vnetAddressPrefixBase: vnetAddressPrefixBase
  }
}

module vnet 'vnet.bicep' = {
  name: 'vnet'
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
