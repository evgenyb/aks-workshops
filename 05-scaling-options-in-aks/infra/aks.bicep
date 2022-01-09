param prefix string
param logAnalyticsWorkspaceId string 
param aksSubnetId string
param enableDiagnostics bool = false

var location = resourceGroup().location
var aksMIName = '${prefix}-aks-mi' 
var aksName = '${prefix}-aks'
var aksEgressPipName = '${prefix}-aks-egress-pip'

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
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${aksMI.id}': {}
    }
  }
  properties: {
    dnsPrefix: aksName
    enableRBAC: true    
    agentPoolProfiles: [
      {
        name: 'system'
        minCount: 1
        maxCount: 4
        count: 1
        vmSize: 'Standard_B2s'
        enableAutoScaling: true
        vnetSubnetID: aksSubnetId
        osType: 'Linux'
        mode: 'System'
        type: 'VirtualMachineScaleSets'
      }
    ]    
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'calico'
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
        enabled: enableDiagnostics
        config: {
          logAnalyticsWorkspaceResourceID: logAnalyticsWorkspaceId
        }
      }
    }
  }
}

output aksKubeletIdentityObjectId string = aks.properties.identityProfile.kubeletidentity.objectId
output aksMIPrincipalId string = aksMI.properties.principalId
