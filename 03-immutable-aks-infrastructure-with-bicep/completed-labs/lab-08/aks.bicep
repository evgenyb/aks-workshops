param environment string
param slot string
param aksSubnetid string

var aksName = 'iac-${environment}-${slot}-aks' 

resource aks 'Microsoft.ContainerService/managedClusters@2021-03-01' = {
  location: resourceGroup().location
  name: aksName
  identity: {
    type: 'SystemAssigned'
  }
  properties: { 
    dnsPrefix: aksName
    enableRBAC: true
    networkProfile: {
      networkPlugin: 'azure'
      loadBalancerSku: 'standard'
      networkPolicy: 'calico'            
    }    
    agentPoolProfiles: [
      {
        name: 'system'
        count: 1
        vmSize: 'Standard_D4_v3'
        mode: 'System'
        vnetSubnetID: aksSubnetid
      }
    ]
  }
}
