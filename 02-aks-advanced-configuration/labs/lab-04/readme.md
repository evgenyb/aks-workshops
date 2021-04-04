# lab-04 - working with AKS node pools

## Estimated completion time - xx min

In AKS, nodes of the same configuration are grouped together into node pools. By default, when you provision new AKS cluster, there is only one system pool available. 
To support applications that have different compute or storage demands, AKS allows you to create multiple user node pools. 

* System node pools serve the primary purpose of hosting critical system pods such as CoreDNS and tunnelfront. 
* User node pools serve the primary purpose of hosting your application pods. 

If you wish to only have one pool in your AKS cluster, application pods can be scheduled on system node pool.

## Goals

* To learn how to assigning Pods to Nodes
* To understand concept of Taints and Tolerations
* To understand the concept of AKS node pools
* To learn how to create new User node pool
* To learn how to create spot node pool

For the most of the labs, I recommend you to use Windows Terminal, because it allows to split Terminal windows and run multiple sessions side-by-side. For example, you can use lef-hand window to run all labs commands, and use right-hand window to run watcher commands like `kubectl get po -w`. This way you will get a realtime insights about what kubernetes does behind the scene. To split current window, enter `Shift+Alt+D` and it will split your current window either vertically or horizontally. 

In the right-hand session, run the "watcher" command

```bash
# Watch what happens with pods
kubectl get pods -w
```

Use left-hand session to run all commands from the labs. 

## Task #1 - get information about default node pool

```bash
# Get list of node pools
az aks nodepool list  -g iac-ws2-blue-rg --cluster-name iac-ws2-blue-aks

# Get name, mode, VM size and number of nodes in the pool

az aks nodepool list  -g iac-ws2-blue-rg --cluster-name iac-ws2-blue-aks --query "[].{name:name, mode:mode, vm_size:vmSize, number_of_nodes:count}"
```

As you can see, the default pool is type of `system`. For a system node pool, AKS automatically assigns the label `kubernetes.azure.com/mode: system` to its nodes. This causes AKS to prefer scheduling system pods on node pools that contain this label. This label does not prevent you from scheduling application pods on system node pools. 

```bash
# Show labels associated with nodes
kubectl get nodes --show-labels

# Get list of system nodes 
kubectl get nodes -l kubernetes.azure.com/mode=system
```

Since there is only one node pool, it allows to deploy user pods into it. To confirm this, let's deploy our `api-a` application.

```bash
# Go to 02-aks-advanced-configuration\k8s\api-a folder
cd 02-aks-advanced-configuration\k8s\api-a

# Deploy api-a application
kubectl apply -f ./deployment.yaml
configmap/api-a-appsettings created
deployment.apps/api-a created
service/api-a-service created
```

After a while, in your right-hand watching session, you should see that both pods are in `Running` state

```bash
...
api-a-8668f99d4d-bfbk8          1/1     Running             0          3s
api-a-8668f99d4d-8lc7l          1/1     Running             0          4s
...
```

Let's delete our application for now.

```bash
# Delete api-a application
kubectl delete -f ./deployment.yaml
```

## Task #2 - configure taint to system pool nodes

As we already know, for a system node pool, AKS automatically assigns the label `kubernetes.azure.com/mode: system` to its nodes. 
It's a good practice to isolate critical system pods from "regular" application pods to prevent misconfigured. 
Kubernetes [taints concept](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) allows a node to repel a set of pods. You can enforce this by using the `CriticalAddonsOnly=true:NoSchedule` taint to prevent application pods from being scheduled on system node pools. 

First, lets' check Taints configuration of our system node(s).

```bash
# Get list of system nodes 
kubectl get nodes -l kubernetes.azure.com/mode=system
aks-systempool-27376456-vmss000000     Ready    agent   37m   v1.19.7

# Get node description and check node taints configuration
kubectl describe node aks-systempool-27376456-vmss000000
```

There should be no `Taints` configured

```yaml
...
Taints:             <none>
...
```

Now, let's update the taints on one or more system nodes by using [kubectl taint](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#taint) command.

```bash
# Set CriticalAddonsOnly=true:NoSchedule taint to nodes from system pool
kubectl taint node -l kubernetes.azure.com/mode=system CriticalAddonsOnly=true:NoSchedule

# Check node taints 
kubectl describe node aks-systempool-27376456-vmss000000
```

You should see `Taints:             CriticalAddonsOnly=true:NoSchedule` as part of the node description.

This taint has key `CriticalAddonsOnly`, value `true`, and taint effect `NoSchedule`. This means that no pod will be able to schedule onto nodes labeled with `kubernetes.azure.com/mode=system` unless it has a matching toleration.

Now, let's try to deploy our `api-a` application again.

```bash
# Go to 02-aks-advanced-configuration\k8s\api-a folder
cd 02-aks-advanced-configuration\k8s\api-a

# Deploy api-a application
kubectl apply -f ./deployment.yaml
configmap/api-a-appsettings created
deployment.apps/api-a created
service/api-a-service created
```

In your right-hand watching session, you should see that both pods are in `Pending` state. 

```bash
...
api-a-8668f99d4d-5jpcz   0/1     Pending   0          0s
api-a-8668f99d4d-49pn8   0/1     Pending   0          0s
...
```

Let's find out why.

```bash
# Get pod description
kubectl describe po api-a-8668f99d4d-49pn8
```

