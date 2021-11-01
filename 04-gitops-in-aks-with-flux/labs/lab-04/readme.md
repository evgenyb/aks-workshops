# lab-01 - provision AKS cluster and supporting resources

## Estimated completion time - 20 min

With supporting resource in place, we will configure and provision AKS. Our AKS cluster needs to fullfil the following requirements:

* Integrate AKS with Azure AD to implement Kubernetes RBAC based on a Azure AD identities
* Implement [advanced (aka Azure CNI)](https://docs.microsoft.com/en-us/azure/aks/concepts-network?WT.mc_id=AZ-MVP-5003837#azure-cni-advanced-networking) networking model
* Use [managed identities in AKS](https://docs.microsoft.com/en-us/azure/aks/use-managed-identity?WT.mc_id=AZ-MVP-5003837) to create additional resources like load balancers and managed disks in Azure
* Integrate AKS with Azure Log Analytics for monitoring
* Integrate AKS with Azure Container Registry

![model](images/aks-resources.png)

## Goals

* Provision `AKS` resource group
* Provision Private Virtual Network with subnet for AKS
* Establish peering between `base` VNet and `aks` VNet
* Provision User Assigned Managed Identity for AKS and Azure AD integration 
* Create new Azure AD group for AKS administrators
* Add your user into AKS admin Azure AD group

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

* [k8s: Namespaces](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)

## Next: post provisioning configuration

[Go to lab-02](../lab-02/readme.md)

## Feedback

* Visit the [Github Issue](https://github.com/evgenyb/aks-workshops/issues/xx) to comment on this lab.