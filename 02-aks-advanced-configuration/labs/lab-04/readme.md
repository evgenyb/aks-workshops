# lab-04 - working with AKS node pools

## Estimated completion time - 30 min

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

and use left-hand session to run all commands from the labs. 

## Task #1 - get information about node pools

```bash
# Get list of node pools
az aks nodepool list  -g iac-ws2-blue-rg --cluster-name iac-ws2-blue-aks

# Get name, mode, VM size and number of nodes
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
Create `lab4-task1.yaml` file with the following deployment manifest

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: lab4-task1
  labels:
    app: lab4-task1
spec:
  replicas: 2
  selector:
    matchLabels:
      app: lab4-task1
  template:
    metadata:
      labels:
        app: lab4-task1
    spec:
      containers:
      - name: api
        image: iacws2evgacr.azurecr.io/apia:v1
        imagePullPolicy: IfNotPresent
        resources: {}
```

and deploy it

```bash
# Deploy api-a
kubectl apply -f ./lab4-task1.yaml
```

After a while, in your right-hand watching session, you should see that both pods are in `Running` state

```bash
lab4-task1-5cc5fc68c6-q4bqf   1/1     Running             0          1s
lab4-task1-5cc5fc68c6-pb28k   1/1     Running             0          2s
```

Let's delete our application for now.

```bash
# Delete api-a application
kubectl delete -f ./lab4-task1.yaml
```

## Task #2 - configure system pool nodes taint

As we already know, for a system node pool, AKS automatically assigns the label `kubernetes.azure.com/mode: system` to its nodes. 
It's a good practice to isolate critical system pods from "regular" application pods to prevent misconfigured. 
Kubernetes [taints concept](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) allows a node to repel a set of pods. You can enforce this by using the `CriticalAddonsOnly=true:NoSchedule` taint to prevent application pods from being scheduled on system node pools. 

First, let's check `Taints` configuration of our system node(s).

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

Now, let's update the taints on system nodes by using [kubectl taint](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#taint) command.

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
# Deploy api-a application
kubectl apply -f ./lab4-task1.yaml
```

In your right-hand watching session, you should see that both pods are in `Pending` state. 

```bash
lab4-task1-5cc5fc68c6-sxrrw   0/1     Pending             0          0s
lab4-task1-5cc5fc68c6-6k4x2   0/1     Pending             0          0s
```

Let's find out why.

```bash
# Get pod description
kubectl describe po lab4-task1-5cc5fc68c6-sxrrw
```

Under the `Events:` section, you should see the similar message

```yaml
Events:
  Type     Reason            Age                 From               Message
  ----     ------            ----                ----               -------
  Warning  FailedScheduling  32s (x4 over 109s)  default-scheduler  0/1 nodes are available: 1 node(s) had taint {CriticalAddonsOnly: true}, that the pod didn't tolerate.
```

This message tells that there is no nodes available to get our pods scheduled. To solve this problem we can either configure pod `Tolerations` or add more nodes without `Taints`. Let's try both approaches, but first, delete our broken deployment.

```bash
# Delete api-a deployment
kubectl delete -f ./lab4-task1.yaml
```

## Task #3 - configure pod tolerations

Create new `lab4-task2.yaml` file with the following content. 

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: lab4-task3
  labels:
    app: lab4-task3
spec:
  replicas: 2
  selector:
    matchLabels:
      app: lab4-task3
  template:
    metadata:
      labels:
        app: lab4-task3
    spec:
      containers:
      - name: api
        image: iacws2evgacr.azurecr.io/apia:v1
        imagePullPolicy: IfNotPresent
        resources: {}
      tolerations:
      - key: "CriticalAddonsOnly"
        operator: "Equal"
        value: "true"
        effect: "NoSchedule"
```

Note the `tolerations` configuration for a pod in the pod `spec` section. The above example uses `effect` of `NoSchedule`. Alternatively, you can use effect of `PreferNoSchedule`. This is a "preference" or "soft" version of `NoSchedule` - the system will try to avoid placing a pod that does not tolerate the taint on the node, but it is not required. 

Now, let's try to deploy our `api-a` application using `lab4-task3.yaml`.

```bash
# Deploy api-a application
kubectl apply -f ./lab4-task3.yaml
```

This time, your right-hand watching session should show that both pods are in `Running` state. 

```bash
lab4-task3-65fcdf5b79-vxjtn   1/1     Running             0          2s
lab4-task3-65fcdf5b79-fvhzc   1/1     Running             0          2s
```

Delete `api-a` application. 

```bash
# Delete api-a application
kubectl delete -f ./lab4-task3.yaml
```

## Task #4 - add new user node pool

Let's keep taint configuration for the system nodes the same, that is - `CriticalAddonsOnly=true:NoSchedule` and deploy `api-a` application without toleration configured using `lab4-task1.yaml`

