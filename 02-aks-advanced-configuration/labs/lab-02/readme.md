# lab-02 - provision AKS cluster

## Estimated completion time - 15 min

![model](images/apim-agw-front-door.png)

## Goals

## Task #1 - create AKS resources

```bash
# Set your user name for global resources (LogAnalytics, AppInsight, APIM etc...)
YOUR_NAME="evg"

# Create AKS resource group
az group create -g iac-ws2-aks-blue-rg -l westeurope 

# Create AKS Vnet
az network vnet create -g iac-ws2-aks-blue-rg -n iac-ws2-aks-blue-vnet --address-prefix 10.11.0.0/16 --subnet-name aks-net --subnet-prefix 10.11.0.0/20

# Get base VNet Id
BASE_VNET_ID="$(az network vnet show -g iac-ws2-base-rg -n iac-ws2-base-vnet --query id -o tsv)"

# Establish VNet peering from AKS VNet to base VNet
az network vnet peering create -g iac-ws2-aks-blue-rg -n aks-blue-to-base --vnet-name iac-ws2-aks-blue-vnet --allow-vnet-access --allow-forwarded-traffic --remote-vnet $BASE_VNET_ID

# Get AKS VNet ID
AKS_BLUE_VNET_ID="$(az network vnet show -g iac-ws2-aks-blue-rg -n iac-ws2-aks-blue-vnet --query id -o tsv)"

# Establish VNet peering from base VNet to AKS VNet
az network vnet peering create -g iac-ws2-base-rg -n base-to-aks-blue --vnet-name iac-ws2-base-vnet --allow-vnet-access --allow-forwarded-traffic --remote-vnet $AKS_BLUE_VNET_ID

# Get workspace resource id
WORKSPACE_ID="$(az monitor log-analytics workspace show -g iac-ws2-base-rg -n iac-ws2-${YOUR_NAME}-la --query id -o tsv)"

# Create Azure AD group iac-ws2
az ad group create --display-name iac-ws2 --mail-nickname iac-ws2

# Get your user Azure AD objectId 
USER_ID="$(az ad user show --id "<AZURE-AD-USER-NAME>" --query objectId -o tsv)"

# Sometimes userPrincipalName is in really strange format. In that case, you can try to search
USER_ID="$(az ad user list --query "[?contains(userPrincipalName, '<PART-OF-USER-NAME>')].objectId" -o tsv)"

# Add user into iac-ws2 Azure AD group. Use object Id from previous query 
az ad group member add -g iac-ws2 --member-id ${USER_ID}

# Get iac-ws2 Azure AD group id)
ADMIN_GROUP_ID="$(az ad group show -g iac-ws2 --query objectId -o tsv)"

# Get subnet Id
SUBNET_ID="$(az network vnet subnet show -g iac-ws2-aks-blue-rg --vnet-name iac-ws2-aks-blue-vnet -n aks-net --query id -o tsv)"

# Create user assigned managed identity
az identity create --name iac-ws2-aks-blue-mi --resource-group iac-ws2-aks-blue-rg

# Get managed identity ID
MANAGED_IDENTITY_ID="$(az identity show --name iac-ws2-aks-blue-mi --resource-group iac-ws2-aks-blue-rg --query id -o tsv)"

# Create AKS cluster
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

# Get AKS credentials
az aks get-credentials -g iac-ws2-aks-blue-rg -n aks-ws2-blue --overwrite-existing

# Get nodes
kubectl get nodes
To sign in, use a web browser to open the page https://microsoft.com/devicelogin and enter the code C9HNNZ8SE to authenticate.
# Because of we enabled RBAC, we need to authenticate with Azure AD
NAME                             STATUS   ROLES   AGE   VERSION
aks-system-40523769-vmss000000   Ready    agent   52m   v1.19.6
```

## Useful links

* [Azure Container Registry documentation](https://docs.microsoft.com/en-us/azure/container-registry/?WT.mc_id=AZ-MVP-5003837)
* [Configure Azure CNI networking in Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/configure-azure-cni?WT.mc_id=AZ-MVP-5003837)
https://docs.microsoft.com/en-us/azure/aks/operator-best-practices-advanced-scheduler
https://docs.microsoft.com/en-us/azure/aks/use-multiple-node-pools
https://docs.microsoft.com/en-us/azure/aks/use-system-pools
https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/


## Next: 

[Go to lab-04](../lab-04/readme.md)

## Feedback

* Visit the [Github Issue](https://github.com/evgenyb/aks-workshops/issues/xx) to comment on this lab. 