# lab-07 - Loops

## Estimated completion time - 15 min

Loops may be used to iterate over an array to declare multiple resources/modules or to set an array property inside a resource/module declaration. Loops may also be used when defining variables. 

## Goals

In this lab you will learn:

* How to use loops to simplify your Bicep templates


## Task #1 - declare multiple user assigned managed identities 

I want to cerate User Assigned Manage identities that will be used by [aad-pod-identities](https://azure.github.io/aad-pod-identity/docs/). There might be more than hundred of managed identities. 
Let's implement Bicep template that will define each managed identity as a resource. To simplify our use case, let's imagine that we need to create three managed identities called `appa`, `appb` and `appc`. We also want to tag each of the managed identity with `owner` tag and use the name of the team owning the application. In this example that will be `team-a`, `team-b` and `team-c`.

Create new `infra.bicep` file with the following content:


```yaml
resource appaMI 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: 'appa'
  location: resourceGroup().location    
}

resource appbMI 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: 'appb'
  location: resourceGroup().location    
}

resource appcMI 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: 'appc'
  location: resourceGroup().location    
}
```

Let's preview what resources will be created if we deploy this template

```bash
# Preview deployment 
az deployment group what-if -g iac-dev-blue-rg  -f ./infra.bicep

 + Microsoft.ManagedIdentity/userAssignedIdentities/appa [2018-11-30]
      ...      
      name:       "appa"
      tags.owner: "team-a"
      type:       "Microsoft.ManagedIdentity/userAssignedIdentities"

  + Microsoft.ManagedIdentity/userAssignedIdentities/appb [2018-11-30]
      ...
      name:       "appb"
      tags.owner: "team-b"
      type:       "Microsoft.ManagedIdentity/userAssignedIdentities"

  + Microsoft.ManagedIdentity/userAssignedIdentities/appc [2018-11-30]
      ...
      name:       "appc"
      tags.owner: "team-c"
      type:       "Microsoft.ManagedIdentity/userAssignedIdentities"
```

You should see three new `userAssignedIdentities` resource expected to be created.

If you look at the Bicep template and imagine than there are more than hundreds of managed identities, you can imagine that will be quite long, noisy and hard to read and maintain.

## Task #2 - declare multiple user assigned managed identities using loops

Now let's see how we can simplify this template if we use loops. What we can do instead of hard-coding resources, is to introduce variable (or parameter) type of array and use loop functionality of Bicep to iteratively create managed identities.

Create new `infra-with-loops.bicep` file with the following content:

```yaml
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
```

Let's review this Bicep template. 

* There is `miArray` variable which contains an array of objects. Each object has two fields: `name` and `owner` representing managed identity name and the name of the team owning the application that is using this managed identity
* Then we are looping over `miArray` array. For each loop iteration, `uami` is set to the current array item and `uami.name` is referenced by `name` property and `uami.owner`  is referenced by tags in the loop body. 

Let's preview what resources will be created if we deploy this template

```bash
# Preview deployment 
az deployment group what-if -g iac-dev-blue-rg  -f .\infra-with-loops.bicep
```

You should see the same that it's expected that three new `userAssignedIdentities` resources to be created.

## Useful links

* [Bicep playground](https://bicepdemo.z22.web.core.windows.net/)
* [Loops](https://github.com/Azure/bicep/blob/main/docs/spec/loops.md)

## Next: Implement AKS infrastructure

[Go to lab-08](../lab-08/readme.md)

## Feedback

* Visit the [Github Issue](https://github.com/evgenyb/aks-workshops/issues/32) to comment on this lab. 