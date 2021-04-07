# lab-07 - add aad-pod-identity support into AKS

## Estimated completion time - xx min

## Goals

* Learn how to install and configure aad-pod-identity component
* Learn how to create a user-assigned managed identity and deploy AzureIdentity and AzureIdentityBinding resources
* Learn how to configure your AKS pod to use Managed Identity

## Task #1 - install and configure aad-pod-identity component

For `aad-pod-identity` to function, our cluster will need the correct role assignment configuration to perform Azure-related operations such as assigning and un-assigning the identity on the underlying VM/VMSS. 

We configured AKS cluster with user-assigned managed identity to communicate with Azure. The following role assignments need to be configured:

The roles `Managed Identity Operator` and `Virtual Machine Contributor` must be assigned to the cluster managed identity so that it can assign and un-assign identities from the underlying VMSS. If application managed identities are not within the node resource group, additional `Managed Identity Operator` role need to be assigned to the identity resource group scope.

`aad-pod-identity` provides bash [script](https://raw.githubusercontent.com/Azure/aad-pod-identity/master/hack/role-assignment.sh) that does all necessary roles assignment. You can find this script under `02-aks-advanced-configuration\k8s\aad-pod-identity` folder. 
Let's use this script to configure our cluster:

```bash
# Go to 02-aks-advanced-configuration\k8s\aad-pod-identity folder
cd 02-aks-advanced-configuration\k8s\aad-pod-identity

export SUBSCRIPTION_ID="<YOUR SUBSCRIPTION ID>"
export RESOURCE_GROUP="iac-ws2-blue-rg"
export CLUSTER_NAME="iac-ws2-blue-aks"

# Optional: if you are planning to deploy your user-assigned identities
# in a separate resource group instead of your node resource group
export IDENTITY_RESOURCE_GROUP="iac-ws2-rg"

# Configure role assignments
./role-assignment.sh 

# Create msi namespace
kubectl create ns msi

# Deploy msi components into msi namespace
kubectl apply -f .\deployment.yaml

# Deploy msi exceptions
kubectl apply -f .\mic-exception.yaml

# Check what is deployed to msi namespace
kubectl get po -n msi
mic-7984844578-5cfbl   1/1     Running   0          74m
mic-7984844578-w695v   1/1     Running   0          74m
nmi-j9dzw              1/1     Running   0          74m
nmi-v6d7q              1/1     Running   0          74m
```

You should have two `mic` pods and one `nmi` daemon set at each node. IN my case, I have two nodes, therefore I have two `nmi` pods.

## Task #2 - create KeyVault and create new secret

As described at tha application use-case, our `api-b` application needs to get access to the secrets fromm the key-vault.
Let's create new `iac-ws2-<YOUR-NAME>-api-b-kv` key-vault in `iac-ws2-rg` resource group.

```bash
# Create api-b KeyVault 
az keyvault create -g iac-ws2-rg -n iac-ws2-<YOUR-NAME>-api-b-kv -l westeurope

# Create secret foobar with value barfoo
az keyvault secret set --vault-name iac-ws2-<YOUR-NAME>-api-b-kv -n foobar --value barfoo

# Get KeyVault url 
az keyvault show -g iac-ws2-rg -n iac-ws2-<YOUR-NAME>-api-b-kv --query properties.vaultUri
```

## Task #3 - create User-Assigned Managed Identity 

Create an identity on Azure and store the client ID and resource ID of the identity as environment variables:

```bash
# Create User Assigned Managed Identity iac-ws2-api-b-mi
az identity create -g iac-ws2-rg -n iac-ws2-api-b-mi

# Get Managed Identity client ID
export IDENTITY_CLIENT_ID="$(az identity show -n iac-ws2-api-b-mi -g iac-ws2-rg --query clientId -o tsv)"
export IDENTITY_RESOURCE_ID="$(az identity show -n iac-ws2-api-b-mi -g iac-ws2-rg --query id -o tsv)"

export OBJECT_ID="$(az identity show -n iac-ws2-api-b-mi -g iac-ws2-rg --query principalId -o tsv)"
# Grant iac-ws2-api-b-mi managed identity with get secret permission at iac-ws2-<YOUR-NAME>-api-b-kv keyvault
az keyvault set-policy -g iac-ws2-rg -n iac-ws2-<YOUR-NAME>-api-b-kv --secret-permissions get --object-id ${OBJECT_ID}
```
## Task #4 - create an AzureIdentity and AzureIdentityBinding

```bash
# Create an AzureIdentity in your cluster that references the identity you created above:

cat <<EOF | kubectl apply -f -
apiVersion: "aadpodidentity.k8s.io/v1"
kind: AzureIdentity
metadata:
  name: api-b
spec:
  type: 0
  resourceID: ${IDENTITY_RESOURCE_ID}
  clientID: ${IDENTITY_CLIENT_ID}
EOF

# Get azureidentity resource
kubectl get azureidentity
NAME    AGE
api-b   2m4s

# Get azureidentity description
kubectl describe azureidentity api-b

# Create an AzureIdentityBinding that reference the AzureIdentity you created above:
cat <<EOF | kubectl apply -f -
apiVersion: "aadpodidentity.k8s.io/v1"
kind: AzureIdentityBinding
metadata:
  name: api-b-binding
spec:
  azureIdentity: api-b
  selector: api-b
EOF

# Get azureidentitybinding resource
kubectl get azureidentitybinding
NAME            AGE
api-b-binding   2m

# Get azureidentity description
kubectl describe azureidentitybinding api-b-binding
```




## Useful links

* [What are managed identities for Azure resources?](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview)
* [Services that support managed identities for Azure resources](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/services-support-managed-identities)
* [Use Key Vault from App Service with Azure Managed Identity](https://docs.microsoft.com/en-us/samples/azure-samples/app-service-msi-keyvault-dotnet/keyvault-msi-appservice-sample/?WT.mc_id=AZ-MVP-5003837)
* [Azure Active Directory Pod Identity for Kubernetes](https://azure.github.io/aad-pod-identity/docs/)
* [Standard Walkthrough](https://azure.github.io/aad-pod-identity/docs/demo/standard_walkthrough/)
* [AAD Pod Identity Tutorial](https://azure.github.io/aad-pod-identity/docs/demo/tutorial/)
* [Role Assignment](https://azure.github.io/aad-pod-identity/docs/getting-started/role-assignment/)
* [aad-pod-identity releases](https://github.com/Azure/aad-pod-identity/releases)

## Next: 

[Go to lab-06](../lab-06/readme.md)

## Feedback

* Visit the [Github Issue](https://github.com/evgenyb/aks-workshops/issues/xx) to comment on this lab. 