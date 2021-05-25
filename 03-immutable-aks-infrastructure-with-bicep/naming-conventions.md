# Naming conventions

We will use the following naming convention during this workshop.

Resource | Name | Example
------------ | ------------- | -------------
Base resource Group | iac-ws3-rg | iac-ws3-rg
SLot resource Group | iac-ws3-{slot name}-rg | iac-ws3-blue-rg, iac-ws3-green-rg
Storage Account | iacws3{storage account name}sa | iacws3evgsa
Private Virtual Network | iac-ws3-{vnet name}-vnet, iac-ws3-{env}-{slot}-vnet | iac-ws3-vnet, iac-ws3-blue-vnet, iac-ws3-green-vnet
Subnet | {subnet name}-net | aks-net, apim-net
Log Analytics Workspace | iac-ws3-{la name}-la | iac-ws3-evg-la
Public IP Prefix | iac-ws3-{prefix name}-la | iac-ws3-pip-prefix
Azure Container Registry | iacws3{acr name}acr | iacws3evgacr
Application Insights | iac-ws3-appinsights | iac-ws3-appinsights
API Management | iac-ws3-{apim name}-apim | iac-ws3-evg-apim
Public IP | iac-ws3-{public ip name}-pip | iac-ws3-aks-blue-egress2-pip
AKS | iac-ws3-{slot name}-aks | iac-ws3-blue-aks, iac-ws3-green-aks
User-Assigned Managed Identity | iac-ws3-{mi name}-mi or iac-ws3-{slot name}-{mi name}-mi | iac-ws3-api-b-mi, iac-ws3-api-a-mi, iac-ws3-blue-aks-mi, iac-ws3-green-aks-mi