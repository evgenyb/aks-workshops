# lab-04 - Creating and managing pods

## Estimated completion time - xx min

intro 

## Goals

* Learn how to run application at AKS
* Learn how to get list of pods
* Learn how to use port forward to test pod
* Learn how to get logs from the pod
* Learn how to get detailed information about the pod
* Learn how to get pod description
* Learn how to get delete pods

## Task #1 - run application at AKS

Now that we published several versions of out application image into ACR, and our AKS cluster is integrated with ACR, we can run our application inside the AKS

```bash
kubectl run app-a --image iacaksws1<YOU-NAME>acr.azurecr.io/apia:v1
pod/app-a created
```

As you can see, Kubernetes reporting that `pod` `app-a` was created.

Now, let's run another version of application (tagged with `:1.0.0`), this time let's call it `app-b`

```bash
kubectl run app-b --image iacaksws1<YOU-NAME>acr.azurecr.io/apia:1.0.0
pod/app-b created
```

## Task #2 - get information about pods

To get all pods, use the following command

```bash
kubectl get pod
NAME    READY   STATUS    RESTARTS   AGE
app-a   1/1     Running   0          5h18m
app-b   1/1     Running   0          13s
```

as you can see, there are 2 pods running. Both have status `Running` and `Ready` column contains `1/1`, which means that 1 out of 1 pods are in `Running` state. 
To get even more information about pods, use `-o wide` flag

```bash
kubectl get po -o wide
NAME    READY   STATUS    RESTARTS   AGE     IP            NODE                                NOMINATED NODE   READINESS GATES
app-a   1/1     Running   0          5h21m   10.244.0.9    aks-nodepool1-95835493-vmss000000   <none>           <none>
app-b   1/1     Running   0          2m49s   10.244.0.10   aks-nodepool1-95835493-vmss000000   <none>           <none>
```

as you can see, now report contains additional information about pods, such as IP address and node name where pods was created.

For the next exercise, open 2 terminals side by side, (or, if you use Windows Terminal, you can split your current session in two by clicking `Shift+Alt+D`). 
In first terminal, run the following command, note `-w` flag

```bash
kubectl get pod -w
```

in the second terminal, let's start the third image from our ACR (tagged with `:latest`) and let's call it `app-c`

```bash
kubectl run app-c --image iacaksws1<YOU-NAME>acr.azurecr.io/apia:latest
pod/app-c created
```

and then observe what is reported at the first terminal. You should see something similar to

```bash
kubectl.exe get po -w
NAME    READY   STATUS    RESTARTS   AGE
app-a   1/1     Running   0          5h39m
app-b   1/1     Running   0          21m
app-c   0/1     Pending   0          0s
app-c   0/1     Pending   0          0s
app-c   0/1     ContainerCreating   0          0s
app-c   0/1     Running             0          5s
app-c   1/1     Running             0          15s
```

`-w` flag is a short version of `--watch` and after listing/getting the requested object (pod in this case), it will watch for changes. As you can see, `app-c` pod was first in `ContainerCreating` state and then, eventually, changed the status to `Running` `0/1` and finally `1/1`.

## Task #3 - get detailed information about pod 

You can get information about one pod by running 

```bash
kubectl get po app-a
NAME    READY   STATUS    RESTARTS   AGE
app-a   1/1     Running   0          20h
```

note, I used `po` instead of `pod`. This is alias that you can use to save soe keystrokes :)

```bash
# -o wide will give you even more information 
kubectl get po app-a -o wide
NAME    READY   STATUS    RESTARTS   AGE   IP           NODE                                NOMINATED NODE   READINESS GATES
app-a   1/1     Running   0          20h   10.244.0.9   aks-nodepool1-95835493-vmss000000   <none>           <none>
```

To get pod manifest, use `-o yaml` or `-o json` 

```bash
kubectl get po app-a -o yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: "2021-02-01T14:40:22Z"
  labels:
    run: app-a
...
```

## Task #4 - testing within cluster with interactive shell

Quite often you need to test application from within your cluster. Because cluster is running inside it's own Virtual Network, nothing is accessible from your PC. 
Let's try to ping of the running `app-a|b|c` pods.

