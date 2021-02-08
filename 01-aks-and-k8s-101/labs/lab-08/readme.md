# lab-08 - Configmaps and secrets

## Estimated completion time - xx min

Kubernetes has two types of objects that can inject configuration data into a container when it starts up: Secrets and ConfigMaps. Secrets and ConfigMaps both can be exposed inside a container as mounted files (or volumes or environment variables). 

To explore Secrets and ConfigMaps, consider the following scenario:
* We use Database and we need to store connection string to the database. We are OK to save development connection string into `Database` section inside `appsettings.json`, but we don't want to store connection string  of database used from our AKS cluster, therefore we want to use Kubernetes secret to store Connection string
* We want to be able to change our logging verbosity without re-deploying or re-starting our application. We want to use build-in ASP.NET logging framework and configuration settings for that. For local development, we want to use `Logging` section of `appsettings.json` file.

## Application

To work with Secrets and ConfigMap, our test application was extended with 2 more controllers:

### SecretTestController 

This endpoint reads `Database:ConnectionString` from Configuration and writes logs it. 
* when you run you application locally and test `http://localhost:5000/secrettest` endpoint, you should see `[lab-08] - Database:ConnectionString: Connection string from local configuration file.` log line

* when you run you application locally and test `http://pod-ip/secrettest` endpoint, you should see `[lab-08] - Database:ConnectionString: Connection string from kubernetes secret.` log line.

### ConfigMapTestController

This endpoint writes 4 different log levels:

* Info
* Warning
* Error
* Critical

With default log level configuration 

```json
"Logging": {
  "LogLevel": {
    "Default": "Information",
    "Microsoft": "Warning",
    "Microsoft.Hosting.Lifetime": "Information"
  }
}
```

we expect to see all 4 type of log levels, but after changing log level configuration to the following

```json
  "Logging": {
    "LogLevel": {
      "Default": "Error",
      "Microsoft": "Error",
      "Microsoft.Hosting.Lifetime": "Error"
    }
  }
```
we expect to see only logs of typ `Warning` and `Critical`.

## Goals

In this lab you will learn how to:

* create Kubernetes secrets 
* mount contents of the Secret into the folder
* use Kubernetes secrets to override some properties in an ASP.NET Core app's configuration at runtime
* crate Kubernetes Config Map
* mount the contents of the config map into the folder
* use config map as mounted configuration file

## Task #1 - create Kubernetes Secret and read it as Configuration parameter from the application

Create `appsettings.secrets.json` file with the following content. Imagine that it contains connection string to your database. You don't want to check it in, so most likely in real life you will generate this file based on either secret form Azure KeyVault, or read connection string from from Azure Cosmos DB or Azure SQL Server resource.

```json
{
    "Database": {
        "ConnectionString": "Connection string from kubernetes secret."
    }
}
```

Now cerate Kubernetes secret from this file using `kubectl create secret`

```bash
# Create new secret from the appsettings.secrets.json file
kubectl create secret generic secret-appsettings --from-file=./appsettings.secrets.json

# Get all secrets
kubectl get secret

# Get secret-appsettings secrets
kubectl get secret secret-appsettings

# Get detailed description of secret-appsettings secret
kubectl describe secret secret-appsettings

# Get secret-appsettings secrets yaml definition
kubectl get secret secret-appsettings -o yaml

# Get the contents of the Secret 
kubectl get secret secret-appsettings -o jsonpath='{.data}'
```

Now you can decode the data. If you are at linux, you most likely already have `base64` command installed. If you are on PowerShell, install `base64` with `choco`

```powershell
choco install base64
Chocolatey v0.10.15
Installing the following packages:
base64
By installing you accept licenses for the packages.
Progress: Downloading base64 1.0.0... 100%

base64 v1.0.0 [Approved]
base64 package files install completed. Performing other installation steps.
The package base64 wants to run 'chocolateyinstall.ps1'.
Note: If you don't run this script, the installation will fail.
Note: To confirm automatically next time, use '-y' or consider:
choco feature enable -n allowGlobalConfirmation
Do you want to run the script?([Y]es/[A]ll - yes to all/[N]o/[P]rint): A
```
With `base64` installed, run the following command to decode secret data.

