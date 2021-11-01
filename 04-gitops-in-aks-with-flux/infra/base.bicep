param prefix string = 'iac-ws4'

var location = resourceGroup().location
var prefixForACR = replace(prefix, '-', '')
var acrName = '${prefixForACR}acr'

var logAnalyticsWorkspaceName = '${prefix}-${uniqueString(subscription().subscriptionId)}-la'
var logAnalyticsRetentionInDays = 60

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
