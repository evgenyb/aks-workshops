param environment string = 'dev'
param slot string = 'blue'
param vnetAddressPrefixBase string = '10.11'

var vnetAddressPrefix = '${vnetAddressPrefixBase}.0.0/16'
var aksSubnetAddressPrefix = '${vnetAddressPrefixBase}.0.0/20'
var testvmSubnetAddressPrefix = '${vnetAddressPrefixBase}.16.0/25'
var vnetName = 'iac-${environment}-${slot}-vnet' 

resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  location: resourceGroup().location
  name: vnetName
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'aks'    
        properties: {
          addressPrefix: aksSubnetAddressPrefix
        }      
      }
      {
        name: 'testVm'  
        properties: {
          addressPrefix: testvmSubnetAddressPrefix
        }      
      }
    ]
  }
}

resource aksSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  name: 'aks'    
  dependsOn: [
    vnet
  ]
  parent: vnet
  properties: {
    addressPrefix: aksSubnetAddressPrefix
  }
}

resource testvmSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  name: 'testVm'  
  dependsOn: [
    vnet
  ]
  parent: vnet
  properties: {
    addressPrefix: testvmSubnetAddressPrefix
  }
}

output aksSubnetAddressPrefix string = aksSubnetAddressPrefix
output vnetName string = vnetName
output aksSubnetId string = aksSubnet.id
