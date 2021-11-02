# lab-04 - use Flux to deploy Kubernetes manifests

## Estimated completion time - xx min


## Goals

* Create Kubernetes secret with Git SSH authentication key
* Create GitRepository using `flux cli`
* Generate GitRepository manifest using `flux cli`
* Create Kustomization using `flux cli`
* Generate Kustomization manifest using `flux cli`

## Task #1 - create new github repository

```bash
# Create new iac-ws4-lab04 repository. Make sure that you run this command outside of github repository, otherwise you will get the following error message  'error: remote origin already exists.' and you will need to clone iac-ws4-lab03 to some other folder.
gh repo create iac-ws4-lab04 --private -g VisualStudio -y
```

## Task #2 - create deployment key

```bash
# Create a Git SSH authentication secret
flux create secret git iac-ws4-lab04 --url=ssh://git@github.com/evgenyb/iac-ws4-lab04 --ssh-key-algorithm=rsa  --ssh-rsa-bits 4096

✚ deploy key: ssh-rsa AAAAB...==

► git secret 'iac-ws4-lab04' created in 'flux-system' namespace
```

At this point, you need to create new deployment key at the `iac-ws4-lab04` repository. Navigate to `https://github.com/<YOUR-GITHUB-USER>/iac-ws4-lab04/settings/keys` and click `Add deployment key`

![add-deployment-key](images/new-deployment-key-1.png)

At the form, give the new deployment key a name, for instance `flux-aks-blue` and then copy `deploy key` ssh key from the output of the `flux create secret git` command

![ssh](images/ssh-section.png)

into the `Key` field 

![key](images/new-deployment-key-2.png)

and click `Add key`.

## Task #3 - create new GitRepository using `flux cli`

There are two ways you can create GitRepository. You can manually create k8s manifest file or you can use `flux create source git` command. You can execute `flux create source git` command and it will deploy `GitResource` to the cluster. If you only want `flux` to generate `GitResource` manifest, use `--export` flag. 

```bash
# Create new github repository 
flux create source git iac-ws4-lab04-1 --url=ssh://git@github.com/evgenyb/iac-ws4-lab04 --secret-ref iac-ws4-lab04 --branch=main --interval=1m

✚ generating GitRepository source
► applying GitRepository source
✔ GitRepository source created
◎ waiting for GitRepository source reconciliation
✔ GitRepository source reconciliation completed
✔ fetched revision: main/7657e4a6680283f530b618d5afb31542dd4a9f05
```

Note that we referenced `iac-ws4-lab04` secret created at the step 1.

## Task #4 - use `flux cli` to generate `GitRepository` manifest 

Somtimes you only want to generate k8s manifest withtou actually creating resource in Kubernetes. You can still use `flux create source git` command, but with `--export` flag.

```bash
# Make sure that you are inside iac-ws4-lab04 repo folder
pwd
Path
----
C:\Users\evgen\git\iac-ws4-lab04

# Generate GitRepository manifest 
flux create source git iac-ws4-lab04-2 --url=ssh://git@github.com/evgenyb/iac-ws4-lab04 --secret-ref iac-ws4-lab04 --branch=main --interval=1m --export > iac-ws4-lab04-2-source.yaml
```

Check the content of the `iac-ws4-lab04-2-source.yaml` file. It should look like this:

```yaml
---
apiVersion: source.toolkit.fluxcd.io/v1beta1
kind: GitRepository
metadata:
  name: iac-ws4-lab04-2
  namespace: flux-system
spec:
  interval: 1m0s
  ref:
    branch: main
  secretRef:
    name: iac-ws4-lab04
  url: ssh://git@github.com/<YOUR-GITHUB-USER>/iac-ws4-lab04
```

Now you can deploy it using `kubectl`

```bash
# Deploy iac-ws4-lab04-2-source.yaml manifest

kubectl apply -f ./iac-ws4-lab04-2-source.yaml
gitrepository.source.toolkit.fluxcd.io/iac-ws4-lab04-2 created

# Get list of GitRepositories using flux
flux get source git
NAME            READY   MESSAGE                                                         REVISION                                        SUSPENDED
flux-system     True    Fetched revision: main/042d13d34b222e0a0955f88f09cc84f848545f69 main/042d13d34b222e0a0955f88f09cc84f848545f69   False
iac-ws4-lab04-1 True    Fetched revision: main/7657e4a6680283f530b618d5afb31542dd4a9f05 main/7657e4a6680283f530b618d5afb31542dd4a9f05   False
iac-ws4-lab04-2 True    Fetched revision: main/7657e4a6680283f530b618d5afb31542dd4a9f05 main/7657e4a6680283f530b618d5afb31542dd4a9f05   False

# Get list of GitRepositories using kubectl
kubectl -n flux-system get GitRepository
NAME              URL                                             READY   STATUS                                                            AGE
flux-system       ssh://git@github.com/evgenyb/iac-ws4-lab03-05   True    Fetched revision: main/042d13d34b222e0a0955f88f09cc84f848545f69   134m
iac-ws4-lab04-1   ssh://git@github.com/evgenyb/iac-ws4-lab04      True    Fetched revision: main/7657e4a6680283f530b618d5afb31542dd4a9f05   15m
iac-ws4-lab04-2   ssh://git@github.com/evgenyb/iac-ws4-lab04      True    Fetched revision: main/7657e4a6680283f530b618d5afb31542dd4a9f05   45s
```

## Useful links

* [k8s: Namespaces](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)

## Next: 

[Go to lab-05](../lab-05/readme.md)

## Feedback

* Visit the [Github Issue](https://github.com/evgenyb/aks-workshops/issues/xx) to comment on this lab.