```bash
# Get pods IP addresses
kubectl get po -o wide
NAME    READY   STATUS    RESTARTS   AGE     IP            NODE                                NOMINATED NODE   READINESS GATES
app-a   1/1     Running   0          27h     10.244.0.9    aks-nodepool1-95835493-vmss000000   <none>           <none>
app-b   1/1     Running   0          21h     10.244.0.10   aks-nodepool1-95835493-vmss000000   <none>           <none>
app-c   1/1     Running   0          21h     10.244.0.11   aks-nodepool1-95835493-vmss000000   <none>           <none>

# try to ping `app-a`
ping 10.244.0.9

Pinging 10.244.0.9 with 32 bytes of data:
Request timed out.
```

One common solution is to run a test pod that you can attach to and run shell commands from inside the pod. There are several well known images for such a tasks, one of them called [busybox](https://busybox.net/), but the image we will use is [busyboxplus:curl](https://hub.docker.com/r/radial/busyboxplus). This is because it contains `curl` command that need for our testing. 

```bash
# Run pod as interactive shell
kubectl run curl -i --tty --rm --restart=Never --image=radial/busyboxplus:curl -- sh
# Here is prompt from withing the pod
[ root@curl:/ ]$ 

# Now, try to ping the same IP
[ root@curl:/ ]$ ping 10.244.0.9
PING 10.244.0.9 (10.244.0.9): 56 data bytes
64 bytes from 10.244.0.9: seq=0 ttl=64 time=0.134 ms
64 bytes from 10.244.0.9: seq=1 ttl=64 time=0.095 ms
64 bytes from 10.244.0.9: seq=2 ttl=64 time=0.094 ms
^C
--- 10.244.0.9 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 0.094/0.107/0.134 ms

# Exit from the pod
[ root@curl:/ ]$ exit
pod "curl" deleted
```

Couple of things to mention here:

1. As expected, IP address is accessible from inside the pod. 
2. The `curl` pod was deleted when we exit. This is because of  `--rm` flag that tells Kubernetes to delete pod created by this command.

## Task #5 - delete pod

Now, let's delete `curl` pod. 

```bash
# delete single pod
kubectl delete pod curl
pod "curl" deleted
```

## Task #4 - testing within cluster with interactive shell

In previous task we used `kubectl run -i --tty --image=...` command every time we wanted to test/debug applications in our cluster. Alternative solution can be to deploy permanent pod to the cluster and attach to it when needed. This time let's do it with yaml pod definition file and deploy it using `kubectl apply ` command. 

Create new file `curl-pod.yaml` file under `lab-04` folder and add the following pod definition

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: curl
spec:
  containers:
    - name: curl
      image: "radial/busyboxplus:curl"      
      command:
        - sleep
        - "3600"
  restartPolicy: Always
```

save the file and run the following command (from within `lab-04` folder)

```bash
# deploy curl pod

kubectl apply -f curl-pod.yaml
pod/curl created

# check pod status and wait when it gets status Running
kubectl get po curl
NAME   READY   STATUS    RESTARTS   AGE
curl   1/1     Running   0          5m35s
```

As you can see from the pod definition file, it uses command `sleep 3600` and `restartPolicy: Always`. `sleep 3600` means that pod will be "alive" for 3600 seconds = 1 hour and then it will terminate itself. But since parameter `restartPolicy` is set to `Always`, Kubernetes will start new pod. That means that with this configuration, pod will be restarted every hour and it will look like it always running.

Now, set `sleep` parameter to `60` and deploy changes. Observe what will happen with `kubectl get po curl -w` in "monitoring" terminal.

```bash
kubectl apply -f .\curl-pod.yaml
The Pod "curl" is invalid: spec: Forbidden: pod updates may not change fields other than `spec.containers[*].image`, `spec.initContainers[*].image`, `spec.activeDeadlineSeconds` or `spec.tolerations` (only additions to existing tolerations)
...
```

We can't update this pod, therefore we need to delete existing one and create new one.

```bash
# delete existing pod 
kubectl delete po curl

# deploy new one
kubectl apply -f .\curl-pod.yaml
pod/curl created
```

Wait for couple of minutes and you will see the following behavior in the "monitoring" terminal (`kubectl get po curl -w`).

```bash
kubectl get po -w
NAME    READY   STATUS    RESTARTS   AGE
app-a   1/1     Running   0          29h
app-b   1/1     Running   0          23h
app-c   1/1     Running   0          23h
curl    0/1     Pending   0          0s
curl    1/1     Running             0          2s
curl    0/1     Completed           0          62s
curl    1/1     Running             1          63s
curl    0/1     Completed           1          2m3s
curl    0/1     CrashLoopBackOff    1          2m18s
curl    1/1     Running             2          2m19s
curl    0/1     Completed           2          3m19s
curl    0/1     CrashLoopBackOff    2          3m32s
curl    1/1     Running             3          3m48s
```

## Task #3 - get pod logs

You can check pod logs by running the following command

```bash
kubectl logs app-a
info: Microsoft.Hosting.Lifetime[0]
      Now listening on: http://[::]:80
info: Microsoft.Hosting.Lifetime[0]
      Application started. Press Ctrl+C to shut down.
info: Microsoft.Hosting.Lifetime[0]
      Hosting environment: Production
info: Microsoft.Hosting.Lifetime[0]
      Content root path: /app
```

or, if you want to continuously monitor logs, use `-f` flag

```bash
kubectl logs app-a -f
info: Microsoft.Hosting.Lifetime[0]
      Now listening on: http://[::]:80
info: Microsoft.Hosting.Lifetime[0]
      Application started. Press Ctrl+C to shut down.
info: Microsoft.Hosting.Lifetime[0]
      Hosting environment: Production
info: Microsoft.Hosting.Lifetime[0]
      Content root path: /app
```


## Task #3 - use Port Forwarding to access your application in a cluster

```bash
# Listen on port 7000 on the local machine and forward to port 80 on app-a
kubectl port-forward app-a 7000:80
Forwarding from 127.0.0.1:7000 -> 80
Forwarding from [::1]:7000 -> 80
```

Now open new terminal (if you use Windows Terminal click `Shift+Alt+D` and it will split your current terminal in 2). In new terminal run the following command

```bash
curl http://localhost:7000/weatherforecast
[{"date":"2021-02-01T21:45:40.0602016+00:00","temperatureC":19,"temperatureF":66,"summary":"Warm"},{"date":"2021-02-02T21:45:40.0621127+00:00","temperatureC":30,"temperatureF":85,"summary":"Scorching"},{"date":"2021-02-03T21:45:40.0621165+00:00","temperatureC":-16,"temperatureF":4,"summary":"Sweltering"},{"date":"2021-02-04T21:45:40.0621169+00:00","temperatureC":45,"temperatureF":112,"summary":"Mild"},{"date":"2021-02-05T21:45:40.0621171+00:00","temperatureC":18,"temperatureF":64,"summary":"Sweltering"}]
```

That looks quite ugly, so, if you want nicely formatted json, install `jq`. On PowerShell, use `choco install jq`. When installed, run the following command:

```bash
curl -s http://localhost:7000/weatherforecast | jq
[
  {
    "date": "2021-02-01T21:47:51.9523787+00:00",
    "temperatureC": -9,
    "temperatureF": 16,
    "summary": "Sweltering"
  },
  {
    "date": "2021-02-02T21:47:51.9523827+00:00",
    "temperatureC": 19,
    "temperatureF": 66,
    "summary": "Cool"
  },
  {
    "date": "2021-02-03T21:47:51.9523837+00:00",
    "temperatureC": 3,
    "temperatureF": 37,
    "summary": "Freezing"
  },
  {
    "date": "2021-02-04T21:47:51.9523839+00:00",
    "temperatureC": 12,
    "temperatureF": 53,
    "summary": "Sweltering"
  },
  {
    "date": "2021-02-05T21:47:51.9523841+00:00",
    "temperatureC": -5,
    "temperatureF": 24,
    "summary": "Bracing"
  }
]
```



## Useful links

* [Kubernetes Pods](https://kubernetes.io/docs/concepts/workloads/pods/)
* [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
* [Interacting with running Pods](https://kubernetes.io/docs/reference/kubectl/cheatsheet/#interacting-with-running-pods)
* [Formatting output](https://kubernetes.io/docs/reference/kubectl/cheatsheet/#formatting-output)
* [https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/](https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/)

* link 2

## Next: Readiness and Liveness probes

[Go to lab-05](../lab-05/readme.md)