```powershell
# Get the contents of the Secret 
kubectl get secret secret-appsettings -o jsonpath='{.data}'
{"appsettings.secrets.json":"ew0KICAgICJEYXRhYmFzZSI6IHsNCiAgICAgICAgIkNvbm5lY3Rpb25TdHJpbmciOiAiQ29ubmVjdGlvbiBzdHJpbmcgZnJvbSBrdWJlcm5ldGVzIHNlY3JldC4iDQogICAgfQ0KfQ=="}

# Decode appsettings.secrets.json
echo ew0KICAgICJEYXRhYmFzZSI6IHsNCiAgICAgICAgIkNvbm5lY3Rpb25TdHJpbmciOiAiQ29ubmVjdGlvbiBzdHJpbmcgZnJvbSBrdWJlcm5ldGVzIHNlY3JldC4iDQogICAgfQ0KfQ== | base64 -d 
{
    "Database": {
        "ConnectionString": "Connection string from kubernetes secret."
    }
}
```

Create `lab8-task1-deployment.yaml` file with the following Deployment definition

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: lab8-task1
  labels:
    app: lab8-task1
spec:
  replicas: 1
  selector:
    matchLabels:
      app: lab8-task1
  template:
    metadata:
      labels:
        app: lab8-task1
    spec:
      containers:
      - name: api
        image: iacaksws1<YOU-NAME>acr.azurecr.io/apia:v1
        imagePullPolicy: IfNotPresent
        resources: {}
        livenessProbe:
          httpGet:
            path: /health
            port: 80
          initialDelaySeconds: 3
          periodSeconds: 3    
        readinessProbe:
          httpGet:
            path: /readiness
            port: 80
          initialDelaySeconds: 3
          periodSeconds: 3
        volumeMounts:
        - name: secrets
          mountPath: /app/secrets
          readOnly: true          
      volumes:
      - name: secrets
        secret:
          secretName: secret-appsettings
```

Note, under the `volumes` section we added new item called `secrets` of type `secret` and we use secret  `secret-appsettings` that we just deployed.
```yaml
      volumes:
      - name: secrets
        secret:
          secretName: secret-appsettings
```

Inside container template spec section we added the following configuration

```yaml
        volumeMounts:
        - name: secrets
          mountPath: /app/secrets
          readOnly: true          
```

This configuration will create folder `app/secrets` inside pod filesystem and will map contents of secret into the files under this folder. In our case, `secret-appsettings` secret only contains one data item called `appsettings.secrets.json`, so, we should expect one `appsettings.secrets.json` file created inside `app/secrets` folder. 

Now, let's deploy `lab8-task1-deployment.yaml` Deployment

```bash
# Deploy lab8-task1-deployment.yaml
kubectl.exe apply -f .\lab8-task1-deployment.yaml
deployment.apps/lab8-task1 created

# Wait until deployment is successfully rolled out

# Get pod name
kubectl get po -l app=lab8-task1
NAME                          READY   STATUS    RESTARTS   AGE
lab8-task1-776c98fb8b-9kmp6   1/1     Running   0          66s

# Attach to the pod
kubectl exec -it lab8-task1-776c98fb8b-9kmp6 -- bash

# check the folder structure
root@lab8-task1-776c98fb8b-9kmp6:/app# ls
Microsoft.OpenApi.dll               Swashbuckle.AspNetCore.SwaggerGen.dll  api-a            api-a.dll  api-a.runtimeconfig.json      appsettings.json  web.config
Swashbuckle.AspNetCore.Swagger.dll  Swashbuckle.AspNetCore.SwaggerUI.dll   api-a.deps.json  api-a.pdb  appsettings.Development.json  secrets

# Check the secrets folder
root@lab8-task1-776c98fb8b-9kmp6:/app# ls secrets
appsettings.secrets.json

# Check content of secrets/appsettings.secrets.json file
root@lab8-task1-776c98fb8b-9kmp6:/app# cat secrets/appsettings.secrets.json
{
    "Database": {
        "ConnectionString": "Connection string from kubernetes secret."
    }
}

# Exit
root@lab8-task1-776c98fb8b-9kmp6:/app# exit
```

Now, let's test the app. Split your terminal in two. At the right-hand window start the following command to stream logs from the pod

```bash
# Stream logs from lab8-task1 pods
kubectl logs -l app=lab8-task1 -f
```

The rest of the exercise do at the left-hand window.

```bash
# Get pod IP
kubectl get po -l app=lab8-task1 -o wide
NAME                          READY   STATUS    RESTARTS   AGE     IP            NODE                                NOMINATED NODE   READINESS GATES
lab8-task1-776c98fb8b-9kmp6   1/1     Running   0          7m58s   10.244.0.46   aks-nodepool1-95835493-vmss000000