```bash
# Deploy api-a without toleration
kubectl apply -f ./lab4-task1.yaml
```

As expected, `api-a` pods will have `Pending` status

```bash
lab4-task1-5cc5fc68c6-rkpzm   0/1     Pending             0          0s
lab4-task1-5cc5fc68c6-mw8mk   0/1     Pending             0          0s
```

Now, let's create new AKS user node pool called `workload`.

```bash
# Add new user node pool
az aks nodepool add -g iac-ws2-blue-rg --cluster-name iac-ws2-blue-aks \
    --name workload \
    --mode User     \
    --node-count 1 \
    --node-vm-size Standard_DS2_v2 \
    --kubernetes-version 1.19.6
``` 

It may take some minutes to create new pool. While you are waiting, keep the watching session with `kubectl get po -w` command running and observe the output. Eventually you should see that both pods are running.

```bash
lab4-task1-5cc5fc68c6-mw8mk   1/1     Running             0          3m26s
lab4-task1-5cc5fc68c6-rkpzm   1/1     Running             0          3m26s
```

When pool is successfully created, get the list of the node pools

```bash
# Get list of node pools
az aks nodepool list  -g iac-ws2-blue-rg --cluster-name iac-ws2-blue-aks --query "[].{name:name, mode:mode, vm_size:vmSize, number_of_nodes:count}"
```

You should see two node pools. One `System` pool and one `User`.

```bash
# Get list of nodes
kubectl get nodes
NAME                                 STATUS   ROLES   AGE     VERSION
aks-systempool-27376456-vmss000000   Ready    agent   3d12h   v1.19.7
aks-workload-27376456-vmss000000     Ready    agent   12m     v1.19.6

# Get list of nodes and show labels. Note that agentpool label contains the name of the pool.
kubectl get nodes --show-labels

# Get all nodes from the workload pool
kubectl get nodes -l agentpool=workload

# Get all nodes from the system pool
kubectl get nodes -l agentpool=systempool

# Check that api-a pods are scheduled to the node from workload pool
kubectl get po -o wide
lab4-task1-5cc5fc68c6-mw8mk   1/1     Running   0          4m42s   10.11.0.120   aks-workload-27376456-vmss000000   <none>           <none>
lab4-task1-5cc5fc68c6-rkpzm   1/1     Running   0          4m42s   10.11.0.119   aks-workload-27376456-vmss000000   <none>           <none>
```

## Task #5 - schedule a pod to run on a system node

Create new `lab4-task5.yaml` file with the following deployment.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: lab4-task5
  labels:
    app: lab4-task5
spec:
  replicas: 2
  selector:
    matchLabels:
      app: lab4-task5
  template:
    metadata:
      labels:
        app: lab4-task5
    spec:
      containers:
      - name: api
        image: iacws2evgacr.azurecr.io/apia:v1
        imagePullPolicy: IfNotPresent
        resources: {}
      nodeSelector:
        kubernetes.azure.com/mode: system
```

If you want your pods to be scheduled to the system nodes, you need to add a `nodeSelector` filed to your pod `spec` that specifies a map of key-value pairs. 
For the pod to be eligible to run on a node, the node must have each of the indicated key-value pairs as labels. 

In our example above, pod will only be deployed to nodes with `kubernetes.azure.com/mode: system` label, that is - to the nodes from the system node pool.

```bash
# Deploy api-a application
kubectl apply -f ./lab4-task5.yaml
```

As you can see at the watch terminal session, both pods are in `Pending` state

```bash
lab4-task5-67dbccb6b8-xnk66    0/1     Pending             0          0s
lab4-task5-67dbccb6b8-lsv7d    0/1     Pending             0          0s
```

Let's check pod description

```bash
kubectl describe pod lab4-task5-67dbccb6b8-lsv7d

Warning  FailedScheduling  77s (x2 over 77s)  default-scheduler  0/2 nodes are available: 1 node(s) didn't match node selector, 1 node(s) had taint {CriticalAddonsOnly: true}, that the pod didn't tolerate
```

Kubernetes can't schedule pod to the system nodes, because pod doesn't tolerate node tain. To fix this, we need to configure  `tolerations` for our pods.

Change `lab4-task5.yaml` file to the following content.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: lab4-task5
  labels:
    app: lab4-task5
spec:
  replicas: 2
  selector:
    matchLabels:
      app: lab4-task5
  template:
    metadata:
      labels:
        app: lab4-task5
    spec:
      containers:
      - name: api
        image: iacws2evgacr.azurecr.io/apia:v1
        imagePullPolicy: IfNotPresent
        resources: {}
      nodeSelector:
        kubernetes.azure.com/mode: system
      tolerations:
      - key: "CriticalAddonsOnly"
        operator: "Equal"
        value: "true"
        effect: "NoSchedule"
```

and re-deploy it 

