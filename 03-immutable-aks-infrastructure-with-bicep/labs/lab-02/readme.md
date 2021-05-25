# lab-02 - working with variables and parameters

## Estimated completion time - 15 min

### Variables
A variable is defined and set within the template. Variables let you store important information in one place and refer to it throughout the template, without having to copy and paste it. Variables are usually a good option when you'll use the same values for each deployment, but you want to make a value reusable within the template, or you want to use expressions to create a complex value. You can also use variables for the names of resources that don't need unique names.

### Parameters

A parameter lets you bring values in from outside the template file. For example, if you deploying the template by using the `az cli`, you'll be asked to provide values for each parameter. You can also create a parameter file, which lists all of the parameters and values used by the template. 

## Goals

In this lab you will learn:

 * How to define and use variables
 * How to define and use parameters
 * How to work with parameters file

Let's continue with template we started at [lab-01](../lab-01/readme.md). As you can see, the vnet and subnet address ranges are repeated several times within template. We can easily fix it if we use variables instead.

## Task #1 - introduce address prefix variables

Let's introduce variables for vnet and subnet address prefix values.
You can define variables like this:

```yaml
var vnetAddressPrefix = '10.10.0.0/16'
var aksSubnetAddressPrefix = '10.10.0.0/20'
var agwSubnetAddressPrefix = '10.10.16.0/25'
```

> Note! Variables don't need types. Bicep can work out the type based on the value that you set.

You can now use variables inside the template. Replace all hardcoded values with corresponding variables.

Let's test that we haven't introduced any changes with our refactoring. To preview changes before deploying a template, you can use [az deployment group what-if](https://docs.microsoft.com/en-us/cli/azure/deployment/group?WT.mc_id=AZ-MVP-5003837&view=azure-cli-latest#az_deployment_group_what_if)

```bash
# Preview changes before deploying
az deployment group what-if -g iac-dev-blue-rg -f ./infra.bicep
...
Resource and property changes are indicated with this symbol:
  = Nochange
...  
```
You should see no changes.

## Task #2 - introduce base vnet address prefix variable

Now, let's extract the base address prefix `10.10` as a individual variable:

```yaml
var vnetAddressPrefixBase = '10.10'
```

Now we can refactor the remaining variables using base address and string interpolation:

```yaml
var vnetAddressPrefixBase = '10.10'
var vnetAddressPrefix = '${vnetAddressPrefixBase}.0.0/16'
var aksSubnetAddressPrefix = '${vnetAddressPrefixBase}.0.0/20'
var agwSubnetAddressPrefix = '${vnetAddressPrefixBase}.16.0/25'
```

> Notice the string interpolation uses the syntax of `${<expression>}` to define the expression that defines the value to place in that location within the string. The expression within can be as simple as a variable or parameter name, or even the use of a built-in function to retrieve another value.

```bash
# Preview changes before deploying
az deployment group what-if -g iac-dev-blue-rg -f ./infra.bicep
...
Resource and property changes are indicated with this symbol:
  = Nochange
...  
```
You should see no changes.

## Task #3 - use variable to implement naming convention for resource names

Let's introduce two new variables `environment` and `slot` and use string interpolation to build resource names followed our [naming conventions](../../naming-convention.md). For VNet that would be - `iac-{env}-{slot}-vnet` and for NSG - `iac-{env}-{slot}-{nsgName}-nsg`

```yaml
var environment = 'dev'
var slot = 'blue'

var aksNsgName = 'iac-${environment}-${slot}-aks-nsg' 
var vnetName = 'iac-${environment}-${slot}-vnet' 
```

and replace hard-coded VNet and NSG names with `vnetName` and `aksNsgName` variables.

Now, let's review our changes.

```bash
# Preview changes before deploying
az deployment group what-if -g iac-dev-blue-rg -f ./infra.bicep
...
Resource and property changes are indicated with this symbol:
  = Nochange
...  
```
You should see no changes.

## Task #4 - refactoring: replace `environment`, `slot` and `vnetAddressPrefixBase` variables with parameters

We can re-use this template and deploy it to different environments. We can do so by changing `environment`, `slot` and `vnetAddressPrefixBase` variables into parameters and send environment specific values in from outside the template file. 

In Bicep, you can define a parameter like this:

```yaml
param environment string
param slot string
param vnetAddressPrefixBase string
```

If you try to review the changes, you will be prompted to provide all three parameters. Use `dev`, `blue` and `10.10` values.

```bash
# No parameters specified
az deployment group what-if -g iac-dev-blue-rg -f ./infra.bicep
Please provide string value for 'environment' (? for help): dev
Please provide string value for 'slot' (? for help): blue
Please provide string value for 'vnetAddressPrefixBase' (? for help): 10.10
...
Resource and property changes are indicated with this symbol:
  = Nochange
```

You can specify default values for the parameter like this:

```yaml
param environment string = 'dev'
param slot string = 'blue'
param vnetAddressPrefixBase string = '10.10'
```

If review the changes now, you will not be prompted to provide all three parameters:

```bash
# No parameters specified
az deployment group what-if -g iac-dev-blue-rg -f ./infra.bicep
...
Resource and property changes are indicated with this symbol:
  = Nochange
...
```

You can provide parameters from `az cli` command line by specifying a set of `-p parameterName=parameterValue` flags:

```bash
# Specify parameters from command line
az deployment group what-if -g iac-dev-blue-rg -f ./infra.bicep -p environment=dev -p slot=blue -p vnetAddressPrefixBase=10.10
...
Resource and property changes are indicated with this symbol:
  = Nochange
```

## Task #5 - use parameters file

 In the previous lab, we used inline parameters with our deployment command. This approach works for testing, but when automating deployments it can be easier to pass a set of values for our environment. Parameter files make it easier to package parameter values for a specific environment. 

 Parameter file is JSON file with a structure that is similar to JSON templates. In the file, you provide the parameter values you want to pass in during deployment.

 Create `dev-blue.json` file with the following content:

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "environment": {
            "value": "dev"
        },
        "slot": {
            "value": "blue"
        },
        "vnetAddressPrefixBase": {
            "value": "10.11"
        }
    }
}
```

You specify parameters file by using `-p parameter.json` flag of `az deployment group ...` commands.

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
az deployment group create -g iac-dev-blue-rg -f ./infra.bicep -p dev-blue.json
```

## Useful links

* [Tutorial: Add parameters to Azure Resource Manager Bicep file](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/bicep-tutorial-add-parameters?tabs=azure-cli&WT.mc_id=AZ-MVP-5003837)
* [Tutorial: Add variables to Azure Resource Manager Bicep file](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/bicep-tutorial-add-variables?tabs=azure-cli&WT.mc_id=AZ-MVP-5003837)
* [Tutorial: Use parameter files to deploy Azure Resource Manager Bicep file](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/bicep-tutorial-use-parameter-file?tabs=azure-cli&WT.mc_id=AZ-MVP-5003837)
* [Bicep playground](https://bicepdemo.z22.web.core.windows.net/)

## Next: Outputs

[Go to lab-03](../lab-03/readme.md)

## Feedback

* Visit the [Github Issue](https://github.com/evgenyb/aks-workshops/issues/27) to comment on this lab. 