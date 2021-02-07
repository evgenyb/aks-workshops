# lab-05 - Readiness and Liveness probes

## Estimated completion time - xx min

Kubernetes supports monitoring applications in the form of readiness and liveness probes. 

### Liveness probes
Liveness probe indicates a container is "alive". Many applications running for long periods of time eventually transition to broken states, and cannot recover except by being restarted. Kubernetes provides liveness probes to detect and remedy such situations. If a liveness probe fails multiple times the container will be restarted. Liveness probes that continue to fail will cause a Pod to enter a crash loop.

### Readiness probes
Sometimes, applications are temporarily unable to serve traffic. For example, an application might need to load large data or configuration files during startup, or depend on external services after startup. In such cases, you don't want to kill the application, but you don't want to send it requests either. Kubernetes provides readiness probes to detect and mitigate these situations. A pod with containers reporting that they are not ready does not receive traffic through Kubernetes Services.

Readiness and liveness probes can be used in parallel for the same container. Using both can ensure that traffic does not reach a container that is not ready for it, and that containers are restarted when they fail.

In this lab we will extend our application with additional readiness and liveness endpoints and extend pod definition with readiness and liveness probes.

## Goals

In this lab you will learn how to:

* create Pods with readiness and liveness probes
* troubleshoot failing readiness and liveness probes

## Task #1 - configure your Windows Terminal

As with `lab-04`, split your terminal in two. At the right-hand window, run `kubectl get po -w` command and at the left-hand window execute labs commands.

## Task #2 - add Liveness probe

Create new yaml pod definition file `lab-05-healthy.yaml` with the following content. 
Note that you should use your own ACR url for `image` field and that there is new `livenessProbe` section in the definition

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: lab-05-healthy
spec:
  containers:
  - name: api
    image: iacaksws1<YOUR-NAME>acr.azurecr.io/apia:v1
    imagePullPolicy: IfNotPresent
    resources: {}
    livenessProbe:
      httpGet:
        path: /health
        port: 80
      initialDelaySeconds: 3
      periodSeconds: 3    
```

Now, deploy it

```bash
# Deploying lab-05-healthy.yaml
kubectl apply -f lab-05-healthy.yaml

