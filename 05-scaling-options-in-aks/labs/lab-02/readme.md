# lab-02 - build and deploy test application

## Estimated completion time - 10 min

There is a simple C# rest API dotnet app, called `guinea-pig` that performs some CPU intensive computations, in order to simulate load in your cluster.

```c#
var x = 0.0001;

for (var i = 0; i < 2000000; i++)
{
    x += Math.Sqrt(x);
}
```

The source code is located under `src` folder. If you use Visual Studio open `app.sln` file. 

## Goals

* build and push application image to Azure Container Registry
* deploy `guinea-pig` app to the cluster

## Task #1 - build and push `guinea-pig` application

Let's publish `api-a` image to the Azure Container Registry.

```bash
# Go to aks-workshops\02-aks-advanced-configuration\src\api-a folder
cd aks-workshops\02-aks-advanced-configuration\src\api-a

# Build and publish apib:v1 image into your ACR
az acr build --registry iacws2<YOUR-NAME>acr --image apia:v1 --file Dockerfile ..
```

## Task #2 - build and push `api-b` application

Let's publish `api-b` image to the Azure Container Registry.

```bash
# Go to aks-workshops\02-aks-advanced-configuration\src\api-b folder
cd aks-workshops\02-aks-advanced-configuration\src\api-b

# Build and publish apib:v1 image into your ACR
az acr build --registry iacws2<YOUR-NAME>acr --image apib:v1 --file Dockerfile ..
```

## Useful links

* [Visual Studio 2019 Community Edition](https://visualstudio.microsoft.com/downloads/?WT.mc_id=AZ-MVP-5003837)
* [Download .NET 5.0](https://dotnet.microsoft.com/download/dotnet/5.0?WT.mc_id=AZ-MVP-5003837)
* [Create your first Docker container with an ASP.NET web app](https://tutorials.visualstudio.com/aspnet-container/containerize?WT.mc_id=AZ-MVP-5003837)
* [Visual Studio Container Tools with ASP.NET Core](https://docs.microsoft.com/en-us/aspnet/core/host-and-deploy/docker/visual-studio-tools-for-docker?view=aspnetcore-5.0&WT.mc_id=AZ-MVP-5003837)
* [Container Tools in Visual Studio](https://docs.microsoft.com/en-us/visualstudio/containers/?view=vs-2019&WT.mc_id=AZ-MVP-5003837)
* [How to configure Visual Studio Container Tools](https://docs.microsoft.com/en-us/visualstudio/containers/container-tools-configure?view=vs-2019&WT.mc_id=AZ-MVP-5003837)
* [az acr build command](https://docs.microsoft.com/en-us/cli/azure/acr?view=azure-cli-latest&WT.mc_id=AZ-MVP-5003837#az_acr_build)
* [Push your first image to a private Docker container registry using the Docker CLI](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-get-started-docker-cli?WT.mc_id=AZ-MVP-5003837)

## Next: working with AKS node pools

[Go to lab-04](../lab-04/readme.md)

## Feedback

* Visit the [Github Issue](https://github.com/evgenyb/aks-workshops/issues/17) to comment on this lab. 