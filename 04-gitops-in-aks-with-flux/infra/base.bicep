param prefix string = 'iac-ws4'

var location = resourceGroup().location
var vnetName = '${prefix}-vnet'
var prefixForACR = replace(prefix, '-', '')
var acrName = '${prefixForACR}acr'
var bastionPIPName = '${prefix}-bastion-pip'
var bastionName = '${prefix}-bastion'
var bastionSubnetName = 'AzureBastionSubnet'
var bastionSubnetIpPrefix = '10.10.0.0/27'
var azurefirewallPIPName = '${prefix}-afw-pip'
var azurefirewallSubnetName = 'AzureFirewallSubnet'
var azurefirewallSubnetIpPrefix = '10.10.0.64/26'

var logAnalyticsWorkspaceName = '${prefix}-${uniqueString(subscription().subscriptionId)}-la'
var logAnalyticsRetentionInDays = 60

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.10.0.0/16'
      ]
    }
    subnets: [
      {
        name: bastionSubnetName
        properties: {
          addressPrefix: bastionSubnetIpPrefix
        }
      }
      {
        name: azurefirewallSubnetName
        properties: {
          addressPrefix: azurefirewallSubnetIpPrefix
        }
      }
    ]
  }
}

resource bastionSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  name: bastionSubnetName    
  dependsOn: [
    vnet
  ]
  parent: vnet
  properties: {
    addressPrefix: bastionSubnetIpPrefix
  }
}

resource afwSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  name: azurefirewallSubnetName    
  dependsOn: [
    vnet
  ]
  parent: vnet
  properties: {
    addressPrefix: azurefirewallSubnetIpPrefix
  }
}

resource bastionPublicIp 'Microsoft.Network/publicIpAddresses@2020-05-01' = {
  name: bastionPIPName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource afwPublicIp 'Microsoft.Network/publicIpAddresses@2020-05-01' = {
  name: azurefirewallPIPName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastion 'Microsoft.Network/bastionHosts@2021-02-01' = {
  name: bastionName  
  location: location
  sku: {
    name: 'Basic'
  }
  dependsOn: [
    vnet
  ] 
  properties: {
    ipConfigurations: [
      {
        name: 'IpConfiguration'
        properties: {
          publicIPAddress: {
            id: bastionPublicIp.id
          }
          subnet: {
            id: bastionSubnet.id
          }
        }
      }
    ]
  }
}

resource acr 'Microsoft.ContainerRegistry/registries@2020-11-01-preview' = {
  name: acrName
  location: location
  sku: {
    name: 'Basic'
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: logAnalyticsRetentionInDays
  }
}

output acrId string = acr.id
output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.id
