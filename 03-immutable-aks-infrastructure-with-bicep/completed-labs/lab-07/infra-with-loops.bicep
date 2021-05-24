var miArray = [
  {
    name: 'appa'
    owner: 'team-a'
  }
  {
    name: 'appb'
    owner: 'team-b'
  }
  {
    name: 'appc'
    owner: 'team-c'
  }
]

resource mi 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = [for uami in miArray: {
  name: uami.name
  location: resourceGroup().location
  tags: {
    owner: uami.owner
  }  
}]