```bash
# Deploy api-a application
kubectl apply -f ./lab4-task5.yaml
```

This time, both pods are in `Running` state

```bash
lab4-task5-5dbdbb46c7-2x6sq   1/1     Running   0          6s
lab4-task5-5dbdbb46c7-cm6f2   1/1     Running   0          5s
```

Check that `lab4-task5` pods are scheduled to system nodes

```bash
# Check that api-a pods are scheduled to the system nodes
kubectl get po -o wide
lab4-task5-5dbdbb46c7-2x6sq   1/1     Running   0          76s   10.11.0.17    aks-systempool-27376456-vmss000000   <none>           <none>
lab4-task5-5dbdbb46c7-cm6f2   1/1     Running   0          75s   10.11.0.75    aks-systempool-27376456-vmss000000   <none>           <none>
```

## Task #6 - add a spot node pool 

A spot node pool is a node pool backed by a [spot virtual machine scale set](https://docs.microsoft.com/en-us/azure/virtual-machine-scale-sets/use-spot). Using spot VMs for nodes with your AKS cluster allows you to take advantage of unutilized capacity in Azure at a significant cost savings. 

```bash
# Add a spot node pool
az aks nodepool add -g iac-ws2-blue-rg --cluster-name iac-ws2-blue-aks \
    --name spotnodes \
    --priority Spot \
    --eviction-policy Delete \
    --spot-max-price -1 \
    --enable-cluster-autoscaler \
    --min-count 1 \
    --max-count 3 

# Get nodes (you may have different names)
kubectl get nodes --show-labels
aks-spotnodes-27376456-vmss000000    Ready    agent   19m    v1.19.7
aks-systempool-27376456-vmss000000   Ready    agent   5d7h   v1.19.7

# Describe aks-spotnodes-27376456-vmss000000 node 
kubectl describe node aks-spotnodes-27376456-vmss000000
```
Note that node has `Taints` configured

```yaml
Taints:             kubernetes.azure.com/scalesetpriority=spot:NoSchedule
```

Since nodes have taint of `kubernetes.azure.com/scalesetpriority=spot:NoSchedule`, only pods with a corresponding toleration are scheduled on this node.

## Task #7 - schedule a pod to run on a spot node

To schedule a pod to run on a spot node, we need to add toleration that corresponds to the taint applied to spot node. 
Create new `lab4-task7.yaml` file with the following deployment manifest:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: lab4-task7
  labels:
    app: lab4-task7
spec:
  replicas: 2
  selector:
    matchLabels:
      app: lab4-task7
  template:
    metadata:
      labels:
        app: lab4-task7
    spec:
      containers:
      - name: api
        image: iacws2evgacr.azurecr.io/apia:v1
        imagePullPolicy: IfNotPresent
        resources: {}
      tolerations:
      - key: "kubernetes.azure.com/scalesetpriority"
        operator: "Equal"
        value: "spot"
        effect: "NoSchedule"
```

Note the `tolerations` section of the `PodSpec`.

Now, deploy it:

```bash
# Deploy api-a to the spot nodes
kubectl apply -f lab4-task7.yaml

# Check where pods were scheduled
kubectl get po -l app=lab4-task7 -owide 
lab4-task7-65d79fc55d-5kj6f   1/1     Running   0          4m8s    10.11.0.118   aks-spotnodes-27376456-vmss000000   <none>           <none>
lab4-task7-65d79fc55d-mh7gg   1/1     Running   0          3m57s   10.11.0.129   aks-spotnodes-27376456-vmss000000   <none>           <none>
```

As expected, both pods are running at `spotnodes` node.

## Task #8 - delete node pool

Let's keep the `spotnodes` node pool and delete the `workload` pool:

```bash
# Delete workload pool
az aks nodepool delete -n workload -g iac-ws2-blue-rg --cluster-name iac-ws2-blue-aks 
```

## Useful links
* [Create and manage multiple node pools for a cluster in Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/use-multiple-node-pools?WT.mc_id=AZ-MVP-5003837)
* [Manage system node pools in Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/use-system-pools?WT.mc_id=AZ-MVP-5003837)
* [Add a spot node pool to an Azure Kubernetes Service (AKS) cluster](https://docs.microsoft.com/en-us/azure/aks/spot-node-pool?WT.mc_id=AZ-MVP-5003837)
* [Azure Spot Virtual Machines for virtual machine scale sets](https://docs.microsoft.com/en-us/azure/virtual-machine-scale-sets/use-spot?WT.mc_id=AZ-MVP-5003837)
* [Assigning Pods to Nodes](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/)
* [Taints and Tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/)

## Next: add aad-pod-identity support into AKS 

[Go to lab-05](../lab-05/readme.md)

## Feedback

* Visit the [Github Issue](https://github.com/evgenyb/aks-workshops/issues/18) to comment on this lab. 