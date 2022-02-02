# Prerequisites

## Laptop / PC

Of course you need an laptop. OS installed at this laptop doesn't really matter. The tools we will use all work cross platforms. I will be using Windows 10 with ubuntu (WSL) as a shell.

## Microsoft Teams

Download and install [Microsoft Teams](https://products.office.com/en-US/microsoft-teams/group-chat-software)

## Visual Studio Code

Please download and install VS Code. It's available for all platforms.
[Download Visual Studio Code](https://code.visualstudio.com/download)

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

## Install Helm cli

```bash
# Install helm for Mac
brew install helm

# Install helm with choco
choco install kubernetes-helm
```

## Register Microsoft.ContainerService Service provider to your Azure subscription

If you are deploying an AKS service for the first time in your subscription, you need to register the `Microsoft.ContainerService` service provider to avoid deployment errors.

```bash
# Register Microsoft.ContainerService provider
az provider register --namespace 'Microsoft.ContainerService'
```

## Register Microsoft.OperationsManagement Service provider to your Azure subscription

If you are deploying an AKS service for the first time in your subscription, you need to register the `Microsoft.OperationsManagement` service provider to avoid deployment errors.

```bash
# Register Microsoft.OperationsManagement provider
az provider register --namespace 'Microsoft.OperationsManagement'
```

## Install git

```bash
# Install helm for Mac
brew install git

# Install helm with choco
choco install git
```