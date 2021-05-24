targetScope = 'subscription'

param environment string = 'dev'
param slot string = 'blue'

resource baseRg 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: 'iac-${environment}-rg'
  location: deployment().location
}

resource slotRg 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: 'iac-${environment}-${slot}-rg'
  location: deployment().location
}
