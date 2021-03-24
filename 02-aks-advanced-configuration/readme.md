# Workshop #2 - Advanced AKS Configuration

![logo](images/logo.png)

Welcome to the second workshop in the series of AKS related workshops! 
This time, we will focus on advanced configuration aspects of AKS cluster and you will learn:

* how to deploy AKS into your Private Virtual Network 
* how to configure multiple node pools for system and user workloads
* how to deploy aad-pod-identity and how to enable pod identity for your applications
* how to deploy and configure nginx ingress controller and how to configure ingress for your services
* how to configure egress traffic
* how to expose your AKS publicly with Azure API Management 
* how to upgrade your AKS cluster

Workshop is organized as a combination of theoretical blocks and labs and here is the preliminary agenda for this workshops (still work in progress):
 
 * Slides - Workshop introduction
 * Slides - Networking (VNet, NSG, peering, AKS capacity planning, Public IP Prefix)
 * Lab-01 - configure Private Virtual Networks
 * Lab-02 - provision APIM (50++ min) -> fire and forget
 * Slides - AKS configuration (Network, egress, RBAC, Managed Identity, Network Policy, Node Pools, )  
 * Lab-03 - provision AKS and all prerequisites
 * Slides - guinea pig apps walk through
 * Lab-04 - build and push docker images
 * Lab-05 - deploy applications and services to AKS
 * Slides - AKS node pools
 * Lab-06 - add new node pool for our workload
 * Slides - AAD Pod Identity
 * Lab-07 - add aad-pod-identity support into AKS 
 * Slides - Kubernetes Ingress Controller
 * Lab-08 - deploy nginx ingress controller
 * Slides - API Management 101 
 * Lab-09 - deploy api-b API to API Management
 * Lab-10 - AKS egress 
 * Slides - AKS upgrade options
 * Lab-11 - upgrade AKS - mutable approach
 * Lab-12 - upgrade AKS - immutable approach
 * Lab-13 - cleaning up resources

## Links

* [Prerequisites](prerequisites.md)

## Feedback

* Visit the [Github Issue](https://github.com/evgenyb/aks-workshops/issues/14) to comment on this workshop. 