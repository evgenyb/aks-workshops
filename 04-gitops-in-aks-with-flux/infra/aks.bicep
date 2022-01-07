param prefix string = 'iac-ws4'
param slot string = 'blue'
param vnetAddressPrefix string = '10.11.0.0/16'
param aksSubnetAddressPrefix string = '10.11.0.0/23'
param logAnalyticsWorkspaceId string 

var location = resourceGroup().location
var prefixWithSlot = '${prefix}-${slot}'
var vnetName = '${prefixWithSlot}-vnet'
var aksMIName = '${prefixWithSlot}-aks-mi' 
var aksName = '${prefixWithSlot}-aks'
var aksEgressPipName = '${prefixWithSlot}-aks-egress-pip'
var nodeResourceGroupName = '${prefixWithSlot}-aks-rg'
var networkContributorRoleId = '4d97b98b-1d4f-4787-a291-c67834d212e7'

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
    ]
  }
}

resource aksSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  name: 'aks'    
  dependsOn: [
    vnet
  ]
  parent: vnet
  properties: {
    addressPrefix: aksSubnetAddressPrefix
  }
}

resource aksMI 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: aksMIName
  location: location
}

resource aksEgressPip 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: aksEgressPipName
  location: location  
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource aks 'Microsoft.ContainerService/managedClusters@2021-05-01' = {
  name: aksName
  location: location
  dependsOn: [
    vnet
    aksMI
    aksEgressPip
  ]
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${aksMI.id}': {}
    }
  }
  properties: {
    dnsPrefix: aksName
    enableRBAC: true    
    nodeResourceGroup: nodeResourceGroupName
    agentPoolProfiles: [
      {
        name: 'system'
        count: 2
        vmSize: 'Standard_B2s'
        vnetSubnetID: aksSubnet.id
        osType: 'Linux'
        mode: 'System'
        type: 'VirtualMachineScaleSets'
      }
    ]    
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'azure'
      loadBalancerSku: 'standard'
      loadBalancerProfile: {
        outboundIPs: {
          publicIPs: [
            {
              id: aksEgressPip.id  
            }
          ]
        }
      } 
    }
    addonProfiles: {
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: logAnalyticsWorkspaceId
        }
      }
    }
  }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  scope: aksSubnet
  name: guid(aksSubnet.id, networkContributorRoleId)  
  properties: {
    principalId: aksMI.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', networkContributorRoleId)
  }
  dependsOn: [
    aksSubnet
    aksMI
    aks
  ]
}
