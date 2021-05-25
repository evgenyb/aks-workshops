resource appaMI 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: 'appa'
  location: resourceGroup().location    
  tags: {
    owner: 'team-a'
  }
}

resource appbMI 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: 'appb'
  location: resourceGroup().location    
  tags: {
    owner: 'team-b'
  }
}

resource appcMI 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: 'appc'
  location: resourceGroup().location    
  tags: {
    owner: 'team-c'
  }
}
