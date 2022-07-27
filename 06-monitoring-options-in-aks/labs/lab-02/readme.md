# lab-02 - build and deploy test application

## Estimated completion time - 10 min

There is a simple C# dotnet core app, called `GuineaPig` that performs some CPU (and memory) intensive computations, in order to simulate load in your cluster.
The source code is located under `src` folder. If you use Visual Studio open `app.sln` file. 

## Goals

* build and push application image to Azure Container Registry
* deploy `GuineaPig` application into the cluster

## Task #1 - build and push `GuineaPig` application

The simplest way to build and push image is to use `az acr build` command. Let's publish `GuineaPig` image to the Azure Container Registry. 
> Note! Don't forget to replace `iacws6<YOU-UNIQUE-ID>acr` with your ACR instance name.

```bash
# Go to aks-workshops\06-monitoring-options-in-aks\src\GuineaPig folder
cd src\GuineaPig

# Build and publish guinea-pig:v1 image into your ACR
az acr build --registry iacws6<YOU-UNIQUE-ID>acr --image guinea-pig:v1 --file Dockerfile ..
```

## Task #2 - deploy application to cluster

First, we need to get Application Insights instrumentation key. 

```bash
# Get Application Insights instrumentation key
az resource show -g iac-ws6-rg -n iac-ws6-ai --resource-type "microsoft.insights/components" --query properties.InstrumentationKey
```

Create new `deployment.yaml` file with the following content. Replace `image` with your ACR instance name. Replace `<INSTRUMENTATION-KEY>` with the value you get from the previous command

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
        image: iacws6<YOU-UNIQUE-ID>acr.azurecr.io/guinea-pig:v1
        imagePullPolicy: IfNotPresent
        env:
          - name: APPINSIGHTS_INSTRUMENTATIONKEY
            value: <INSTRUMENTATION-KEY>
        resources: 
          requests:            
            cpu: 200m
            memory: 100Mi
          limits:
            cpu: 400m
            memory: 200Mi
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
  - name: web
    port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: guinea-pig
  type: ClusterIP
```

Deploy application into `default` namespace. 

```bash
# Deploy application into default namespace
kubectl apply -f deployment.yaml
deployment.apps/guinea-pig created
service/guinea-pig-service created

# Check that pod is up and running
kubectl get po
NAME                          READY   STATUS    RESTARTS   AGE
guinea-pig-6c994669b7-c8rtz   1/1     Running   0          32s

# Check that service was created
kubectl get svc
NAME                 TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
guinea-pig-service   ClusterIP   10.0.49.164   <none>        80/TCP    47s
```

## Task #3 - test application

Now let's test if application is actually up and running. We will use our old freind - [busyboxplus:curl](https://hub.docker.com/r/radial/busyboxplus) image, mainly because it contains `curl` command that we need for our testing. 

```bash
# Run pod as interactive shell
kubectl run curl -i --tty --rm --restart=Never --image=radial/busyboxplus:curl -- sh

# Here is prompt from withing the pod
[ root@curl:/ ]$ 

# Call api endpoint. It should response with "[guinea-pig] - OK."
[ root@curl:/ ]$ curl http://guinea-pig-service/api
[guinea-pig] - OK.
```

In the separate terminal window, watch application logs.

```bash
# Get pod name
kubectl get po
NAME                          READY   STATUS    RESTARTS   AGE
guinea-pig-75f86bcf55-bzb5g   1/1     Running   0          2m18s

# Get guinea-pig application logs
kubectl logs guinea-pig-75f86bcf55-bzb5g -f
[21:26:36 WRN] Failed to determine the https port for redirect.
[21:26:56 INF] [guinea-pig] - OK.
```

Now let's test another application endpoint from the `busybox` shell.  

```bash
[ root@curl:/ ]$ curl http://guinea-pig-service/api/highcpu
[ root@curl:/ ]$ curl http://guinea-pig-service/api/highcpu
```

You should see new logs appear from `kubectl logs ` window

```bash
kubectl logs guinea-pig-75f86bcf55-bzb5g -f
[21:26:36 WRN] Failed to determine the https port for redirect.
[21:26:56 INF] [guinea-pig] - OK.
[21:26:58 INF] [guinea-pig] - OK.
[21:32:05 INF] [guinea-pig.highcpu] - execution took 18 ms.
[21:32:05 INF] [guinea-pig.highcpu] - execution took 18 ms.
```

## Task #4 - put some load to the application

To get some more metrics, let's put some load to our application by running the following command

```bash
# Generate some load to guinea-pig application
kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://guinea-pig-service/api/highcpu; done"
```

This script will run an infinite loop, sending `wget -q -O- http://guinea-pig-service/api/highcpu` query to the `guinea-pig-service` every 0.01 sec, resulting in approx. 25 requests per sec. load. You will notice 404 and 500 responses, but that is expected and you can ignore those for now. Later on we'll explore how those different responses can be monitored.


## Useful links

* [Visual Studio 2019 Community Edition](https://visualstudio.microsoft.com/downloads/?WT.mc_id=AZ-MVP-5003837)
* [Download .NET 5.0](https://dotnet.microsoft.com/download/dotnet/5.0?WT.mc_id=AZ-MVP-5003837)
* [Create your first Docker container with an ASP.NET web app](https://tutorials.visualstudio.com/aspnet-container/containerize?WT.mc_id=AZ-MVP-5003837)
* [Visual Studio Container Tools with ASP.NET Core](https://docs.microsoft.com/en-us/aspnet/core/host-and-deploy/docker/visual-studio-tools-for-docker?view=aspnetcore-5.0&WT.mc_id=AZ-MVP-5003837)
* [Container Tools in Visual Studio](https://docs.microsoft.com/en-us/visualstudio/containers/?view=vs-2019&WT.mc_id=AZ-MVP-5003837)
* [How to configure Visual Studio Container Tools](https://docs.microsoft.com/en-us/visualstudio/containers/container-tools-configure?view=vs-2019&WT.mc_id=AZ-MVP-5003837)
* [az acr build command](https://docs.microsoft.com/en-us/cli/azure/acr?view=azure-cli-latest&WT.mc_id=AZ-MVP-5003837#az_acr_build)
* [Push your first image to a private Docker container registry using the Docker CLI](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-get-started-docker-cli?WT.mc_id=AZ-MVP-5003837)

## Next: monitoring AKS with Azure Monitor

[Go to lab-03](../lab-03/readme.md)