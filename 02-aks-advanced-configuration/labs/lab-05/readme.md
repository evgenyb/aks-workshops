# lab-07 - add aad-pod-identity support into AKS

## Estimated completion time - xx min

## Goals

* Learn how to install and configure aad-pod-identity component
* Learn how to create a user-assigned managed identity and deploy AzureIdentity and AzureIdentityBinding resources
* Learn how to configure your AKS pod to use Managed Identity

## Task #1 - install and configure aad-pod-identity component

```bash
# Go to 02-aks-advanced-configuration\k8s\aad-pod-identity folder
cd 02-aks-advanced-configuration\k8s\aad-pod-identity

export SUBSCRIPTION_ID="8878beb2-5e5d-4418-81ae-783674eea324"
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
```

## Task #2 - create KeyVault and create new secret

```bash
# Ccreate api-b KeyVault 
az keyvault create -g iac-ws2-base-rg -n iac-ws2-api-b-kv -l westeurope

# Create secret foobar with value barfoo
az keyvault secret set --vault-name iac-ws2-api-b-kv -n foobar --value barfoo

# Get KeyVault url 
az keyvault show -g iac-ws2-base-rg -n iac-ws2-api-b-kv --query properties.vaultUri
```

## Task #3 - create User Assigned Managed Identity 

```bash
# Create User Assigned Managed Identity iac-ws2-api-b-mi
az identity create -g iac-ws2-base-rg -n iac-ws2-api-b-mi

# Get Managed Identity client ID
az identity show -n iac-ws2-api-b-mi -g iac-ws2-base-rg --query clientId -o tsv
az identity show -n iac-ws2-api-b-mi -g iac-ws2-base-rg --query id -o tsv

OBJECT_ID="$(az identity show -n iac-ws2-api-b-mi -g iac-ws2-base-rg --query principalId -o tsv)"
# Grant iac-ws2-api-b-mi managed identity with get secret permission at iac-ws2-api-b-kv keyvault
az keyvault set-policy -g iac-ws2-base-rg -n iac-ws2-api-b-kv --secret-permissions get --object-id ${OBJECT_ID}
```

```yaml
apiVersion: "aadpodidentity.k8s.io/v1"
kind: AzureIdentity
metadata:
  name: "api-b"
  annotations:
    aadpodidentity.k8s.io/Behavior: namespaced
spec:
  type: 0
  resourceID: "<resourceId>"
  clientID: "<clientId>"
---
apiVersion: "aadpodidentity.k8s.io/v1"
kind: AzureIdentityBinding
metadata:
  name: "api-b-binding"
spec:
  azureIdentity: "api-b"
  selector: "api-b"
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