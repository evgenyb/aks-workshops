targetScope = 'subscription'
param tags object

param location string
param prefix string
param vnetAddressPrefix string
param aksSubnetAddressPrefix string
param agwSubnetAddressPrefix string

var resourceGroupName = '${prefix}-rg'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

module appInsights 'appInsights.bicep' = {
  scope: resourceGroup
  name: 'appInsights'
  params: {
    prefix: prefix
    location: location
  }
}
module acr 'acr.bicep' = {
  scope: resourceGroup
  name: 'acr'
  params: {
    prefix: prefix
    location: location
  }
}

module logAnalytics 'logAnalytics.bicep' = {
  scope: resourceGroup
  name: 'logAnalytics'
  params: {
    prefix: prefix
    location: location
  }
}

module vnet 'vnet.bicep' = {
  scope: resourceGroup
  name: 'vnet'
  params: {
    prefix: prefix
    location: location
    vnetAddressPrefix: vnetAddressPrefix
    aksSubnetAddressPrefix: aksSubnetAddressPrefix
    agwSubnetAddressPrefix: agwSubnetAddressPrefix
  }
}

module aks 'aks.bicep' = {
  scope: resourceGroup
  name: 'aks'
  params: {
    prefix: prefix
    location: location
    aksSubnetId: vnet.outputs.aksSubnetId
    logAnalyticsWorkspaceId: logAnalytics.outputs.logAnalyticsWorkspaceId
  }
}

module aksRoles 'grantAKSPermissions.bicep' = {
  name: 'aksRoles'
  scope: resourceGroup
  params: {
    vnetName: vnet.outputs.vnetName
    principalId: aks.outputs.aksMIPrincipalId
  }
}

module acrToAks 'attachACRToAKS.bicep' = {
  scope: resourceGroup
  name: 'acrToAks'
  params: {
    acrName: acr.outputs.acrName
    aksKubeletIdentityObjectId: aks.outputs.aksKubeletIdentityObjectId
  }
}