# Start test shell
kubectl run curl -i --tty --rm --restart=Never --image=radial/busyboxplus:curl -- sh
# Test the secrettest endpoint several times
[ root@curl:/ ]$ curl http://10.244.0.46/secrettest
[ root@curl:/ ]$ curl http://10.244.0.46/secrettest
[ root@curl:/ ]$ curl http://10.244.0.46/secrettest
[lab-08] - OK
```

You should see the following logs at the log stream

```bash
info: api_a.Controllers.SecretTestController[0]
      [lab-08] - Database:ConnectionString: Connection string from kubernetes secret.
info: api_a.Controllers.SecretTestController[0]
      [lab-08] - Database:ConnectionString: Connection string from kubernetes secret.
info: api_a.Controllers.SecretTestController[0]
      [lab-08] - Database:ConnectionString: Connection string from kubernetes secret.            
```

As you can see, app reads connection string deployed as a secret. 


## Task #2 - working with ConfigMap

Create `logging-appsettings.yaml` file with the following Config Map definition 

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: logging-appsettings
data:
  appsettings.json: |-
    {
      "Logging": {
        "LogLevel": {
          "Default": "Error",
          "Microsoft": "Error",
          "Microsoft.Hosting.Lifetime": "Error"
        }
      }
    }
```

Deploy config map 

```bash
# Deploying config map from `logging-appsettings.yaml` file
kubectl apply -f .\logging-appsettings.yaml

# Get a list of config map instances
kubectl get configmap
NAME                  DATA   AGE
logging-appsettings   1      91m

# Get config map yaml. Note, I used alias cm instead of configmap
kubectl get cm logging-appsettings -o yaml

# Get configmap details
kubectl describe cm logging-appsettings
```

Create Deployment file `lab8-task2-deployment.yaml` with the following definition

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: lab8-task2
  labels:
    app: lab8-task2
spec:
  replicas: 1
  selector:
    matchLabels:
      app: lab8-task2
  template:
    metadata:
      labels:
        app: lab8-task2
    spec:
      containers:
      - name: api
        image: iacaksws1<YOU-NAME>acr.azurecr.io/apia:v1
        imagePullPolicy: IfNotPresent
        resources: {}
        livenessProbe:
          httpGet:
            path: /health
            port: 80
          initialDelaySeconds: 3
          periodSeconds: 3    
        readinessProbe:
          httpGet:
            path: /readiness
            port: 80
          initialDelaySeconds: 3
          periodSeconds: 3
        volumeMounts:
        - name: secrets
          mountPath: /app/secrets
          readOnly: true          
        - name: logging-config
          mountPath: /app/config          
      volumes:
      - name: secrets
        secret:
          secretName: secret-appsettings
      - name: logging-config
        configMap:
          name: logging-appsettings
```

Under the `volumes` section we added new item called `logging-config` of type `configMap` and we use ConfigMap `logging-appsettings` that we just deployed.
```yaml
      volumes:
      ...
      - name: logging-config
        configMap:
          name: logging-appsettings
```

Inside container template spec section we added the following configuration

```yaml
        volumeMounts:
        - name: logging-config
          mountPath: /app/config          
```

This configuration will create folder `app/config` inside pod filesystem and will map contents of ConfigMap into the files under this folder. In our case, `logging-appsettings` config map only contains one item called `appsettings.json`, so, we should expect one `appsettings.json` file created inside `app/config` folder. 

Now, let's deploy our Deployment

```bash
# Deploy lab8-task2-deployment.yaml 
kubectl apply -f .\lab8-task2-deployment.yaml

# Wait until deployment is successfully rolled out

# Get pod name
kubectl get po -l app=lab8-task2
NAME                          READY   STATUS    RESTARTS   AGE
lab8-task2-8484dcdb58-4t74b   1/1     Running   0          59m

# Attach to the pod
kubectl exec -it lab8-task2-8484dcdb58-4t74b -- bash

# check the folder structure
root@lab8-task2-8484dcdb58-4t74b:/app#  ls
Microsoft.OpenApi.dll                  api-a            api-a.runtimeconfig.json      secrets
Swashbuckle.AspNetCore.Swagger.dll     api-a.deps.json  appsettings.Development.json  web.config
Swashbuckle.AspNetCore.SwaggerGen.dll  api-a.dll        appsettings.json
Swashbuckle.AspNetCore.SwaggerUI.dll   api-a.pdb        config

