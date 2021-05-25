param environment string
param slot string
param agwSubnetid string

var agwName = 'iac-${environment}-${slot}-aks-agw' 
var agwPipName = 'iac-${environment}-${slot}-agw-pip'

resource agwPip 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: agwPipName
  location: resourceGroup().location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }

  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: 'iac-dev-blue-agw-pip'
    }
  }
}

resource agw 'Microsoft.Network/applicationGateways@2020-11-01' = {
  name: agwName
  location: resourceGroup().location
  dependsOn: [
    agwPip
  ]
  properties: {
    sku: {
      name: 'Standard_v2'
      tier: 'Standard_v2'
      capacity: 2
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayFrontendIP'
        properties: {
          subnet: {
            id: agwSubnetid
          }
        }
      }
    ]
    sslCertificates: []
    trustedRootCertificates: []
    trustedClientCertificates: []
    sslProfiles: []
    frontendIPConfigurations: [
      {
        name: 'appGatewayFrontendIP'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: agwPip.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'appGatewayFrontendPort'
        properties: {
          port: 80
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'appGatewayBackendPool'
        properties: {
          backendAddresses: []
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'appGatewayBackendHttpSettings'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          connectionDraining: {
            enabled: false
            drainTimeoutInSec: 1
          }
          pickHostNameFromBackendAddress: false
          requestTimeout: 30
        }
      }
    ]
    httpListeners: [
      {
        name: 'appGatewayHttpListener'
        properties: {
          frontendIPConfiguration: {
            id: '${resourceId('Microsoft.Network/applicationGateways', agwName)}/frontendIPConfigurations/appGatewayFrontendIP'
          }
          frontendPort: {
            id: '${resourceId('Microsoft.Network/applicationGateways', agwName)}/frontendPorts/appGatewayFrontendPort'
          }
          protocol: 'Http'
          hostNames: []
          requireServerNameIndication: false
        }
      }
    ]
    urlPathMaps: []
    requestRoutingRules: [
      {
        name: 'rule1'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: '${resourceId('Microsoft.Network/applicationGateways', agwName)}/httpListeners/appGatewayHttpListener'
          }
          backendAddressPool: {
            id: '${resourceId('Microsoft.Network/applicationGateways', agwName)}/backendAddressPools/appGatewayBackendPool'
          }
          backendHttpSettings: {
            id: '${resourceId('Microsoft.Network/applicationGateways', agwName)}/backendHttpSettingsCollection/appGatewayBackendHttpSettings'
          }
        }
      }
    ]
    probes: []
    rewriteRuleSets: []
    redirectConfigurations: []
    privateLinkConfigurations: []
  }
}
