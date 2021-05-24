# lab-04 - refactoring: group resources using modules

## Estimated completion time - 15 min


If we will keep define all resources inside one Bicep template, you can imagine that your Bicep code will become more complex and hard to read, navigate and understand. Bicep has a concept called Modules that allows to make Bicep code more modularized. You can create individual Bicep files, called modules, for different parts of your deployment. The main Bicep template then can reference these modules. Modules are also a way to make Bicep code even more reusable. You can have a single Bicep module that lots of Bicep templates use.

You also will often need to emit outputs from the Bicep modules and templates. 

## Goals

In this lab you will learn:

* How to create Bicep module
* How to reference module from Bicep template
* How to use module output in Bicep template

## Task #1 - implement Network Security Group module 

Let's keep working with Bicep file from [lab-03](../lab-03/readme.md). If you didn't manage to finish it, use [infra.bicep](../../completed-labs/lab-03/infra.bicep) file from the completed labs folder.

Create new `nsg.bicep` file containing Bicep code for `aksNsg` resource from template we implemented at [lab-03](../lab-03/readme.md).

* Implement the following input parameters for this module: - `environment`, `slot` and `vnetAddressPrefixBase`
* Expose `aksNsg` resource id as a output parameter called `aksNsgId`

Your code should look something like this:

```yaml
param environment string = 'dev'
param slot string = 'blue'
param vnetAddressPrefixBase string = '10.10'

var aksNsgName = 'iac-${environment}-${slot}-aks-nsg' 
var aksSubnetAddressPrefix = '${vnetAddressPrefixBase}.0.0/20'
var agwSubnetAddressPrefix = '${vnetAddressPrefixBase}.16.0/25'

resource aksNsg 'Microsoft.Network/networkSecurityGroups@2020-11-01' = {
  name: aksNsgName
  location: resourceGroup().location
  properties: {
    securityRules: [
      {
        name: 'deny-connection-from-agw'
        properties: {
          priority: 110
          direction: 'Inbound'
          access: 'Deny'
          description: 'Deny any connectivity from any vnets'
          protocol: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
          destinationAddressPrefix: aksSubnetAddressPrefix
          destinationPortRange: '*'
        }
      }
      {
        name: 'allow-connection-from-agw'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          description: 'Allow connectivity from agw subnet into aks subnet'
          protocol: 'Tcp'
          sourceAddressPrefix: agwSubnetAddressPrefix
          sourcePortRange: '*'
          destinationAddressPrefix: aksSubnetAddressPrefix
          destinationPortRange: '80'
        }
      }
    ]
  }  
}

output aksNsgId string = aksNsg.id
```

## Task #2 - implement Private Virtual Network Group module 

Create new `vnet.bicep` file containing Bicep code for `vnet` resource from template we implemented at [lab-03](../lab-03/readme.md).
 
* Implement the following input parameters for this module: - `environment`, `slot`, `vnetAddressPrefixBase` and `aksNsgid` 
* Expose `aksSubnet` resource id as a output parameter called `aksSubnetId`
* Expose `agwSubnet` resource id as a output parameter called `agwSubnetId`

Your code should look something like this:

```yaml
param environment string = 'dev'
param slot string = 'blue'
param vnetAddressPrefixBase string = '10.10'
param aksNsgid string

var vnetName = 'iac-${environment}-${slot}-vnet' 
var vnetAddressPrefix = '${vnetAddressPrefixBase}.0.0/16'
var aksSubnetAddressPrefix = '${vnetAddressPrefixBase}.0.0/20'
var agwSubnetAddressPrefix = '${vnetAddressPrefixBase}.16.0/25'

resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  location: resourceGroup().location
  name: vnetName
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'aks'    
        properties: {
          addressPrefix: aksSubnetAddressPrefix
          networkSecurityGroup: {
            id: aksNsgid
          }
        }      
      }
      {
        name: 'agw'  
        properties: {
          addressPrefix: agwSubnetAddressPrefix
        }      
      }
    ]
  }
}

resource aksSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  name: 'aks'    
  dependsOn: [
    vnet
  ]
  parent: vnet
  properties: {
    addressPrefix: aksSubnetAddressPrefix
    networkSecurityGroup: {
      id: aksNsgid
    }
  }
}

resource agwSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  name: 'agw'  
  dependsOn: [
    vnet
  ]
  parent: vnet
  properties: {
    addressPrefix: agwSubnetAddressPrefix
  }
}

output aksSubnetId string = aksSubnet.id
output agwSubnetId string = agwSubnet.id
```

> Note! Because there is no NSG resource defined in this file there is no more `dependsOn` definition in the module and `aksNsgid` is provided as input parameter. Dependencies will be defined between modules instead in the master template fine. 

## Task #3 - implement Bicep template that uses modules

Now that we have implemented two modules, we can use them and implement our infra template.

Create new `infra.bicep` file with the following content:

```yaml
param environment string = 'dev'
param slot string = 'blue'
param vnetAddressPrefixBase string = '10.10'

module nsg 'nsg.bicep' = {
  name: 'nsg'
  params: {
    environment: environment
    slot: slot
    vnetAddressPrefixBase: vnetAddressPrefixBase
  }
}

module vnet 'vnet.bicep' = {
  name: 'vnet'
  dependsOn: [
    nsg
  ]
  params: {
    environment: environment
    slot: slot
    vnetAddressPrefixBase: vnetAddressPrefixBase
    aksNsgid: nsg.outputs.aksNsgId
  }
}
```

## Task #4 - verify refactoring

```bash
# Preview changes before deploying
az deployment group what-if -g iac-dev-blue-rg -f ./infra.bicep -p dev-blue.json
...
Resource and property changes are indicated with this symbol:
  = Nochange
...  
```
You should see no changes.

Finally, let's deploy our template.

```bash
# Deploy Bicep template
az deployment group create -g iac-dev-blue-rg -f ./vnet.bicep -p dev-blue.json
```

## Task #5 (optional) - refactoring: move code that compiles subnet address prefixes from modules to infra template

As you probably noticed, this code 

```yaml
var vnetAddressPrefix = '${vnetAddressPrefixBase}.0.0/16'
var aksSubnetAddressPrefix = '${vnetAddressPrefixBase}.0.0/20'
var agwSubnetAddressPrefix = '${vnetAddressPrefixBase}.16.0/25'
```

that compiles the `aks` and `agw` subnet address prefixes is now duplicated both at `vnet.bicep` and `nsg.bicep` modules. This is very bad practice and it needs to be fixed.
You need to refactor code and move this code to the `infra.bicep` file and do all necessary changes at all three files.  


## Useful links

* [Tutorial: Add modules to Azure Resource Manager Bicep file](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/bicep-tutorial-add-modules?tabs=azure-cli&WT.mc_id=AZ-MVP-5003837)
* [Bicep playground](https://bicepdemo.z22.web.core.windows.net/)

## Next: 

[Go to lab-05](../lab-05/readme.md)

## Feedback

* Visit the [Github Issue](https://github.com/evgenyb/aks-workshops/issues/29) to comment on this lab. 