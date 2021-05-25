param virtualNetworks_iac_dev_blue_vnet_name string = 'iac-dev-blue-vnet'
param networkSecurityGroups_iac_dev_blue_aks_nsg_externalid string = '/subscriptions/8878beb2-5e5d-4418-81ae-783674eea324/resourceGroups/iac-dev-blue-rg/providers/Microsoft.Network/networkSecurityGroups/iac-dev-blue-aks-nsg'

resource virtualNetworks_iac_dev_blue_vnet_name_resource 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: virtualNetworks_iac_dev_blue_vnet_name
  location: 'westeurope'
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
            id: networkSecurityGroups_iac_dev_blue_aks_nsg_externalid
          }
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'agw'
        properties: {
          addressPrefix: '10.10.16.0/25'
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
    virtualNetworkPeerings: []
    enableDdosProtection: false
  }
}

resource virtualNetworks_iac_dev_blue_vnet_name_agw 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  parent: virtualNetworks_iac_dev_blue_vnet_name_resource
  name: 'agw'
  properties: {
    addressPrefix: '10.10.16.0/25'
    delegations: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource virtualNetworks_iac_dev_blue_vnet_name_aks 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  parent: virtualNetworks_iac_dev_blue_vnet_name_resource
  name: 'aks'
  properties: {
    addressPrefix: '10.10.0.0/20'
    networkSecurityGroup: {
      id: networkSecurityGroups_iac_dev_blue_aks_nsg_externalid
    }
    delegations: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}