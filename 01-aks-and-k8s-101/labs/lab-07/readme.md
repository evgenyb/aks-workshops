# lab-07 - Creating and Managing Services

## Estimated completion time - xx min

Service in Kubernetes is an abstract way to expose an application running on a set of Pods as a network service.
Kubernetes gives Pods their own IP addresses and a single DNS name for a set of Pods, and can load-balance across them.
Kubernetes Pods are created and destroyed to match the state of your cluster. Each Pod gets its own IP address, however in a Deployment, the set of Pods running in one moment in time could be different from the set of Pods running that application a moment later.

This leads to a problem: if some set of Pods (`app-a`) provides functionality to other Pods (`app-b`) inside your cluster, how do the `app-a` find out and keep track of which IP address to connect to, so that the `app-a` can use the `app-b` part of the workload?

The name of a Service object must be a valid DNS label name.

ServiceTypes

ClusterIP - Exposes the Service on a cluster-internal IP. Choosing this value makes the Service only reachable from within the cluster. This is the default ServiceType.

## Goals

In this lab you will learn how to:

* create Kubernetes Service using `kubectl expose` command
* create Kubernetes Service using yaml definition
* update Kubernetes Service using yaml definition
* delete Kubernetes Service

## Task #1 - prepare your lab environment

As with `lab-06`, split your terminal in two. At the right-hand window, run `kubectl get svc -w` command and at the left-hand window execute labs commands.

## Task #2 - deploy Deployment from lab-06

If you completed `lab-06` and deleted Deployment we created during this lab, Deploy it again

```bash
# Deploy lab6-task3-deployment.yaml Deployment
kubectl apply -f .\lab6-task3-deployment.yaml

# Check that rollout status is "successfully rolled out"
kubectl rollout status deployment/lab6-task3
deployment "lab6-task3" successfully rolled out
```

## Task #3 - Create Service using `kubectl expose` command

```bash
# Expose deployment lab6-task3 as a new Kubernetes service apia-service-1
kubectl expose deployment lab6-task3 --name=apia-service-1 --port=80 --target-port=80
service/apia-service-1 exposed

# Get all services 
kubectl get services 
NAME             TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
apia-service-1   ClusterIP   10.0.169.148   <none>        80/TCP    22m
kubernetes       ClusterIP   10.0.0.1       <none>        443/TCP   4d

# Show services with labels (note, that I use alias svc this time)
kubectl get svc --show-labels
NAME             TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE    LABELS
apia-service-1   ClusterIP   10.0.169.148   <none>        80/TCP    22m    app=lab6-task3
kubernetes       ClusterIP   10.0.0.1       <none>        443/TCP   4d     component=apiserver,provider=kubernetes

# Get service apia-service-1 yaml definition
kubectl get svc apia-service-1 -oyaml

# Get service apia-service-1 description 
kubectl describe svc apia-service-1
Name:              apia-service-1
Namespace:         default
Labels:            app=lab6-task3
Annotations:       <none>
Selector:          app=lab6-task3
Type:              ClusterIP
IP Families:       <none>
IP:                10.0.169.148
IPs:               <none>
Port:              <unset>  80/TCP
TargetPort:        80/TCP
Endpoints:         10.244.0.103:80
Session Affinity:  None
Events:            <none>
```

Now, let's test our service.

```bash
# Get service CLUSTER-IP
kubectl get svc apia-service-1 
NAME             TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
apia-service-1   ClusterIP   10.0.169.148   <none>        80/TCP    30m

# Start our test shell
kubectl run curl -i --tty --rm --restart=Never --image=radial/busyboxplus:curl -- sh

# Test our service using IP (you should use your IP)
[ root@curl:/ ]$ curl http://10.0.169.148/weatherforecast

# Test our service using service DNS name
[ root@curl:/ ]$ curl http://apia-service-1/weatherforecast

# Test our service using service full DNS name
[ root@curl:/ ]$ curl http://apiaapia-service-1.default.svc.cluster.local/weatherforecast

# Run test load with watch command. It will run "curl http://apia-service-1/weatherforecast" command every second until we stop it
watch -n 1 curl http://apia-service-1/weatherforecast
```

Keep the test running and open|split new terminal and scale Deployment `lab6-task3` down to 0 and see what will happen with our test.

```bash
kubectl scale deployment lab6-task3 --replicas=0
deployment.apps/lab6-task3 scaled
```
you should see that `curl: (7) Failed to connect to apia-service-1 port 80: Connection refused`. Now scale it back to 3 replicas

```bash
kubectl scale deployment lab6-task3 --replicas=3
deployment.apps/lab6-task3 scaled
```
and our app is back to business.

```bash
# Stop the watch command with Ctrl+C and leave the shell
[ root@curl:/ ]$exit
```

## Task #4 - Create service using yaml definition file

Create new `lab-07-apia-service-2.yaml` file with the following content

```yaml
apiVersion: v1
kind: Service
metadata:
  name: apia-service-2
  labels:
    app: lab6-task3
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: lab6-task3
  type: ClusterIP
```

Deploy it using `kubectl apply` command

```bash
# Deploy lab-07-apia-service-2.yaml service
kubectl apply -f .\lab-07-apia-service-2.yaml
service/apia-service-2 created

# Get service 
kubectl get svc apia-service-2 

# Get service apia-service-1 description 
kubectl describe svc apia-service-2

# Start test shell
kubectl run curl -i --tty --rm --restart=Never --image=radial/busyboxplus:curl -- sh

# Test service
[ root@curl:/ ]$ curl http://apia-service-2/weatherforecast

# Leave the shell
[ root@curl:/ ]$exit
```

## Task #6 - change service port

Now let's change Service port to `8081`. Edit `lab-07-apia-service-2.yaml` and replace `port: 80` with `port: 8081`, deploy and test it.

```bash
# Deploy lab-07-apia-service-2.yaml service
kubectl apply -f .\lab-07-apia-service-2.yaml
service/apia-service-2 configured

# Get service and check that PORT(S) field is now showing 8081/TCP 
kubectl get svc apia-service-2 
NAME             TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
apia-service-2   ClusterIP   10.0.164.163   <none>        8081/TCP   16m

# Start test shell
kubectl run curl -i --tty --rm --restart=Never --image=radial/busyboxplus:curl -- sh

# Test the service. Note that it doesn't work since we changed the port
[ root@curl:/ ]$ curl http://apia-service-2/weatherforecast

# Test using port :8081
[ root@curl:/ ]$ curl http://apia-service-2:8081/weatherforecast

# Leave the shell
[ root@curl:/ ]$exit
```

## Task #7 - delete service

There are several ways you can delete service

```bash
# Delete apia-service-1 Service using `kubectl delete svc ` command
kubectl delete svc apia-service-1
service "apia-service-1" deleted

# Delete apia-service-2 Service using yaml definition file
kubectl delete -f .\lab-07-apia-service-2.yaml
service "apia-service-2" deleted
```

## Useful links

* [Kubernetes Service](https://kubernetes.io/docs/concepts/services-networking/service/)
* [Use a Service to Access an Application in a Cluster](https://kubernetes.io/docs/tasks/access-application-cluster/service-access-application-cluster/)
* [kubectl expose](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#expose)

## Next: Configmaps and secrets

[Go to lab-08](../lab-08/readme.md)

## Feedback

* Visit the [Github Issue](https://github.com/evgenyb/aks-workshops/issues/8) to comment on this lab. 