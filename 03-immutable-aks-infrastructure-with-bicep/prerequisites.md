# Prerequisites

## Laptop / PC

Of course you need an laptop. OS installed at this laptop doesn't really matter. The tools we will use all work cross platforms. I will be using Windows 10 with ubuntu (WSL) as a shell.

## Microsoft Teams

Download and install [Microsoft Teams](https://products.office.com/en-US/microsoft-teams/group-chat-software)


## Visual Studio Code

Please download and install VS Code. It's available for all platforms.
[Download Visual Studio Code](https://code.visualstudio.com/download)

## Azure Resource Manager (ARM) Tools plugin for VS Code

Install plugin from [marketplace](https://marketplace.visualstudio.com/items?itemName=msazurermtools.azurerm-vscode-tools) 

## Bicep plugin

Install Bicep plugin from [marketplace](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-bicep) 
 
## Windows Terminal

Download and install [Windows Terminal](https://www.microsoft.com/en-us/p/windows-terminal/9n0dx20hk701?activetab=pivot:overviewtab&atc=true)

## Active Azure account

If you don't have an Azure account, please create one before the workshop.
[Create your Azure free account](https://azure.microsoft.com/en-us/free/?WT.mc_id=AZ-MVP-5003837)

## Install `az cli`

Download and install latest version of `az cli` from this link  
[Install the Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest&WT.mc_id=AZ-MVP-5003837)

If you already have `az cli` installed, make sure that you use the latest version. To make sure, run the following command

```bash
az upgrade

This command is in preview and under development. Reference and support levels: https://aka.ms/CLI_refstatus
Your current Azure CLI version is 2.19.0. Latest version available is 2.19.1.
Please check the release notes first: https://docs.microsoft.com/cli/azure/release-notes-azure-cli
Do you want to continue? (Y/n): Y
```

## Test your azure account with `az cli`

Open your terminal (bash, cmd or powershell) and login to your azure account by running this command

```bash
# Login using your Azure account
az login

# Get a list of available subscriptions
az account list -o table

# Set subscription by subscription id
az account set --subscription  xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

# Set subscription by name
az account set --subscription subscription_name
```

## Register Microsoft.ContainerService Service provider to your Azure subscription

If you are deploying an AKS service for the first time in your subscription, you need to register the `Microsoft.ContainerService` service provider to avoid deployment errors.

```bash
# Register Microsoft.ContainerService provider
az provider register --namespace 'Microsoft.ContainerService'
```

## Create your Azure DevOps account

If you don't have an Azure DevOps, please create one before the workshop.
[Azure DevOps - start for free](https://azure.microsoft.com/en-gb/services/devops/)

## Create a new Project at Azure DevOps

Follow this [how-to guide](https://docs.microsoft.com/en-us/azure/devops/organizations/projects/create-project?view=azure-devops&tabs=preview-page) and create a new project called `iac-aks-ws3`. Feel free to use existing project, if you already have one.

## Create a new git repository

Create new git repository under your Azure DevOps project. Follow this [how-to guide](https://docs.microsoft.com/en-us/azure/devops/repos/git/create-new-repo?toc=%2Fazure%2Fdevops%2Forganizations%2Ftoc.json&bc=%2Fazure%2Fdevops%2Forganizations%2Fbreadcrumb%2Ftoc.json&view=azure-devops) and create a new repository called `immutable-aks`.

## Check that you have access to Azure DevOps

Try to login to your Azure DevOps Account. Use some time and get yourself familiar with this product. During the workshop we will use the following features of this product:

* [Repositories](https://docs.microsoft.com/en-gb/azure/devops/repos/get-started/what-is-repos?view=azure-devops) - here we will keep our source code
* [Pipelines](https://docs.microsoft.com/en-gb/azure/devops/pipelines/get-started/what-is-azure-pipelines?view=azure-devops) - all our build and release pipelines will be implemented here