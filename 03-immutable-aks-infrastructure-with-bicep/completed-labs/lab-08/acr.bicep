param environment string = 'dev'

var acrName = 'iac${environment}${uniqueString(resourceGroup().id)}acr'

resource scr 'Microsoft.ContainerRegistry/registries@2020-11-01-preview' = {
  name: acrName
  location: resourceGroup().location
  sku: {
    name: 'Basic'
  }
}

