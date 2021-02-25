# lab-04 - ....

## Estimated completion time - 50 min

![model](images/apim-agw-front-door.png)

## Goals

## Task #1 - create AKS resources

```bash

cd k8s/api-a
# Deploy configmap with appsettings for api-a
kubectl create secret generic api-a-secret-appsettings --from-file=./appsettings.secrets.json

# Deploy api-a 
kubectl apply -f ./deployment.yaml

cd ../k8s/api-b
# Deploy configmap with appsettings for api-b
kubectl create secret generic api-b-secret-appsettings --from-file=./appsettings.secrets.json

# Deploy api-b
kubectl apply -f ./deployment.yaml

```

## Useful links

* [Application Insights for ASP.NET Core applications](https://docs.microsoft.com/en-us/azure/azure-monitor/app/asp-net-core?WT.mc_id=AZ-MVP-5003837)


## Next: 

[Go to lab-05](../lab-05/readme.md)

## Feedback

* Visit the [Github Issue](https://github.com/evgenyb/aks-workshops/issues/xx) to comment on this lab. 