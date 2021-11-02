# Workshop #4 - GitOps in AKS with Flux

![logo](images/logo.png)

This is an introduction level workshop for those of you who have never worked with GitOps in Kubernetes. This workshop covers the basics of GitOps in Kubernetes with [Flux](https://fluxcd.io/) and you will learn:
 * How to install Flux to AKS cluster
 * How to configure Flux with your git repository
 * How to continuous deliver infrastructure and workloads changes defined with Kubernetes manifests and assembled with [Kustomize](https://kustomize.io/)
 * How to declaratively manage Helm chart releases with Kubernetes manifests 
 * Different ways how you can structure your repositories
 * How to upgrade flux 
 * How to monitor flux
 
Here is the preliminary agenda for the workshops (this is subject to change):
 
 * Welcome
 * GitOps at AKS with Flux (slides)
 * [Lab-01](labs/lab-01/readme.md) - provision AKS cluster and supporting resources (20 min)
 * [Lab-02](labs/lab-02/readme.md) - post provisioning cluster configuration: create namespaces and deploy [NGINX ingress controller](https://docs.microsoft.com/en-us/azure/aks/ingress-internal-ip?WT.mc_id=AZ-MVP-5003837) (xx min)
 * [Lab-03](labs/lab-03/readme.md) - install Flux CLI to your PC and bootstrap Flux onto your cluster (xx min)
 * [Lab-04](labs/lab-04/readme.md) - use Flux to deploy Kubernetes manifests (xx min)
 * [Lab-05](labs/lab-05/readme.md) - manage Helm Releases with Flux  (xx min)
 * [Lab-06](labs/lab-06/readme.md) - kustomize 101
 * Lab-07 - monorepo as Flux repository structure
 * Lab-08 - setup notifications (xx min)
 * [Lab-09](labs/lab-09/readme.md) - cleaning up

## Links

* [Prerequisites](prerequisites.md)
* [Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/?WT.mc_id=AZ-MVP-5003837)
* [GitOps for Azure Kubernetes Service](https://docs.microsoft.com/en-us/azure/architecture/example-scenario/gitops-aks/gitops-blueprint-aks?WT.mc_id=AZ-MVP-5003837)
* [Flux - the GitOps family of projects](https://fluxcd.io/)

## Feedback

* Visit the [Github Issue](https://github.com/evgenyb/aks-workshops/issues/35) to comment on this workshop. 
