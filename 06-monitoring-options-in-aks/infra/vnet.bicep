param prefix string
param vnetAddressPrefix string
param aksSubnetAddressPrefix string
param agwSubnetAddressPrefix string
param location string

var vnetName = '${prefix}-vnet'

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: vnetName
  location: location
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
        name: 'agw'
        properties: {
          addressPrefix: agwSubnetAddressPrefix
        }
      }
    ]
  }
}

resource aksSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  name: 'aks'    
  parent: vnet
  properties: {
    addressPrefix: aksSubnetAddressPrefix
  }
}

resource agwSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  name: 'agw'    
  parent: vnet
  properties: {
    addressPrefix: agwSubnetAddressPrefix
  }
}

output aksSubnetId string = aksSubnet.id
output agwSubnetId string = agwSubnet.id
output vnetName string = vnet.name