```

Check the `lab-05-healthy` logs

```bash
# Stream logs from lab-05-healthy pod
kubectl logs lab-05-healthy -f
info: api_a.Controllers.HealthController[0]
      [lab-05 task #1] - always healthy
info: api_a.Controllers.HealthController[0]
      [lab-05 task #1] - always healthy
info: api_a.Controllers.HealthController[0]
      [lab-05 task #1] - always healthy
info: api_a.Controllers.HealthController[0]
      [lab-05 task #1] - always healthy
info: api_a.Controllers.HealthController[0]
      [lab-05 task #1] - always healthy
info: api_a.Controllers.HealthController[0]
      [lab-05 task #1] - always healthy
```

As you can see, the `/health` endpoint is now called every 3 seconds (`periodSeconds` field).

The `periodSeconds` field specifies that the kubelet should perform a liveness probe every 3 seconds. The `initialDelaySeconds` field tells the kubelet that it should wait 3 seconds before performing the first probe. To perform a probe, the kubelet sends an HTTP GET request to the server that is running in the container and listening on port 80. If the handler for the server's `/health` path returns a success code, the kubelet considers the container to be alive and healthy. If the handler returns a failure code, the kubelet kills the container and restarts it. 

Let's try to simulate such a situation.

## Task #3 - add Liveness probe with unhealthy endpoint

For this task let's use `/health/almost_healthy` endpoint for `livenessProbe` get request. Check implementation of `AlmostHealthy` method at `01-aks-and-k8s-101\app\api-a\Controllers\HealthController.cs` file. 
It contains extra logic that for the first 10 seconds that the app is alive, the `/health/almost_healthy` handler returns a status of 200. After that, the handler returns a status of 500.

```c#
var secondsFromStart = Timekeeper.GetSecondsFromStart();
_logger.LogInformation($"{secondsFromStart} seconds from start...");
var secondsToWait = 10;
if (secondsFromStart < secondsToWait)
{
    _logger.LogInformation($"< {secondsToWait} seconds -> response with 200");
    return Ok("[lab-05 task #2] - healthy first 10 sec");
}
else
{
    _logger.LogInformation($"> {secondsToWait} seconds -> response with 500");
    return StatusCode(500); 
}
```

Create new yaml pod definition file `lab-05-almost-healthy.yaml` with the following content. 
Note that you should use your ACR url for `image` field and that `path:` now points to `/health/almost_healthy`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: lab-05-almost-healthy
spec:
  containers:
  - name: api
    image: iacaksws1<YOUR-NAME>acr.azurecr.io/apia:v1
    imagePullPolicy: IfNotPresent
    resources: {}
    livenessProbe:
      httpGet:
        path: /health/almost_healthy
        port: 80
      initialDelaySeconds: 3
      periodSeconds: 3    
```

Deploy it

```bash
# Deploy lab-05-almost-healthy.yaml
kubectl apply -f .\lab-05-almost-healthy.yaml
```

The kubelet starts performing health checks 3 seconds after the container starts. So the first couple of health checks will succeed. But after 10 seconds, the health checks will fail, and the kubelet will kill and restart the container. After several attempts, pod will go into `CrashLoopBackOff` state.

Your "watching" log should show something similar to 

```bash
lab-05-almost-healthy   0/1     Pending   0          0s
lab-05-almost-healthy   0/1     Pending   0          0s
lab-05-almost-healthy   0/1     ContainerCreating   0          0s
lab-05-almost-healthy   1/1     Running             0          2s
lab-05-almost-healthy   1/1     Running             1          12s
lab-05-almost-healthy   1/1     Running             2          20s
lab-05-almost-healthy   0/1     CrashLoopBackOff    2          29s
lab-05-almost-healthy   1/1     Running             3          43s
lab-05-almost-healthy   1/1     Running             4          54s
lab-05-almost-healthy   0/1     CrashLoopBackOff    4          63s
```

and if you get pod description, under the `Events:` section you should see that pod was `Unhealthy` because `Liveness probe failed: HTTP probe failed with statuscode: 500` and then pod was killed because `Container api failed liveness probe, will be restarted`.

```bash
# Get pod description
kubectl describe po lab-05-almost-healthy
...
Events:
  Type     Reason     Age                 From               Message
  ----     ------     ----                ----               -------
  Normal   Killing    42s (x3 over 78s)   kubelet            Container api failed liveness probe, will be restarted
  Normal   Started    41s (x4 over 95s)   kubelet            Started container api
  Warning  Unhealthy  30s (x10 over 84s)  kubelet            Liveness probe failed: HTTP probe failed with statuscode: 500
```

## Task #4 - add Readiness probe

Readiness probes are configured similarly to liveness probes. The only difference is that you use the readinessProbe field instead of the livenessProbe field.

Create new yaml pod definition file `lab-05-ready.yaml` with the following content. 
Note that you should use your ACR url for `image` field and there is additional `readinessProbe` section 

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: lab-05-ready
spec:
  containers:
  - name: api
    image: iacaksws1<YOUR-NAME>acr.azurecr.io/apia:v1
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
```

Now, deploy it

```bash
# Deploying lab-05-ready.yaml
kubectl apply -f lab-05-ready.yaml
```

Check the `lab-05-ready` logs

```bash
# Stream logs from lab-05-ready pod
kubectl logs lab-05-ready -f
info: api_a.Controllers.ReadinessController[0]
      [lab-05 task #4] - always ready
info: api_a.Controllers.HealthController[0]
      [lab-05 task #1] - always healthy
info: api_a.Controllers.ReadinessController[0]
      [lab-05 task #4] - always ready
info: api_a.Controllers.HealthController[0]
      [lab-05 task #1] - always healthy```

As you can see, both  `/health` and `/readiness` endpoints are called every 3 seconds.

## Task #5 - add Readiness probe with unstable endpoint

For this task we will use `/readiness/unstable` endpoint for `livenessProbe` get request. Check implementation of `Unstable` method at `01-aks-and-k8s-101\app\api-a\Controllers\ReadinessController.cs` Controller. 
It contains extra logic that response status changes every minute. That is - first minute - 200 and next minute - 500.


Create new yaml pod definition file `lab-05-ready-unstable.yaml` with the following content. 
Note that you should use your ACR url for `image` field and `readinessProbe` points to `/readiness/unstable` endpoint

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: lab-05-ready-unstable
spec:
  containers:
  - name: api
    image: iacaksws1<YOUR-NAME>acr.azurecr.io/apia:v1
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
        path: /readiness/unstable
        port: 80
      initialDelaySeconds: 3
      periodSeconds: 3               
```

Now, deploy it

```bash
# Deploying lab-05-ready-unstable.yaml
kubectl apply -f lab-05-ready-unstable.yaml
```
and observe what happens at the "watch" window. You should see similar behavior:
```bash
lab-05-ready-unstable   0/1     Pending            0          0s
lab-05-ready-unstable   0/1     Pending            0          0s
lab-05-ready-unstable   0/1     ContainerCreating   0          0s
lab-05-ready-unstable   0/1     Running             0          2s
lab-05-ready-unstable   1/1     Running             0          62s
lab-05-ready-unstable   0/1     Running             0          2m8s
lab-05-ready-unstable   1/1     Running             0          3m2s
lab-05-ready-unstable   0/1     Running             0          4m8s
```
as you can see, it changes status from `Running` to not running, but it never goes into the `CrashLoopBackOff` status.

Check the pod description 

```bash
# Get pod description
kubectl describe po lab-05-ready-unstable
...
Events:
  Type     Reason     Age                    From               Message
  ----     ------     ----                   ----               -------
  Normal   Created    13m                    kubelet            Created container api
  Normal   Started    13m                    kubelet            Started container api
  Warning  Unhealthy  3m41s (x100 over 13m)  kubelet            Readiness probe failed: HTTP probe failed with statuscode: 500
  ```

The sate was `Unhealthy` 100 times over the last 13 min with reason `Readiness probe failed: HTTP probe failed with statuscode: 500`

## Useful links

* [Configure Liveness, Readiness and Startup Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)

## Next: Deployments

[Go to lab-06](../lab-06/readme.md)
