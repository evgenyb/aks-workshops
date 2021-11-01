# lab-02 - post provisioning cluster configuration

## Estimated completion time - xx min

When cluster is ready and before you start deploying your workloads, you need to configure it. Depending on your use-case, you will need to deploy and configure different resources components, such as namespaces, RBAC rules, Network Policy rules, Ingress Controller, Azure Pod Identity etc...

For our workshop, we will configure namespaces and NGINX ingress controller to an internal virtual network. 

## Goals

* Deploy namespace using `kubectl` command
* Implement namespaces as a k8s manifest file and deploy it using using `kubectl`
* Deploy NGINX ingress controller as a Helm chart

## Task #1 - deploy namespaces

One of the first tasks when cluster is provisioned, is to create a set of `namespaces` for your k8s workload. You can use `namespaces` to isolate workload that belong to different teams, environments, domains or any other logical item. In our example, we need to create three namespaces: `team-a`, `team-b` and `team-c`. Let's define a kubernetes manifest file for two  fo them and create on using `kubectl` command.

Create `namespaces.yaml` file with the following content

```yaml
---
apiVersion: v1
kind: Namespace
metadata:
  name: team-b
---
apiVersion: v1
kind: Namespace
metadata:
  name: team-c
```

```bash
# Create namespace using kubectl command
kubectl create ns team-a
namespace/team-a created

# Create namespaces using k8s manifest file
kubectl apply -f ./namespaces.yaml
namespace/team-b created
namespace/team-c created

# Get all namespaces
kubectl get ns
NAME              STATUS   AGE  
default           Active   66m  
kube-node-lease   Active   66m  
kube-public       Active   66m  
kube-system       Active   66m  
kured             Active   10m  
nginx-ingress     Active   12m  
team-a            Active   5m16s
team-b            Active   5m   
team-c            Active   5m   
```

## Task #2 - install nginx ingress controller

An [ingress controller](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/) is a piece of software that provides reverse proxy, configurable traffic routing, and TLS termination for Kubernetes services. Kubernetes ingress resources are used to configure the ingress rules and routes for individual Kubernetes services. Using an ingress controller and ingress rules, a single IP address can be used to route traffic to multiple services in a Kubernetes cluster.

Create a file named `internal-ingress.yaml` using the following example manifest file. This example assign `10.11.1.10` to the `loadBalancerIP` resource. If you used your own IP range for the AKS Vnet, provide your own internal IP address for use with the ingress controller. Make sure that this IP address is not already in use within your virtual network.

```yaml
controller:
  replicaCount: 2
  service:
    annotations:
      service.beta.kubernetes.io/azure-load-balancer-internal: "true"
    loadBalancerIP: 10.11.1.10
```

Now deploy the nginx-ingress chart with Helm. To use the manifest file created in the previous step, add the `-f internal-ingress.yaml` parameter. 

```bash
# Add the nginx-ingress Helm repository and install nginx ingress controller
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install nginx-ingress ingress-nginx/ingress-nginx --create-namespace --namespace nginx-ingress -f internal-ingress.yaml

# Check that nginx controller pods are up and running
kubectl -n nginx-ingress get po
NAME                                                      READY   STATUS    RESTARTS   AGE
nginx-ingress-ingress-nginx-controller-7c84dff847-44jnc   1/1     Running   0          15m
nginx-ingress-ingress-nginx-controller-7c84dff847-c4bxg   1/1     Running   0          15m

# Check that nginx controller service is up and running and that EXTERNAL-IP is assigned to IP we provided at the internal-ingress.yaml file. That is - 10.11.1.10. Note that it might take some minutes, since AKS will create Azure Internal Load Balancer at the management resource group.
kubectl -n nginx-ingress get svc
NAME                                               TYPE           CLUSTER-IP    EXTERNAL-IP   PORT(S)                      AGE
nginx-ingress-ingress-nginx-controller             LoadBalancer   10.0.60.139   10.11.1.10    80:30147/TCP,443:32355/TCP   16m
nginx-ingress-ingress-nginx-controller-admission   ClusterIP      10.0.146.49   <none>        443/TCP                      16m
```

## Useful links

* [Apply security and kernel updates to Linux nodes in Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/node-updates-kured?WT.mc_id=AZ-MVP-5003837)
* [Create an ingress controller to an internal virtual network in Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/ingress-internal-ip?WT.mc_id=AZ-MVP-5003837)
* [k8s: ingress controller](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/)


## Next: install Flux CLI to your PC and Flux onto your cluster

[Go to lab-03](../lab-03/readme.md)

## Feedback

* Visit the [Github Issue](https://github.com/evgenyb/aks-workshops/issues/xx) to comment on this lab. 