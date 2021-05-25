# Naming conventions

We will use the following naming convention during this workshop.

Resource | Name | Example
------------ | ------------- | -------------
Base resource Group | iac-dev-rg | iac-dev-rg
SLot resource Group | iac-dev-{slot name}-rg | iac-dev-blue-rg, iac-dev-green-rg
Storage Account | iacdev{storage account name}sa | iacdevevgsa
Private Virtual Network | iac-dev-{vnet name}-vnet, iac-dev-{env}-{slot}-vnet | iac-dev-vnet, iac-dev-blue-vnet, iac-dev-green-vnet
Subnet | {subnet name}-net | aks-net, apim-net
Log Analytics Workspace | iac-dev-{la name}-la | iac-dev-evg-la
Public IP Prefix | iac-dev-{prefix name}-la | iac-dev-pip-prefix
Azure Container Registry | iacdev{acr name}acr | iacdevevgacr
Application Insights | iac-dev-appinsights | iac-dev-appinsights
API Management | iac-dev-{apim name}-apim | iac-dev-evg-apim
Public IP | iac-dev-{public ip name}-pip | iac-dev-aks-blue-egress2-pip
AKS | iac-dev-{slot name}-aks | iac-dev-blue-aks, iac-dev-green-aks
User-Assigned Managed Identity | iac-dev-{mi name}-mi or iac-dev-{slot name}-{mi name}-mi | iac-dev-api-b-mi, iac-dev-api-a-mi, iac-dev-blue-aks-mi, iac-dev-green-aks-mi