# Check the config folder
root@lab8-task2-8484dcdb58-4t74b:/app# ls config
appsettings.json

# Check content of config/appsettings.json file
root@lab8-task2-8484dcdb58-4t74b:/app# cat config/appsettings.json
{
  "Logging": {
    "LogLevel": {
      "Default": "Error",
      "Microsoft": "Error",
      "Microsoft.Hosting.Lifetime": "Error"
    }
  }
}

# Exit
root@lab8-task2-8484dcdb58-4t74b:/app# exit
```

As you can see this file contains what's inside the Config Map `logging-appsettings->data.appsettings.json` element.

## Task #3 - Changing ConfigMap

Split your terminal in two. At right-hand window run the following command 

```bash
# Get logs from the lab8-task2 pods
kubectl logs -l app=lab8-task2 -f
```

At the left-hand window start our test shell

```bash
# Get pod IP
kubectl get po -o wide | grep lab8-task2
lab8-task2-8484dcdb58-4t74b   1/1     Running            0          68m   10.244.0.41   aks-nodepool1-95835493-vmss000000   <none>           <none>

# Start testing shell
kubectl run curl -i --tty --rm --restart=Never --image=radial/busyboxplus:curl -- sh

# Test configmaptest endpoint
[ root@curl:/ ]$ curl http://10.244.0.41/configmaptest
[ root@curl:/ ]$ curl http://10.244.0.41/configmaptest
[ root@curl:/ ]$ curl http://10.244.0.41/configmaptest
[ root@curl:/ ]$ curl http://10.244.0.41/configmaptest
```

Note that there are only two type of logs shown for each request: `Error` and `Critical`

```bash
fail: api_a.Controllers.ConfigMapTestController[0]
      Error log
crit: api_a.Controllers.ConfigMapTestController[0]
      Critical log
```

This is because config map configured `Error` log level for everything.

Now, edit configmap

```bash
kubectl edit cm logging-appsettings
```

Inside the editor change `appsettings.json` to 

```yaml
  appsettings.json: |-
    {
      "Logging": {
        "LogLevel": {
          "Default": "Information",
          "Microsoft": "Error",
          "Microsoft.Hosting.Lifetime": "Error"
        }
      }
    }
```

Save file and exit. Then wait for about 1 min and test `configmaptest` endpoint again.

```bash
# Test configmaptest endpoint
[ root@curl:/ ]$ curl http://10.244.0.41/configmaptest
[ root@curl:/ ]$ curl http://10.244.0.41/configmaptest
[ root@curl:/ ]$ curl http://10.244.0.41/configmaptest
[ root@curl:/ ]$ curl http://10.244.0.41/configmaptest
```

observe logs. There are 4 logs for each request: `Information`, `Warning`, `Error`, `Critical`

```bash
info: api_a.Controllers.ConfigMapTestController[0]
      Information log
warn: api_a.Controllers.ConfigMapTestController[0]
      Warning log
fail: api_a.Controllers.ConfigMapTestController[0]
      Error log
crit: api_a.Controllers.ConfigMapTestController[0]
      Critical log
```

You probably noticed logs from `health` and `readiness` endpoints are also shown in the logs stream.

## Useful links

* [Managing ASP.NET Core App Settings on Kubernetes](https://anthonychu.ca/post/aspnet-core-appsettings-secrets-kubernetes/)
* [.NET Configuration in Kubernetes config maps with auto reload](https://medium.com/@fbeltrao/automatically-reload-configuration-changes-based-on-kubernetes-config-maps-in-a-net-d956f8c8399a)
* [.NET Configuration in Kubernetes config maps with auto reload - repo](https://github.com/fbeltrao/ConfigMapFileProvider)
* [Configuration in ASP.NET Core](https://docs.microsoft.com/en-us/aspnet/core/fundamentals/configuration/?view=aspnetcore-5.0)
* [Kubernetes Secret](https://kubernetes.io/docs/concepts/configuration/secret/)
* [Kubernetes ConfigMaps](https://kubernetes.io/docs/concepts/configuration/configmap/)
* [kubectl create secret](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#-em-secret-em-)
* [Configure a Pod to Use a ConfigMap](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/)
* [Managing Secret using kubectl](https://kubernetes.io/docs/tasks/configmap-secret/managing-secret-using-kubectl/)

## Next: name of next lab

[Go to lab-09](../lab-09/readme.md)
