

```bash
$ az acr login --name iacakslab01
Login Succeeded
```


```bash
az acr build --image iac-aks-lab01/app-a:v2 --registry iacakslab01 --file Dockerfile ..

```

```bash
kubectl run app-a --image iacakslab01.azurecr.io/iac-aks-lab01/app-a:v2
```

## Links

* [Push your first image to a private Docker container registry using the Docker CLI](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-get-started-docker-cli?WT.mc_id=AZ-MVP-5003837)