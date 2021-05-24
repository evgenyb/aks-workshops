# lab-05 - scopes

## Estimated completion time - 15 min

A deployment in ARM has an associated scope, which dictates the scope that resources within that deployment are created in. There are various ways to deploy resources across multiple scopes today in ARM templates; this spec describes how similar functionality can be achieved in Bicep.

Unless otherwise specified, Bicep will assume that a given `.bicep` file is to be deployed at a resource group scope, and will validate resources accordingly. If you wish to change this scope, or define a file that can be deployed at multiple scopes, you must use the `targetScope` keyword with either a string or array value as follows:

## Goals

In this lab you will learn:

* How to configure module scopes
* How to create a resource group and deploy a module to the resource group

## Task #1 - create template file to create resource group

Create new `rg.bicep` file with the following content:

```yaml
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
```



## Task #2 - change the template scope to subscription

Let's keep working with Bicep file from [lab-04](../lab-04/readme.md). If you didn't manage to finish it, use [infra.bicep](../../completed-labs/lab-04/infra.bicep) file from the completed labs folder.




## Useful links

* [Tutorial: Add modules to Azure Resource Manager Bicep file](https://github.com/Azure/bicep/blob/main/docs/spec/resource-scopes.md)
* [Bicep playground](https://bicepdemo.z22.web.core.windows.net/)

## Next: 

[Go to lab-06](../lab-06/readme.md)

## Feedback

* Visit the [Github Issue](https://github.com/evgenyb/aks-workshops/issues/30) to comment on this lab. 