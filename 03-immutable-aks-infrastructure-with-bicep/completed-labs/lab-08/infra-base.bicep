targetScope = 'subscription'

param environment string = 'dev'
param slot string = 'blue'

var rgName = 'iac-${environment}-rg'

resource rg 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: rgName
  location: deployment().location
}

module fd 'fd.bicep' = {
  name: 'fd'
  scope: rg
  params: {
    environment: environment
    slot: slot
  }
}

module acr 'acr.bicep' = {
  name: 'acr'
  scope: rg
  params: {
    environment: environment
  }
}


