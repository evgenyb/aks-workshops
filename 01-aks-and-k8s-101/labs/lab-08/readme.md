# lab-08 - Configmaps and secrets

## Estimated completion time - xx min

intro 

## Goals

In this lab you will learn how to:

* create Kubernetes secrets 
* mount contents of the Secret into the folder
* use Kubernetes secrets to override some properties in an ASP.NET Core app's configuration at runtime
* crate Kubernetes Config Map
* mount the contents of the config map into the folder
* use config map as mounted configuration file

## Task #1 - create Kubernetes Secret and read it as Configuration parameter from the application



```bash
# Create new secret from the file
kubectl create secret generic secret-appsettings --from-file=./appsettings.secrets.json

```

## Task #2 - ConfigMap

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

There are also logs from `health` and `readiness` showing int the logs stream.

## Useful links

* [Managing ASP.NET Core App Settings on Kubernetes](https://anthonychu.ca/post/aspnet-core-appsettings-secrets-kubernetes/)
* [.NET Configuration in Kubernetes config maps with auto reload](https://medium.com/@fbeltrao/automatically-reload-configuration-changes-based-on-kubernetes-config-maps-in-a-net-d956f8c8399a)
* [.NET Configuration in Kubernetes config maps with auto reload - repo](https://github.com/fbeltrao/ConfigMapFileProvider)
* [Configuration in ASP.NET Core](https://docs.microsoft.com/en-us/aspnet/core/fundamentals/configuration/?view=aspnetcore-5.0)
* [Kubernetes Secret](https://kubernetes.io/docs/concepts/configuration/secret/)
* [Kubernetes ConfigMaps](https://kubernetes.io/docs/concepts/configuration/configmap/)
* [Configure a Pod to Use a ConfigMap](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/)


## Next: name of next lab

[Go to lab-09](../lab-09/readme.md)
