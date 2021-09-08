# aks-workshops

I decided to dedicate 2021 to Azure Kubernetes Services (AKS) and here is the preliminary set of workshops with draft content (both dates and content are subject to change) that I am planning to work on:

## [Workshop #1 - AKS and Kubernetes 101](01-aks-and-k8s-101/readme.md)

This is introduction level (101) workshop for those of you who have never worked with neither AKS nor Kubernetes. I expect that you have some basic understanding of containerization concept and know what docker and docker images are. This workshop covers the basics of using Kubernetes and you will learn how to:
 * Provision basic AKS cluster and integrate it with Azure Container Registry (ACR)
 * Take a simple dotnet api application and build it into a docker container
 * Use `kubectl` to deploy, configure, monitor, update and delete your apps 

 The workshops consists of 11 labs and estimated time is 3 hours.
 
## [Workshop #2 - Advanced AKS configuration](02-aks-advanced-configuration/readme.md)

The focus for this workshop is advanced configuration aspects of AKS cluster and you will learn:

* how to deploy AKS into your Private Virtual Network 
* how to configure multiple node pools for system and user workloads
* how to deploy aad-pod-identity and how to enable pod identity for your applications
* how to deploy and configure nginx ingress controller and how to configure ingress for your services
* how to configure egress traffic
* how to expose your AKS publicly with Azure API Management 
* how to upgrade your AKS cluster

Workshop is organized as a combination of theoretical blocks and 10 labs.

## [Workshop #3 - Implement Immutable AKS Infrastructure on Azure with Bicep](03-immutable-aks-infrastructure-with-bicep/readme.md)

This time we will work with Azure Bicep - a Domain Specific Language (DSL) for deploying Azure resources declaratively.
Since this year is all about AKS, we will use Bicep to implement immutable AKS infrastructure on Azure.

Workshop goals:
* get a hands-on experience working with Bicep
* design and implement a simple immutable AKS infrastructure using Bicep

Workshop is organized as a combination of theoretical blocks and 9 labs.

## [Workshop #4 - GitOps in AKS with Flux](04-gitops-in-aks-with-flux/readme.md)

This workshop covers the basics of GitOps in Kubernetes with [Flux](https://fluxcd.io/) and you will learn:
 * How to install Flux to AKS cluster
 * How to configure Flux with your git repositories
 * How to continuous deliver infrastructure and workloads changes defined with Kubernetes manifests and assembled with [Kustomize](https://kustomize.io/)
 * How to declaratively manage Helm chart releases with Kubernetes manifests 
 * Different ways how you can structure your repositories
 * How to upgrade flux 
 * How to monitor flux

## Workshop #5 - Service mesh with linkerd
## Workshop #6 - security



