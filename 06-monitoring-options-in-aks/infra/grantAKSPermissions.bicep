param vnetName string
param principalId string 

var networkContributorRoleId = '4d97b98b-1d4f-4787-a291-c67834d212e7'

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: vnetName    
}

resource aksSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  name: 'aks'    
  parent: vnet
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  scope: aksSubnet
  name: guid(aksSubnet.id, networkContributorRoleId)  
  properties: {
    principalId: principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', networkContributorRoleId)
  }
}
