#!/usr/bin/env bash

# Set your user name for global resources (LogAnalytics, AppInsight, APIM etc...)
YOUR_NAME="evg"
YOUR_AAD_NAME="evgeny.borzenin_gmail.com#EXT#@evgenyborzeningmail.onmicrosoft.com"

# Create AKS resource group
echo -e "Create iac-ws2-aks-blue-rg resource group"
az group create -g iac-ws2-aks-blue-rg -l westeurope 

# Create AKS Vnet
echo -e "Create iac-ws2-aks-blue-vnet VNet"
az network vnet create -g iac-ws2-aks-blue-rg -n iac-ws2-aks-blue-vnet --address-prefix "10.11.0.0/16" --subnet-name aks-net --subnet-prefix "10.11.0.0/20"

# Get base VNet Id
BASE_VNET_ID="$(az network vnet show -g iac-ws2-base-rg -n iac-ws2-base-vnet --query id -o tsv)"

# Establish VNet peering from AKS VNet to base VNet
echo -e "Peering iac-ws2-aks-blue-vnet with iac-ws2-base-vnet"
az network vnet peering create -g iac-ws2-aks-blue-rg -n aks-blue-to-base --vnet-name iac-ws2-aks-blue-vnet --allow-vnet-access --allow-forwarded-traffic --remote-vnet $BASE_VNET_ID

# Get AKS VNet ID
AKS_BLUE_VNET_ID="$(az network vnet show -g iac-ws2-aks-blue-rg -n iac-ws2-aks-blue-vnet --query id -o tsv)"

# Establish VNet peering from base VNet to AKS VNet
echo -e "Peering iac-ws2-base-vnet with iac-ws2-aks-blue-vnet"
az network vnet peering create -g iac-ws2-base-rg -n base-to-aks-blue --vnet-name iac-ws2-base-vnet --allow-vnet-access --allow-forwarded-traffic --remote-vnet $AKS_BLUE_VNET_ID

# Get workspace resource id
WORKSPACE_ID="$(az monitor log-analytics workspace show -g iac-ws2-base-rg -n iac-ws2-${YOUR_NAME}-la --query id -o tsv)"

# Create Azure AD group iac-ws2
echo -e "Create Azure AD group iac-ws2"
az ad group create --display-name iac-ws2 --mail-nickname iac-ws2

# Get your user Azure AD objectId 
USER_ID="$(az ad user show --id "${YOUR_AAD_NAME}" --query objectId -o tsv)"

# Add user into iac-ws2 Azure AD group. Use object Id from previous query 
echo -e "Add user ${USER_ID} into iac-ws2 AAD group"
az ad group member add -g iac-ws2 --member-id ${USER_ID}

# Get iac-ws2 Azure AD group id)
ADMIN_GROUP_ID="$(az ad group show -g iac-ws2 --query objectId -o tsv)"

# Get subnet Id
SUBNET_ID="$(az network vnet subnet show -g iac-ws2-aks-blue-rg --vnet-name iac-ws2-aks-blue-vnet -n aks-net --query id -o tsv)"

# Create user assigned managed identity
echo -e "Create User Assigned Managed Identity iac-ws2-aks-blue-mi"
az identity create --name iac-ws2-aks-blue-mi --resource-group iac-ws2-aks-blue-rg

# Get managed identity ID
MANAGED_IDENTITY_ID="$(az identity show --name iac-ws2-aks-blue-mi --resource-group iac-ws2-aks-blue-rg --query id -o tsv)"

# Create AKS cluster
echo -e "Create AKS cluster aks-ws2-blue"
az aks create -g iac-ws2-aks-blue-rg -n aks-ws2-blue \
    --nodepool-name systempool  \
    --node-count 1 \
    --max-pods 110 \
    --enable-aad --aad-admin-group-object-ids ${ADMIN_GROUP_ID} \
    --kubernetes-version 1.19.6 \
    --network-plugin azure \
    --network-policy calico \
    --vm-set-type VirtualMachineScaleSets \
    --docker-bridge-address 172.17.0.1/16 \
	--enable-managed-identity \
    --assign-identity ${MANAGED_IDENTITY_ID} \
    --vnet-subnet-id ${SUBNET_ID} \
    --no-ssh-key \
    --attach-acr iacws2${YOUR_NAME}acr \
    --enable-addons monitoring --workspace-resource-id ${WORKSPACE_ID}