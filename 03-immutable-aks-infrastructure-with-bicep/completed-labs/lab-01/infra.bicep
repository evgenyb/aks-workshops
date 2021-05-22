resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  location: 'westeurope'
  name: 'iac-dev-vnet'
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.10.0.0/16'
      ]
    }
    subnets: [
      {        
        name: 'apim'    
        properties: {
          addressPrefix: '10.10.0.0/27'
        }
      }
    ]
  }
}

resource apimSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  name: 'apim'    
  parent: vnet
  properties: {
    addressPrefix: '10.10.0.0/27'
  }
}

resource apim 'Microsoft.ApiManagement/service@2020-12-01' = {
  name: 'iac-dev-${uniqueString(resourceGroup().id)}-apim'
  location: resourceGroup().location
  sku: {
    name: 'Developer'
    capacity: 1
  }
  identity: {
    type: 'SystemAssigned'
  }
  dependsOn: [
    vnet
  ]
  properties: {
    virtualNetworkType: 'External'
    publisherEmail: 'Your Email Address'
    publisherName: 'Your name'
    virtualNetworkConfiguration: {
      subnetResourceId: apimSubnet.id
    }    
  }  
}
