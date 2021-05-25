param environment string = 'dev'
param slot string = 'blue'

var fdName = 'iac-${environment}-${uniqueString(resourceGroup().id)}-fd'
var agwPipName = 'iac-${environment}-${slot}-agw-pip'
var slotRG = 'iac-${environment}-${slot}-rg'

resource agwPip 'Microsoft.Network/publicIPAddresses@2020-11-01' existing = { 
  name: agwPipName
  scope: resourceGroup(slotRG)
}

resource fd 'Microsoft.Network/frontdoors@2020-05-01' = {
  name: fdName
  location: 'Global'
  properties: {
    resourceState: 'Enabled'
    backendPools: [
      {
        id: '${resourceId('Microsoft.Network/frontdoors', fdName)}/BackendPools/aks'
        name: 'aks'
        properties: {
          backends: [
            {
              address: agwPip.properties.ipAddress
              httpPort: 80
              httpsPort: 443
              priority: 1
              weight: 50
              backendHostHeader: agwPip.properties.ipAddress
              enabledState: 'Enabled'
            }
          ]
          healthProbeSettings: {
            id: '${resourceId('Microsoft.Network/frontdoors', fdName)}/HealthProbeSettings/healthProbeSettings-1621805921394'
          }
          loadBalancingSettings: {
            id: '${resourceId('Microsoft.Network/frontdoors', fdName)}/LoadBalancingSettings/loadBalancingSettings-1621805921394'
          }
          resourceState: 'Enabled'
        }
      }
    ]
    healthProbeSettings: [
      {
        id: '${resourceId('Microsoft.Network/frontdoors', fdName)}/HealthProbeSettings/healthProbeSettings-1621805921394'
        name: 'healthProbeSettings-1621805921394'
        properties: {
          intervalInSeconds: 30
          path: '/'
          protocol: 'Http'
          resourceState: 'Enabled'
          enabledState: 'Enabled'
          healthProbeMethod: 'HEAD'
        }
      }
    ]
    frontendEndpoints: [
      {
        id: '${resourceId('Microsoft.Network/frontdoors', fdName)}/FrontendEndpoints/${fdName}-azurefd-net'
        name: '${fdName}-azurefd-net'
        properties: {
          hostName: '${fdName}.azurefd.net'
          sessionAffinityEnabledState: 'Disabled'
          sessionAffinityTtlSeconds: 0
          resourceState: 'Enabled'
        }
      }
    ]
    loadBalancingSettings: [
      {
        id: '${resourceId('Microsoft.Network/frontdoors', fdName)}/LoadBalancingSettings/loadBalancingSettings-1621805921394'
        name: 'loadBalancingSettings-1621805921394'
        properties: {
          additionalLatencyMilliseconds: 0
          sampleSize: 4
          successfulSamplesRequired: 2
          resourceState: 'Enabled'
        }
      }
    ]
    routingRules: [
      {
        id: '${resourceId('Microsoft.Network/frontdoors', fdName)}/RoutingRules/rule1'
        name: 'rule1'
        properties: {
          frontendEndpoints: [
            {
              id: '${resourceId('Microsoft.Network/frontdoors', fdName)}/FrontendEndpoints/${fdName}-azurefd-net'
            }
          ]
          acceptedProtocols: [
            'Http'
            'Https'
          ]
          patternsToMatch: [
            '/*'
          ]
          enabledState: 'Enabled'
          resourceState: 'Enabled'
          routeConfiguration: {
            '@odata.type': '#Microsoft.Azure.FrontDoor.Models.FrontdoorForwardingConfiguration'
            forwardingProtocol: 'HttpOnly'
            backendPool: {
              id: '${resourceId('Microsoft.Network/frontdoors', fdName)}/backendPools/aks'
            }
          }
        }
      }
    ]
    backendPoolsSettings: {
      enforceCertificateNameCheck: 'Enabled'
      sendRecvTimeoutSeconds: 30
    }
    enabledState: 'Enabled'
    friendlyName: fdName
  }
}
