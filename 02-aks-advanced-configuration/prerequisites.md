# Prerequisites

## Laptop / PC

Of course you need an laptop. OS installed at this laptop doesn't really matter. The tools we will use all work cross platforms. I will be using Windows 10 with ubuntu (WSL) as a shell.

## Microsoft Teams

Download and install [Microsoft Teams](https://products.office.com/en-US/microsoft-teams/group-chat-software)

## Visual Studio Community Edition

Please download and install Visual Studio Community edition. 
[Download Visual Studio Code](https://visualstudio.microsoft.com/downloads/) and make sure that `ASP.NET and web development` and `.NET Core cross-platform development` workloads are installed. If you have already installed Visual Studio, you can modify workload set from `Visual Studio Installer`.

![vs-workloads](images/vs-workloads.png)

## Install PowerShell core

If you are planning to use PowerShell as your shell, Download and install [PowerShell Core](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-windows?WT.mc_id=AZ-MVP-5003837&view=powershell-7.1)  

## Windows Terminal

Download and install [Windows Terminal](https://www.microsoft.com/en-us/p/windows-terminal/9n0dx20hk701?activetab=pivot:overviewtab&atc=true)

## Download and Install .NET 5.0

Download and install [.NET 5.0](https://dotnet.microsoft.com/download/dotnet/5.0)

## Docker

Download and install [Docker for Windows](https://docs.docker.com/docker-for-windows/install/)

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