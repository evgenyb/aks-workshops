# lab-01 - create and deploy your first Bicep template

## Estimated completion time - 15 min

Bicep templates are the files that you author. They define the Azure resources to be deployed.
If you use Visual Studio Code with [Bicep plugin](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-bicep), then you use `.bicep` as a file extension. 

## Goals

In this lab you will learn:
* how to define a resource in a Bicep template
* how to generate ARM templates from Bicep template
* how to deploy Bicep template using `az cli`

## Task #1 - create resource group

As always, we start by creating new resource group. Let's name it `iac-ws3-blue-rg`.

```bash
# Create new resource group
az group create -n iac-ws3-blue-rg -l westeurope
```

## Task #2 - create Bicep template

Create `sa.bicep` file in Visual Studio Code with the content shown below. 

> Note, Storage Account is a global resource and its name has to be unique, therefore I suggest the following naming convention for Storage Account: `iacws3<YOUR-NAME>sa`, where `YOUR-NAME` is your short name, in my case, that will be `evg`. Please also keep in mind that Storage Account name length has a [limit](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftstorage) of 24 chars.

```yaml
resource sa 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: 'iacws3<YOURNAME>sa'
  location: 'westeurope'
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
  }
}
```

## Task #3 - generate ARM templates from bicep file

The Bicep CLI provides a command to convert Bicep to JSON. To generate a JSON file from your Bicep template, use:

```bash
# Generate ARM templates from Bicep template.
# Run this command from the folder containing your sa.bicep file.
az bicep build -f sa.bicep
```

If no errors, you should see the `sa.json` file with storage account ARM templates next to your `sa.bicep` template. 

> Note that you can use [Bicep playground](https://bicepdemo.z22.web.core.windows.net/) to view your ARM and Bicep templates side by side. 

## Task 4 - deploy Bicep template

Bicep files can be directly deployed via the `az cli` or PowerShell Az module, so the standard deployment commands (i.e. `az deployment group create` or `New-AzResourceGroupDeployment`) will "just work" with a .bicep file. You will need Az CLI version 2.20.0+ or PowerShell Az module version 5.6.0+.


```bash
# Deploy Bicep template to a resource group
az deployment group create -g iac-ws3-blue-rg -f ./sa.bicep
```

If you go to to `Deployment` tab of the `iac-ws3-blue-rg` resource group you should see new deployment running. Open it and check `Template` section and you will see that it contains standard ARM templates. 

![arm](images/deployments-arm.png)

## Useful links

* [What is Bicep](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/bicep-overview/?WT.mc_id=AZ-MVP-5003837)
* [Tutorial: Create and deploy first Azure Resource Manager Bicep file](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/bicep-tutorial-create-first-bicep?tabs=azure-cli&WT.mc_id=AZ-MVP-5003837)
* [Bicep playground](https://bicepdemo.z22.web.core.windows.net/)

## Next: working with variables

[Go to lab-02](../lab-02/readme.md)

## Feedback

* Visit the [Github Issue](https://github.com/evgenyb/aks-workshops/issues/26) to comment on this lab. 