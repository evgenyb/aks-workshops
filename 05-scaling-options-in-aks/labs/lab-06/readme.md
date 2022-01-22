# lab-06 - manually scale the node count in an AKS cluster

You can manually scale nodes to test how your applications responds to a change in available resources and state. Manually scaling resources also lets you define a set amount of resources to use to maintain a fixed cost, such as the number of nodes. To manually scale, you define node count. The Kubernetes API then  draining nodes based on node count.

When scaling down nodes, the Kubernetes API calls the relevant Azure Compute API tied to the compute type used by your cluster. For example, for clusters built on VM Scale Sets the logic for selecting which nodes to remove is determined by the VM Scale Sets API. 

## Task #1 - scale up cluster to two nodes

You can adjust the number of nodes manually if you plan more or fewer container workloads on your cluster.

The following command increases the number of nodes to two. The command takes a couple of minutes to complete.

```bash
# scale up cluster to two nodes

```

## Useful links

* [Scaling options for applications in Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/concepts-scale?WT.mc_id=AZ-MVP-5003837)
* [Scale the node count in an Azure Kubernetes Service (AKS) cluster](https://docs.microsoft.com/en-us/azure/aks/scale-cluster?WT.mc_id=AZ-MVP-5003837)
* [Manually scale AKS nodes](https://docs.microsoft.com/en-us/azure/aks/tutorial-kubernetes-scale??WT.mc_id=AZ-MVP-5003837&abs=azure-cli#manually-scale-aks-nodes)

## Next: use cluster autoscaler to automatically scale an AKS cluster to meet application demands

[Go to lab-07](../lab-07/readme.md)