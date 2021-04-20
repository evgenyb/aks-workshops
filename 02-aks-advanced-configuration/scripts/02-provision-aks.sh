#!/usr/bin/env bash

# Usage:
#  Use default values for slot, vnet and subnet address ranges
#  ./02-provision-aks.sh <USE-YOUR-NAME> <YOUR-AAD-USER-NAME>
#  Provide all three parameters
#  ./02-provision-aks.sh <USE-YOUR-NAME> <YOUR-AAD-USER-NAME> blue "10.11.0.0/16" "10.11.0.0/20"
#  ./02-provision-aks.sh <USE-YOUR-NAME> <YOUR-AAD-USER-NAME> green "10.12.0.0/16" "10.12.0.0/20"

YOUR_NAME=$1                                    # I am using "evg"
YOUR_AAD_NAME=$2                                # Your Azure AD user name
SLOT=${3:-"blue"}                               # AKS deployment slot name (available values blue and green)
AKS_VNET_ADDRESS=${4:-"10.11.0.0/16"}           # AKS VNet address prefix
AKS_SUBNET_ADDRESS=${5:-"10.11.0.0/20"}         # aks-net subnet address prefix

# Set your user name for global resources (LogAnalytics, AppInsight, APIM etc...)
WS_PREFIX='iac-ws2'
AKS_RG="$WS_PREFIX-$SLOT-rg"                    # iac-ws2-blue-rg
AKS_NAME="$WS_PREFIX-$SLOT-aks"                 # iac-ws2-blue-aks
AKS_VNET_NAME=$WS_PREFIX-$SLOT-vnet             # iac-ws2-blue-vnet
BASE_RG="$WS_PREFIX-rg"                         # iac-ws2-rg
VNET_NAME=$WS_PREFIX-vnet                       # iac-ws2-vnet
LA_NAME="$WS_PREFIX-$YOUR_NAME-la"              # iac-ws2-evg-la
APPINSIGHTS_NAME="$WS_PREFIX-appinsights"       # iac-ws2-appinsights
PREFIX_NAME="$WS_PREFIX-pip-prefix"             # iac-ws2-pip-prefix
ACR_NAME="iacws2${YOUR_NAME}acr"                # iacws2evgacr
MANAGED_IDENTITY_NAME=$WS_PREFIX-$SLOT-aks-mi   # iac-ws2-blue-aks-mi

# Create AKS resource group
echo -e "Create $AKS_RG resource group"
az group create -g $AKS_RG -l westeurope 

# Create AKS VNet
echo -e "Create $AKS_VNET_NAME VNet ($AKS_VNET_ADDRESS) with aks-net subnet ($AKS_SUBNET_ADDRESS)"
az network vnet create -g $AKS_RG -n $AKS_VNET_NAME --address-prefix $AKS_VNET_ADDRESS --subnet-name aks-net --subnet-prefix $AKS_SUBNET_ADDRESS

# Get base VNet Id
BASE_VNET_ID="$(az network vnet show -g $BASE_RG -n $VNET_NAME --query id -o tsv)"

# Establish VNet peering from AKS VNet to base VNet
echo -e "Peering $AKS_VNET_NAME with $VNET_NAME"
az network vnet peering create -g $AKS_RG -n aks-$SLOT-to-base --vnet-name $AKS_VNET_NAME --allow-vnet-access --allow-forwarded-traffic --remote-vnet $BASE_VNET_ID

# Get AKS VNet ID
AKS_BLUE_VNET_ID="$(az network vnet show -g $AKS_RG -n $AKS_VNET_NAME --query id -o tsv)"

# Establish VNet peering from base VNet to AKS VNet
echo -e "Peering $VNET_NAME with $AKS_VNET_NAME"
az network vnet peering create -g $BASE_RG -n base-to-aks-$SLOT --vnet-name $VNET_NAME --allow-vnet-access --allow-forwarded-traffic --remote-vnet $AKS_BLUE_VNET_ID

# Get workspace resource id
WORKSPACE_ID="$(az monitor log-analytics workspace show -g $BASE_RG -n ${LA_NAME} --query id -o tsv)"
echo -e "Use Log Analytics $WORKSPACE_ID"

# Create Azure AD group iac-ws2
echo -e "Create Azure AD group iac-ws2"
az ad group create --display-name iac-ws2 --mail-nickname iac-ws2

# Get your Azure AD user objectId 
USER_ID="$(az ad user show --id "${YOUR_AAD_NAME}" --query objectId -o tsv)"

# Add your user (${USER_ID}) into iac-ws2 Azure AD group.
echo -e "Add user ${USER_ID} into iac-ws2 AAD group"
az ad group member add -g iac-ws2 --member-id ${USER_ID}

# Get iac-ws2 Azure AD group id)
ADMIN_GROUP_ID="$(az ad group show -g iac-ws2 --query objectId -o tsv)"

# Get aks-net subnet Id
SUBNET_ID="$(az network vnet subnet show -g $AKS_RG --vnet-name $AKS_VNET_NAME -n aks-net --query id -o tsv)"

# Create user assigned managed identity
echo -e "Create User Assigned Managed Identity $MANAGED_IDENTITY_NAME"
az identity create --name $MANAGED_IDENTITY_NAME --resource-group $AKS_RG

# Get managed identity ID
MANAGED_IDENTITY_ID="$(az identity show --name $MANAGED_IDENTITY_NAME --resource-group $AKS_RG --query id -o tsv)"

# Create AKS cluster
echo -e "Create AKS cluster $AKS_NAME"
az aks create -g $AKS_RG -n $AKS_NAME \
    --nodepool-name systempool  \
    --node-count 1 \
    --max-pods 110 \
    --enable-aad --aad-admin-group-object-ids ${ADMIN_GROUP_ID} \
    --kubernetes-version 1.19.7 \
    --network-plugin azure \
    --vm-set-type VirtualMachineScaleSets \
    --docker-bridge-address 172.17.0.1/16 \
	--enable-managed-identity \
    --assign-identity ${MANAGED_IDENTITY_ID} \
    --vnet-subnet-id ${SUBNET_ID} \
    --no-ssh-key \
    --attach-acr $ACR_NAME \
    --enable-addons monitoring --workspace-resource-id ${WORKSPACE_ID}