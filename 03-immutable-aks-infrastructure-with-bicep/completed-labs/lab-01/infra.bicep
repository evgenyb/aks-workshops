resource aksNsg 'Microsoft.Network/networkSecurityGroups@2020-11-01' = {
  name: 'iac-dev-blue-aks-nsg'
  location: resourceGroup().location
  properties: {
    securityRules: [
      {
        name: 'deny-connection-from-agw'
        properties: {
          priority: 110
          direction: 'Inbound'
          access: 'Deny'
          description: 'Deny any connectivity from any vnets'
          protocol: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
          destinationAddressPrefix: '10.10.0.0/20'
          destinationPortRange: '*'
        }
      }
      {
        name: 'allow-connection-from-agw'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          description: 'Allow connectivity from agw subnet into aks subnet'
          protocol: 'Tcp'
          sourceAddressPrefix: '10.10.16.0/25'
          sourcePortRange: '*'
          destinationAddressPrefix: '10.10.0.0/20'
          destinationPortRange: '80'
        }
      }
    ]
  }  
}

resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  location: resourceGroup().location
  name: 'iac-dev-blue-vnet'
  dependsOn: [
    aksNsg
  ]
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.10.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'aks'    
        properties: {
          addressPrefix: '10.10.0.0/20'
          networkSecurityGroup: {
            id: aksNsg.id
          }
        }      
      }
      {
        name: 'agw'  
        properties: {
          addressPrefix: '10.10.16.0/25'
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
    addressPrefix: '10.10.0.0/20'
    networkSecurityGroup: {
      id: aksNsg.id
    }
  }
}

resource agwSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  name: 'agw'  
  dependsOn: [
    vnet
  ]
  parent: vnet
  properties: {
    addressPrefix: '10.10.16.0/25'
  }
}
