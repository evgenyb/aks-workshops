param prefix string

var location = resourceGroup().location
var uniqueStr = uniqueString(subscription().subscriptionId, resourceGroup().id)
var logAnalyticsWorkspaceName = '${prefix}-${uniqueStr}-la'

var logAnalyticsRetentionInDays = 60

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

output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.id
