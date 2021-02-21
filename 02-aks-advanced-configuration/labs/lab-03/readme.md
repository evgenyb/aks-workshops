# lab-03 - ....

## Estimated completion time - 50 min

![model](images/apim-agw-front-door.png)

## Goals

## Task #1 - create AKS resources

```bash
# Create Log Analytics
az monitor log-analytics workspace create -g iac-ws2-base-rg -n iac-ws2-<YOUR-NAME>-la

# Create Azure Container Registry
az acr create -g iac-ws2-base-rg -n iacws2<YOUR-NAME>acr --sku Basic

# Get workspace resource id
az monitor log-analytics workspace show -g iac-ws2-base-rg -n iac-ws2-<YOUR-NAME>-la --query id

# Create Azure AD group iac-ws2
az ad group create --display-name iac-ws2 --mail-nickname iac-ws2

# Get your user Azure AD objectId 
az ad user show --id "<AZURE-AD-USER-NAME>" --query objectId

# Sometimes userPrincipalName is in really strange format. In that case, you can try to search
az ad user list --query "[?contains(userPrincipalName, '<PART-OF-USER-NAME>')].objectId"

# Add user into iac-ws2 Azure AD group. Use object Id from previous query 
az ad group member add -g iac-ws2 --member-id <USER-AAD-OBJECT-ID>

# Get iac-ws2 Azure AD group id)
az ad group show -g iac-ws2 --query objectId

# Get Public IP prefix ID
az network public-ip prefix show  -g iac-ws2-base-rg -n iac-ws2-pip-prefix --query id

# Create public IP address from prefix 
az network public-ip create -g iac-ws2-aks-blue-rg -n iac-ws2-aks-blue-egress-pip --sku Standard --public-ip-prefix <PREFIX-ID> 

# Get public egress IP ID
az network public-ip show -g iac-ws2-aks-blue-rg -n iac-ws2-aks-blue-egress-pip --query id

# Get subnet Id
az network vnet subnet show -g iac-ws2-aks-blue-rg --vnet-name iac-ws2-aks-blue-vnet -n aks-net  --query id

# Create user assigned managed identity
az identity create --name iac-ws2-aks-blue-mi --resource-group iac-ws2-aks-blue-rg

# Get managed identity ID
az identity show --name iac-ws2-aks-blue-mi --resource-group iac-ws2-aks-blue-rg --query id

# Create AKS cluster
az aks create -g iac-ws2-aks-blue-rg -n aks-ws2-blue \
    --nodepool-name systempool  \
    --node-count 1 \
    --max-pods 110 \
    --enable-aad --aad-admin-group-object-ids <AAD-GROUP-ID> \
    --kubernetes-version 1.19.7 \
    --network-plugin azure \
    --network-policy calico \
    --vm-set-type VirtualMachineScaleSets \
    --docker-bridge-address 172.17.0.1/16 \
	--enable-managed-identity \
    --assign-identity <identity-id> \
    --load-balancer-outbound-ips <PUBLIC-EGRESS-IP-ID>\
    --vnet-subnet-id <SUBNET-ID> \
    --no-ssh-key \
    --attach-acr iacws2<YOUR-NAME>acr \
    --enable-addons monitoring --workspace-resource-id <WORKSPACE-ID> 

# Get AKS credentials
az aks get-credentials -g iac-ws2-aks-blue-rg -n aks-ws2-blue --overwrite-existing

# Set CriticalAddonsOnly=true:NoSchedule taint
kubectl taint nodes systempool CriticalAddonsOnly=true:NoSchedule

# Add new node pool
az aks nodepool add -g iac-ws2-aks-blue-rg --cluster-name aks-ws2-blue \
    --name workloadpool \
    --node-count 3 \
    --max-pods 110 \
    --node-vm-size Standard_D4_v3 \
    --kubernetes-version 1.19.7 \
    --mode User

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