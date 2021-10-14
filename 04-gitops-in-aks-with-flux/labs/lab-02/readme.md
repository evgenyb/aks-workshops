# lab-02 - post provisioning configuration

## Estimated completion time - xx min


```powershell
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install nginx-ingress ingress-nginx/ingress-nginx --create-namespace --namespace nginx-ingress -f internal-ingress.yaml
```

```powershell
# Add the Kured Helm repository
helm repo add kured https://weaveworks.github.io/kured

# Update your local Helm chart repository cache
helm repo update

# Create a dedicated namespace where you would like to deploy kured into
kubectl create namespace kured

# Install kured in that namespace with Helm 3 (only on Linux nodes, kured is not working on Windows nodes)
helm install kured kured/kured --namespace kured --set nodeSelector."kubernetes\.io/os"=linux
```

https://docs.microsoft.com/en-us/azure/aks/node-updates-kured

## Task #1 - create AKS resources

```powershell
# Select your subscription
Set-AzContext -Subscription 8878beb2-5e5d-4418-81ae-783674eea324
```

```powershell
# Deploy your blue environment
New-AzSubscriptionDeployment -Location WestEurope -TemplateFile .\deployment.bicep -TemplateParameterFile .\parameters-blue.json
```

## Useful links

* [AKS-managed Azure Active Directory integration](https://docs.microsoft.com/en-us/azure/aks/managed-aad?WT.mc_id=AZ-MVP-5003837)

## Next: install Flux CLI to your PC and Flux onto your cluster

[Go to lab-03](../lab-03/readme.md)

## Feedback

* Visit the [Github Issue](https://github.com/evgenyb/aks-workshops/issues/xx) to comment on this lab. 