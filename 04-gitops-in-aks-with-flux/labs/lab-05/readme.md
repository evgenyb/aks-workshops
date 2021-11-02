# lab-05 - manage Helm Releases with Flux

## Estimated completion time - xx min

The Helm Controller is a Kubernetes operator, allowing one to declaratively manage Helm chart releases with Kubernetes manifests.

![helm-controller](https://fluxcd.io/img/helm-controller.png) 

## Goals

The goal for this lab is to learn how to create and configure Flux `HelmRepository` and `HelmRelease` resources.

* Create `HelmRepository` using `flux cli`
* Generate `HelmRepository` manifest using `flux cli`
* Create `HelmRelease` using `flux cli`
* Generate `HelmRelease` manifest using `flux cli`

## Task #1 - connect to the `green` cluster

Since we already deployed NGINX ingress controller during `lab #2`, let's switch to the clean `green` cluster.

```bash
# Connect to your clue cluster
az aks get-credentials --resource-group iac-ws4-green-rg --name iac-ws4-green-aks --overwrite-existing

# Get list of namespaces and authenticate with Azure AD
kubectl get ns

# You will be prompted to enter devicelogin code.
To sign in, use a web browser to open the page https://microsoft.com/devicelogin and enter the code <...> to authenticate.

NAME              STATUS   AGE
default           Active   14m
kube-node-lease   Active   14m
kube-public       Active   14m
kube-system       Active   14m
```

## Task #2 - create new github repository, bootstrap Flux and create new `nginx-ingress` namespace

```bash
# Create new iac-ws4-lab05 repository. Make sure that you run this command outside of github repository, otherwise you will get the following error message  'error: remote origin already exists.' and you will need to clone iac-ws4-lab05 to some other folder.
gh repo create iac-ws4-lab05 --private -g VisualStudio -y

# Export your GitHub access token and username
$Env:GITHUB_TOKEN='ghp_....'
$Env:GITHUB_USER='<your-github-username>'

# Check you have everything needed to run Flux by running 
flux check --pre

# Bootstrap the iac-ws4-blue-aks cluster
flux bootstrap github --owner=$Env:GITHUB_USER --repository=iac-ws4-lab05 --branch=main --personal --path=clusters/iac-ws4-green-aks

# Create new nginx-ingress namespace
kubectl create ns nginx-ingress
namespace/nginx-ingress created
```

## Task #3 - create new Helm repository using `flux cli`

The helm-controller makes use of the artifacts produced by the source-controller from `HelmRepository`, `GitRepository` and `HelmChart` resources. In this lab we will use `HelmRepository` only. 

Lets create new `HelmRepository` for NGINX ingress controller.  This time we will create flux resources under `nginx-ingress` namespace using `-n nginx-ingress` or `--namespace nginx-ingress` flag.

```bash
# Create a source for a nginx ingress controller Helm repository
flux -n nginx-ingress create source helm ingress-nginx --url=https://kubernetes.github.io/ingress-nginx --interval=1m 

# Get list of HelmRepository objects
flux -n nginx-ingress get source helm
NAME            READY   MESSAGE                                                         REVISION                                        SUSPENDED
ingress-nginx   True    Fetched revision: 86bb1f86fbf911042a7118f2c87ab4df06f03ce6      86bb1f86fbf911042a7118f2c87ab4df06f03ce6        False
```

The `interval` defines at which interval the Helm repository index is fetched, and should be at least `1m`. Setting this to a higher value means newer chart versions will be detected at a slower pace. 
The `url` can be any HTTP/S Helm repository URL.

## Task #4 - generate Helm repository manifest using `flux cli`

As with `GitRepository`, sometimes you don't want to create `HelmRepository` resource, but want to generate manifest file to store it under the source control.
You can do it by using additional `--export` flag

```bash
# Generate nginx ingress controller Helm repository manifest
flux -n nginx-ingress create source helm ingress-nginx-1 --url=https://kubernetes.github.io/ingress-nginx --interval=1m --export > ingress-nginx-1-source.yaml

# Check manifest file
cat ./ingress-nginx-1-source.yaml
---
apiVersion: source.toolkit.fluxcd.io/v1beta1
kind: HelmRepository
metadata:
  name: ingress-nginx-1
  namespace: nginx-ingress
spec:
  interval: 1m0s
  url: https://kubernetes.github.io/ingress-nginx

# Deploy manifest file
kubectl apply -f ./ingress-nginx-1-source.yaml
helmrepository.source.toolkit.fluxcd.io/ingress-nginx-1 created

# Get list of HelmRepository objects
flux -n nginx-ingress get source helm
NAME            READY   MESSAGE                                                         REVISION                                        SUSPENDED
ingress-nginx   True    Fetched revision: 86bb1f86fbf911042a7118f2c87ab4df06f03ce6      86bb1f86fbf911042a7118f2c87ab4df06f03ce6        False
ingress-nginx-1 True    Fetched revision: 86bb1f86fbf911042a7118f2c87ab4df06f03ce6      86bb1f86fbf911042a7118f2c87ab4df06f03ce6        False
```

## Task #5 - create Helm Release using `flux cli`

Same as we did at the `lab #2`, we need some additional configuration parameters for nginx ingress helm chart. Create a file named `internal-ingress.yaml` using the following example manifest file. This example assign `10.11.1.10` to the `loadBalancerIP` resource. If you used your own IP range for the AKS Vnet, provide your own internal IP address for use with the ingress controller. Make sure that this IP address is not already in use within your virtual network.

```yaml
controller:
  replicaCount: 2
  service:
    annotations:
      service.beta.kubernetes.io/azure-load-balancer-internal: "true"
    loadBalancerIP: 10.12.1.10
```

With the chart source created, create a new `HelmRelease` using `flux create helmrelease` command. Remember to create resources under `nginx-ingress` namespace.

```bash
# Create a nginx-ingress HelmRelease with a chart from a nginx-ingress HelmRepository source
flux -n nginx-ingress create helmrelease nginx-ingress --source=HelmRepository/ingress-nginx --chart=ingress-nginx --values=./internal-ingress.yaml
✚ generating HelmRelease
► applying HelmRelease
✔ HelmRelease created
◎ waiting for HelmRelease reconciliation
✔ HelmRelease nginx-ingress is ready
✔ applied revision 4.0.6

# Get list of HelmRelease objects. Note that I used hr alias
flux -n nginx-ingress get hr
NAME            READY   MESSAGE                                 REVISION        SUSPENDED
nginx-ingress   True    Release reconciliation succeeded        4.0.6           False
```

## Task #6 - generate Helm Release manifest using `flux cli`

If you only need manifest file, use `--export` flag

```bash
# Generate manifest for HelmRelease object
flux -n nginx-ingress create helmrelease nginx-ingress --source=HelmRepository/ingress-nginx --chart=ingress-nginx --values=./internal-ingress.yaml --export > release.yaml

# Check the manifest file
cat ./release.yaml
---
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: nginx-ingress
  namespace: nginx-ingress
spec:
  chart:
    spec:
      chart: ingress-nginx
      sourceRef:
        kind: HelmRepository
        name: ingress-nginx
  interval: 1m0s
  values:
    controller:
      replicaCount: 2
      service:
        annotations:
          service.beta.kubernetes.io/azure-load-balancer-internal: "true"
        loadBalancerIP: 10.12.1.10

```

## Useful links

* [Helm Controller](https://fluxcd.io/docs/components/helm/)
* [flux create source helm](https://fluxcd.io/docs/cmd/flux_create_source_helm/)
* [flux create helmrelease](https://fluxcd.io/docs/cmd/flux_create_helmrelease/)

## Next: 

[Go to lab-07](../lab-07/readme.md)

## Feedback

* Visit the [Github Issue](https://github.com/evgenyb/aks-workshops/issues/xx) to comment on this lab.