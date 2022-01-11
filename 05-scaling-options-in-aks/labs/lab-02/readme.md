# lab-02 - build and deploy test application

## Estimated completion time - 10 min

There is a simple C# rest API dotnet app, called `GuineaPig` that performs some CPU intensive computations, in order to simulate load in your cluster.
The source code is located under `src` folder. If you use Visual Studio open `app.sln` file. 

## Goals

* build and push application image to Azure Container Registry
* deploy `GuineaPig` application into the cluster

## Task #1 - build and push `GuineaPig` application

The simplest way to build and push image is to use `az acr build` command. Let's publish `GuineaPig` image to our Azure Container Registry.

```bash
# Go to aks-workshops\05-scaling-options-in-aks\src\GuineaPig folder
cd src\GuineaPig

# Build and publish guinea-pig:v1 image into your ACR
az acr build --registry iacws5<YOU-UNIQUE-ID>acr --image guinea-pig:v1 --file Dockerfile ..
```

## Task #2 - deploy application to cluster

Create new `deployment.yaml` file with the following content

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: guinea-pig
  labels:
    app: guinea-pig
spec:
  replicas: 1
  selector:
    matchLabels:
      app: guinea-pig
  template:
    metadata:
      labels:
        app: guinea-pig
    spec:
      containers:
      - name: api
        image: iacws5<YOU-UNIQUE-ID>acr.azurecr.io/guinea-pig:v1
        imagePullPolicy: IfNotPresent
        resources: 
          requests:
            cpu: 200m
          limits:
            cpu: 300m
        livenessProbe:
          httpGet:
            path: /health
            port: 80
          initialDelaySeconds: 3
          periodSeconds: 3    
---
apiVersion: v1
kind: Service
metadata:
  name: guinea-pig-service
  labels:
    app: guinea-pig
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: guinea-pig
  type: ClusterIP

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