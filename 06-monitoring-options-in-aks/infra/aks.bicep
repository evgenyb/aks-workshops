param prefix string
param logAnalyticsWorkspaceId string 
param aksSubnetId string
param location string

var aksMIName = '${prefix}-aks-mi' 
var aksName = '${prefix}-aks'

resource aksMI 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: aksMIName
  location: location
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
    kubernetesVersion: '1.22.4'
    agentPoolProfiles: [
      {
        name: 'system'
        count: 2
        vmSize: 'Standard_DS2_v2'
        vnetSubnetID: aksSubnetId
        osType: 'Linux'
        mode: 'System'
        type: 'VirtualMachineScaleSets'
      }
    ]    
    networkProfile: {
      networkPlugin: 'azure'
      loadBalancerSku: 'standard'
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

output aksKubeletIdentityObjectId string = aks.properties.identityProfile.kubeletidentity.objectId
output aksMIPrincipalId string = aksMI.properties.principalId
