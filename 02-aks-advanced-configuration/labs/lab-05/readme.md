# lab-07 - add aad-pod-identity support into AKS

## Estimated completion time - xx min

## Goals

## Task #1 - 

```bash
# create new namespace
kubectl create ns msi

# deploy msi components
kubectl apply -f .\deployment.yaml

# deploy msi components
kubectl apply -f .\deployment.yaml

# deploy exceptions
kubectl apply -f .\mic-exception.yaml

export SUBSCRIPTION_ID="8878beb2-5e5d-4418-81ae-783674eea324"
export RESOURCE_GROUP="iac-ws2-aks-blue-rg"
export CLUSTER_NAME="aks-ws2-blue"

# Optional: if you are planning to deploy your user-assigned identities
# in a separate resource group instead of your node resource group
export IDENTITY_RESOURCE_GROUP="iac-ws2-base-rg"

./role-assignment.sh 
```

```bash
# Ccreate api-b KeyVault 
az keyvault create -g iac-ws2-base-rg -n iac-ws2-api-b-kv -l westeurope

# Create secret foobar with value barfoo
az keyvault secret set --vault-name iac-ws2-api-b-kv -n foobar --value barfoo

# Get KeyVault url 
az keyvault show -g iac-ws2-base-rg -n iac-ws2-api-b-kv --query properties.vaultUri

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

https://docs.microsoft.com/en-us/samples/azure-samples/app-service-msi-keyvault-dotnet/keyvault-msi-appservice-sample/
https://azure.github.io/aad-pod-identity/docs/
https://azure.github.io/aad-pod-identity/docs/demo/standard_walkthrough/
https://azure.github.io/aad-pod-identity/docs/demo/tutorial/


## Next: 

[Go to lab-06](../lab-06/readme.md)

## Feedback

* Visit the [Github Issue](https://github.com/evgenyb/aks-workshops/issues/xx) to comment on this lab. 