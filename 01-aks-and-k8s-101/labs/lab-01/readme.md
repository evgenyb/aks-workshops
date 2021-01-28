# lab-01 - AKS setup

## Estimated completion time - 15 min

To start learning and experimenting with Kubernetes concepts, commands and operations, we need to provision Azure Kubernetes Service (AKS). There are multiple ways you can provision AKS and there will be dedicated workshop covering this topic in details. But for this workshop we will use the simplest possible option - `az cli`. AKS as a resource is not free and the compute power will come with some costs. We will use the smallest Virtual Machine size for our nodes and we will use only one node. We will also delete AKS cluster when we are finished with workshop. Here is the list of resources we need to provision:

* Resource Group
* Azure Container Registry (ACR)
* Azure Kubernetes Service (AKS)


## Goals

* Provision resource group for all resources needed during the workshop
* Provision Azure Container Registry (ACR)
* Provision Azure Kubernetes Service (AKS) and integrate it with ACR
* Install `kubectl` command 
* Connect to AKS cluster
* Use `kubectl` and get list of nodes and namespaces

## Task #1 - create AKS resources

First, you need to create resource group. I suggest we all use the same resource group name - `iac-aks-ws1-rg` so it will be easier to troubleshoot thing later if needed. 

```bash
az group create -g iac-aks-ws1-rg -l westeurope
```

Next, create Azure Container Registry. ACR name should be globally unique, therefore I suggest that we use the following naming convention: `iacaksws1<YOU-NAME>`, so for example for me it will be  `iacaksws1evg`.

```bash
az acr create -g iac-aks-ws1-rg -n iacaksws1<YOU-NAME> --sku Basic
```
Finally, provision AKS. Let's use the same cluster name - `aks-ws1`

```bash
az aks create -g iac-aks-ws1-rg -n aks-ws1 -c 1 --generate-ssh-keys --attach-acr iacaksws1<YOU-NAME> 
```

## Task #2 - install kubectl

To manage a Kubernetes cluster, you use `kubectl`, the Kubernetes command-line client. To install kubectl locally, use the [az aks install-cli](https://docs.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest&WT.mc_id=AZ-MVP-5003837#az_aks_install_cli) command. You may need to use `sudo` if you are running on WSL

```bash
az aks install-cli
```

For a complete list of kubectl operations, see [Overview of kubectl](https://kubernetes.io/docs/reference/kubectl/overview/).

To configure `kubectl` to connect to your Kubernetes cluster, use the [az aks get-credentials](https://docs.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest&WT.mc_id=AZ-MVP-5003837#az_aks_get_credentials) command. This command downloads credentials and configures the Kubernetes CLI to use them.

```bash
az aks get-credentials -g iac-aks-ws1-rg -n aks-ws1
```

## Task 3 - verify the connection to your cluster

To verify the connection to your cluster, let's use the kubectl get command to return a list of the cluster nodes and namespaces.

```bash
kubectl get nodes

kubectl get ns

```

## Useful links

* [Azure Container Registry documentation](https://docs.microsoft.com/en-us/azure/container-registry/?WT.mc_id=AZ-MVP-5003837)
* [Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/?WT.mc_id=AZ-MVP-5003837)
* [Quickstart: Deploy an Azure Kubernetes Service cluster using the Azure CLI](https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough?WT.mc_id=AZ-MVP-5003837)
* [Tutorial: Deploy and use Azure Container Registry](https://docs.microsoft.com/en-us/azure/aks/tutorial-kubernetes-prepare-acr?WT.mc_id=AZ-MVP-5003837)
* [Authenticate with Azure Container Registry from Azure Kubernetes Service](https://docs.microsoft.com/en-us/azure/aks/cluster-container-registry-integration?WT.mc_id=AZ-MVP-5003837)
* [az aks install-cli](https://docs.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest?WT.mc_id=AZ-MVP-5003837#az_aks_install_cli)
* [Overview of kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)

## Next: name of next lab

[Go to lab-02](../lab-02/readme.md)

