#!/usr/bin/env bash
#
# usage: provision-aks.sh ws2 green 10.12.0.0

AKS_PREFIX=$1
SLOT=$2
VNET_ADDRESS_PREFIX=$3

RESOURCE_GROUP_NAME="iac-${AKS_PREFIX}-aks-${SLOT}-rg"
AKS_NAME="aks-${AKS_PREFIX}-${SLOT}"
VNET_NAME="iac-${AKS_PREFIX}-aks-${SLOT}-vnet"
BASE_RESOURCE_GROUP="iac-${AKS_PREFIX}-base-rg"
BASE_VNET_NAME="iac-${AKS_PREFIX}-base-vnet"
MANAGED_IDENTITY_NAME="iac-${AKS_PREFIX}-aks-${SLOT}-mi"
PEERING_TO_BASE_NAME="aks-${SLOT}-to-base"
PEERING_TO_AKS_NAME="base-to-aks-${SLOT}"

# Set your user name for global resources (LogAnalytics, AppInsight, APIM etc...)
YOUR_NAME="evg"
YOUR_AAD_NAME="evgeny.borzenin_gmail.com#EXT#@evgenyborzeningmail.onmicrosoft.com"

# Create AKS resource group
echo -e "Create ${RESOURCE_GROUP_NAME} resource group"
az group create -g ${RESOURCE_GROUP_NAME} -l westeurope 

# Create AKS Vnet
echo -e "Create ${VNET_NAME} VNet"
az network vnet create -g ${RESOURCE_GROUP_NAME} -n ${VNET_NAME} --address-prefix "${VNET_ADDRESS_PREFIX}/16" --subnet-name aks-net --subnet-prefix "${VNET_ADDRESS_PREFIX}/20"

# Get base VNet Id
BASE_VNET_ID="$(az network vnet show -g ${BASE_RESOURCE_GROUP} -n ${BASE_VNET_NAME} --query id -o tsv)"

# Establish VNet peering from AKS VNet to base VNet
echo -e "Peering ${VNET_NAME} with ${BASE_VNET_NAME}"
az network vnet peering create -g ${RESOURCE_GROUP_NAME} -n ${PEERING_TO_BASE_NAME} --vnet-name ${VNET_NAME} --allow-vnet-access --allow-forwarded-traffic --remote-vnet $BASE_VNET_ID

# Get AKS VNet ID
AKS_BLUE_VNET_ID="$(az network vnet show -g ${RESOURCE_GROUP_NAME} -n ${VNET_NAME} --query id -o tsv)"

# Establish VNet peering from base VNet to AKS VNet
echo -e "Peering ${BASE_VNET_NAME} with ${VNET_NAME}"
az network vnet peering create -g ${BASE_RESOURCE_GROUP} -n ${PEERING_TO_AKS_NAME} --vnet-name ${BASE_VNET_NAME} --allow-vnet-access --allow-forwarded-traffic --remote-vnet $AKS_BLUE_VNET_ID

# Get workspace resource id
WORKSPACE_ID="$(az monitor log-analytics workspace show -g ${BASE_RESOURCE_GROUP} -n iac-ws2-${YOUR_NAME}-la --query id -o tsv)"

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
SUBNET_ID="$(az network vnet subnet show -g ${RESOURCE_GROUP_NAME} --vnet-name ${VNET_NAME} -n aks-net --query id -o tsv)"

# Create user assigned managed identity
echo -e "Create User Assigned Managed Identity ${MANAGED_IDENTITY_NAME}"
az identity create --name ${MANAGED_IDENTITY_NAME} --resource-group ${RESOURCE_GROUP_NAME}

# Get managed identity ID
MANAGED_IDENTITY_ID="$(az identity show --name ${MANAGED_IDENTITY_NAME} --resource-group ${RESOURCE_GROUP_NAME} --query id -o tsv)"

# Create AKS cluster
echo -e "Create AKS cluster ${AKS_NAME}"
az aks create -g ${RESOURCE_GROUP_NAME} -n ${AKS_NAME} \
    --nodepool-name systempool  \
    --node-count 3 \
    --max-pods 110 \
    --enable-aad --aad-admin-group-object-ids ${ADMIN_GROUP_ID} \
    --kubernetes-version 1.19.6 \
    --network-plugin azure \
    --node-vm-size Standard_D4_v3 \
    --network-policy calico \
    --vm-set-type VirtualMachineScaleSets \
    --docker-bridge-address 172.17.0.1/16 \
	--enable-managed-identity \
    --assign-identity ${MANAGED_IDENTITY_ID} \
    --vnet-subnet-id ${SUBNET_ID} \
    --no-ssh-key \
    --attach-acr iacws2${YOUR_NAME}acr \
    --enable-addons monitoring --workspace-resource-id ${WORKSPACE_ID}