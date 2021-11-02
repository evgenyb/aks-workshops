# lab-06 - kustomize 101

## Estimated completion time - xx min

[Kustomize](https://kustomize.io/) is a standalone command-line tool to customize Kubernetes objects through a [kustomization file](https://kubectl.docs.kubernetes.io/references/kustomize/glossary/). Kustomize is an overlay engine. You create a base configuration and overlays. Any variants/changes are applied over the top of the base configuration.

Let's look at the nginx ingress configuration. There are two clusters in our environment - `blue` and `green`. Remember `internal-ingress.yaml` file that we created in `lab #2` and `lab #5`? 

```yaml
controller:
  replicaCount: 2
  service:
    annotations:
      service.beta.kubernetes.io/azure-load-balancer-internal: "true"
    loadBalancerIP: 10.12.1.10
```

It contains `loadBalancerIP` property that is different for `blue` and `green` clusters, because clusters are deployed to the different Private Virtual Networks with different IP address ranges. 

The complete generated `HelmRelease` manifest for nginx ingress controller looks as follow.

```yaml
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
      version: 4.0.6
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

We can commit these `HelmRelease` manifest files "as is" under `clusters/blue|green/` folders, but in this case there will be twice as much maintenance work associated with these manifests. What if there are more environments? 

What we can do instead is to use `kustomize`. Implement "master" manifest at the base level and implement overlays per cluster|environment. These overlays will only contain values that are different. In our example, the potential values to be extracted into overlays are:

* `loadBalancerIP` - we already know that IP address will be different per cluster
* `replicaCount` - this value can be different for different environment. We might be OK with one replica in dev environment but we definitely need more than one replicas in production
* `version` - version also can be different between environments. Production can be at the latest stable version `4.0.6` and we can start experimenting with new version or event with a beta version in dev environment.

## Goals

In this lab we will learn how to use `kustomize` to implement the nginx ingress controller "use-case" described above.

## Task #1 - install kustomize

If you are on Windows, use [Chocolatey](https://chocolatey.org/install)

```bash
# If you are on Windows, use choco
choco install kustomize

# If you are on Mac, use 
brew install kustomize

# check the version
kustomize version
```

## Task #2 - create folder structure

Our project should have directory structure like the following

```txt
.
├── base
│   ├── nginx-ingress
│   │   ├── release.yaml
│   │   └── kustomization.yaml
│   └── kustomization.yaml
├── iac-ws4-blue-aks
│   ├── patches-nginx-ingress.yaml
│   └── kustomization.yaml
└── iac-ws4-green-aks
    ├── patches-nginx-ingress.yaml
    └── kustomization.yaml
```

The base directory contains one `kustomization.yaml` file with the following content:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- release.yaml
```

and `release.yaml` manifest file with the following content:

```yaml
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
      version: TO-BE-REPLACED
      sourceRef:
        kind: HelmRepository
        name: ingress-nginx
  interval: 1m0s
  values:
    controller:
      admissionWebhooks:
        patch:
          nodeSelector:
            beta.kubernetes.io/os: linux
      nodeSelector:
        beta.kubernetes.io/os: linux
      replicaCount: 2
      service:
        annotations:
          service.beta.kubernetes.io/azure-load-balancer-internal: "true"
        loadBalancerIP: TO-BE-REPLACED
    defaultBackend:
      nodeSelector:
        beta.kubernetes.io/os: linux
```
Note that properties that must to be overwritten (like `loadBalancerIP`) use `TO-BE-REPLACED` as a value. Properties that can be overwritten, contain the default value.

The `iac-ws4-blue-aks` and `iac-ws4-green-aks` folders contain `kustomization.yaml` file with the following content:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../base/nginx-ingress
patchesStrategicMerge:
  - patches-nginx-ingress.yaml
```

and `patches-nginx-ingress.yaml` patch file with the following content:

```yaml
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
      version: 4.0.5
  values:
    controller:
      replicaCount: 1
      service:
        loadBalancerIP: 10.11.1.10
```

## Task #3 - build manifest files for blue cluster

```bash
# Make sure you are at the same level with base folder
pwd
...\completed-labs\lab-06

# Build manifest files for blue cluster
kustomize build ./iac-ws4-blue-aks
```

You should see the valid YAML manifest and all `TO-BE-REPLACED` values should be replaced with values from `iac-ws4-blue-aks/patches-nginx-ingress.yaml` file.

## Useful links

* [Install Kustomize](https://kubectl.docs.kubernetes.io/installation/kustomize/)
* [Kubernetes native configuration management](https://kustomize.io/)
* [Kustomize tutorial](https://kustomize.io/tutorial)

## Next: monorepo as Flux repository structure

[Go to lab-08](../lab-08/readme.md)

## Feedback

* Visit the [Github Issue](https://github.com/evgenyb/aks-workshops/issues/xx) to comment on this lab.