Under the `Events:` section, you should see the similar message

```yaml
Events:
  Type     Reason            Age                 From               Message
  ----     ------            ----                ----               -------
  Warning  FailedScheduling  32s (x4 over 109s)  default-scheduler  0/1 nodes are available: 1 node(s) had taint {CriticalAddonsOnly: true}, that the pod didn't tolerate.
```

This message tells that there is no nodes available to get our pods scheduled. To solve this problem we can either configure pod Tolerations or to add more nodes without Taints. Let's try both approaches, but first, delete our broken deployment.

```bash
# Delete api-a deployment
kubectl delete -f ./deployment.yaml
configmap "api-a-appsettings" deleted
deployment.apps "api-a" deleted
service "api-a-service" deleted
```

## Task #3 - configure pod Tolerations

Create new file `deployment-system.yaml` and copy/paste the content from the `02-aks-advanced-configuration\k8s\api-a\deployment.yaml` deployment manifest. 
Add the following Toleration for a pod in the pod `spec` section. Both of the following tolerations "match" the taint created in our previous task, and thus a pod with either toleration would be able to schedule: 

```yaml
...
    spec:
      tolerations:
      - key: "CriticalAddonsOnly"
        operator: "Equal"
        value: "true"
        effect: "NoSchedule"
      containers:
      - name: api
...
```

or

```yaml
...
    spec:
      tolerations:
      - key: "CriticalAddonsOnly"
        operator: "Exists"
        effect: "NoSchedule"
      containers:
      - name: api
...
```

The above example used `effect` of `NoSchedule`. Alternatively, you can use effect of `PreferNoSchedule`. This is a "preference" or "soft" version of `NoSchedule` -- the system will try to avoid placing a pod that does not tolerate the taint on the node, but it is not required. 

Now, let's try to deploy our `api-a` application using `deployment-system.yaml`.

```bash
# Deploy api-a application
kubectl apply -f ./deployment-system.yaml
configmap/api-a-appsettings created
deployment.apps/api-a created
service/api-a-service created
```

This time, your right-hand watching session should show that both pods are in `Running` state. 

```bash
...
api-a-7dc498bc57-6xwzl   1/1     Running             0          6s
api-a-7dc498bc57-79zjs   1/1     Running             0          6s
...
```

## Task #2 - Create new user pool with different Kubernetes version and VM size

```bash
# Add new node pool
az aks nodepool add -g iac-ws2-blue-rg --cluster-name iac-ws2-blue-aks \
    --name workload2 \
    --node-count 1 \
    --max-pods 110 \
    --node-vm-size Standard_DS2_v2 \
    --kubernetes-version 1.19.6 \
    --mode User
``` 

## Task #3 - add a spot node pool to an AKS cluster

```bash
# Add a spot node pool
az aks nodepool add -g iac-ws2-blue-rg --cluster-name iac-ws2-blue-aks \
    --name spotnodepool \
    --priority Spot \
    --eviction-policy Delete \
    --spot-max-price -1 \
    --enable-cluster-autoscaler \
    --min-count 1 \
    --max-count 3 
```

## Task #4 - schedule a pod to run on a spot node

To schedule a pod to run on a spot node, add a toleration that corresponds to the taint applied to your spot node. The following example shows a portion of a yaml file that defines a toleration that corresponds to a `kubernetes.azure.com/scalesetpriority=spot:NoSchedule` taint used in the previous step.



## Task - untain 

```bash
# Untain system nodes
kubectl taint node -l kubernetes.azure.com/mode=system CriticalAddonsOnly=true:NoSchedule-
```

```bash
# Add new node pool
az aks nodepool add -g iac-ws2-blue-rg --cluster-name iac-ws2-blue-aks \
    --name workloadpool \
    --node-count 1 \
    --mode User

# Get list of node pools
az aks nodepool list  -g iac-ws2-blue-rg --cluster-name iac-ws2-blue-aks

# Get nodes
kubectl get nodes
NAME                                   STATUS   ROLES   AGE     VERSION
aks-systempool-27376456-vmss000000     Ready    agent   48m     v1.19.6
aks-workloadpool-27376456-vmss000000   Ready    agent   5m25s   v1.19.6
```

As you can see the name of the node is prefixed with the name of the pool. 

```bash
# Get nodes and show labels
kubectl get nodes --show-labels
```

The `agentpool` label contains the name of the pool to which node is assigned to.

## Task - delete pool

```bash
# Delete workload pool
az aks nodepool delete -n workload2 -g iac-ws2-blue-rg --cluster-name iac-ws2-blue-aks 
```

## Useful links
[Create and manage multiple node pools for a cluster in Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/use-multiple-node-pools?WT.mc_id=AZ-MVP-5003837)
[Manage system node pools in Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/use-system-pools?WT.mc_id=AZ-MVP-5003837)
[Add a spot node pool to an Azure Kubernetes Service (AKS) cluster](https://docs.microsoft.com/en-us/azure/aks/spot-node-pool?WT.mc_id=AZ-MVP-5003837)
[Assigning Pods to Nodes](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/)
[Taints and Tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/)

## Next: 

[Go to lab-05](../lab-05/readme.md)

## Feedback

* Visit the [Github Issue](https://github.com/evgenyb/aks-workshops/issues/18) to comment on this lab. 