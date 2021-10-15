# lab-03 - install Flux CLI to your PC and Flux onto your cluster

## Estimated completion time - xx min


## Task #1 - install Flux CLI 

The Flux CLI is available as a binary executable for all major platforms, the binaries can be downloaded form GitHub releases page.

```bash
# Install the Flux CLI  with Homebrew for macOS and Linux:
brew install fluxcd/tap/flux
```

```powershell
# Install the Flux CLI with Chocolatey for Windows:
choco install flux
```

## Task #2 - create github repository for flux manifests

```powershell
# Create a new repository
gh repo create iac-ws4-flux --private -g VisualStudio -y

✓ Created repository evgenyb/iac-ws4-flux on GitHub
Cloning into 'iac-ws4-flux'...
remote: Enumerating objects: 3, done.
remote: Counting objects: 100% (3/3), done.
remote: Compressing objects: 100% (2/2), done.
remote: Total 3 (delta 0), reused 0 (delta 0), pack-reused 0
Receiving objects: 100% (3/3), done.
```

## Task #3 - generate manifests file and deploy flux into the cluster

```powershell
# Go into newly created repository 
cd .\iac-ws4-flux\

# Create new folder for flux manifests
mkdir clusters/iac-ws4-green-aks/flux-system

# Write install manifests to file
flux install  --export > ./clusters/iac-ws4-green-aks/flux-system/gotk-components.yaml

# Deploy flux components
kubectl apply -f ./clusters/iac-ws4-green-aks/flux-system/gotk-components.yaml

# Verify that the controllers have started
flux check
```

## Task #4 - create git source

When you run `flux create source git` command, flux will generate SSH deploy and will prompt you to add a deploy key to your repository. You can find `Deploy keys` page under the following URL `https://github.com/YOUR-GITHUB-USER/iac-ws4-flux/settings/keys` 

```powershell
# Create a GitRepository object on your cluster by specifying the SSH address of your repo
flux create source git flux-system --url=ssh://git@github.com/evgenyb/iac-ws4-flux --branch=main --interval=1m
```

Behind the scene, flux creates new secret with the same name as the source (`flux-system`) and three data items: `identity`, `identity.pub` and `known_hosts`  

```powershell
# Get information about flux-system secret
kubectl -n flux-system describe secret flux-system
```

## Task #5 - create kustomization object, export k8s manifests and commit them to the repo

```powershell
# Create a Kustomization object on your cluster
flux create kustomization flux-system --source=flux-system --path="./clusters/iac-ws4-green-aks/flux-system/" --prune=false --interval=10m

# At this point, it should fail with similar error, because there are no files under ./clusters/iac-ws4-green-aks/flux-system/ folder yet committed into the repository.
kustomization path not found: stat /tmp/flux-system053895390/clusters/iac-ws4-green-aks/flux-system: no such file or directory
```

```powershell
# Export both source and kustomization objects
flux export source git flux-system > ./clusters/iac-ws4-green-aks/flux-system/gotk-sync.yaml
flux export kustomization flux-system  >> ./clusters/iac-ws4-green-aks/flux-system/gotk-sync.yaml

# Generate a kustomization.yaml
cd ./clusters/iac-ws4-green-aks/flux-system/ 
kustomize create --autodetect

# Commit and push the manifests to Git
git add -A
git commit -m "add sync manifests"
git push

# Wait for Flux to reconcile your previous commit with
flux get kustomizations --watch

# After about a minute, you should see the READY status to be updated to true and MESSAGE containing 'Applied revision: main/....'
NAME            READY   MESSAGE                                                                                                 REVISION        SUSPENDED
flux-system     False   kustomization path not found: stat /tmp/flux-system053895390/clusters/iac-ws4-green-aks/flux-system: no such file or directory                 False
flux-system     Unknown reconciliation in progress              False
flux-system     Unknown reconciliation in progress              False
flux-system     True    Applied revision: main/516b34befb68dc706e4e4c476b58956b8374754d main/516b34befb68dc706e4e4c476b58956b8374754d   False
```

## Task #6 - change kustomization interval

Open `./clusters/iac-ws4-green-aks/flux-system/gotk-sync.yaml` file and change `interval` property `flux-system` kustomization manifests file from `10m0s` to `5m0s`

```yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
kind: Kustomization
metadata:
  name: flux-system
  namespace: flux-system
spec:
  interval: 5m0s
  path: ./clusters/iac-ws4-green-aks/flux-system
  prune: false
  sourceRef:
    kind: GitRepository
    name: flux-system
```

```powershell
# Commit and push the manifests to Git
git add -A
git commit -m "change interval from 10 to 5 min"
git push

# Wait for Flux to reconcile your previous commit with
flux get kustomizations --watch

# After about a minute, the applied revision will change and that means that changes we committed to the github are deployed

# Verify that changes are deployed.
kubectl -n flux-system get ks flux-system -oyaml
``` 

The [source-controller](https://fluxcd.io/docs/components/source/) will pull the changes on the cluster, then kustomize-controller will perform a rolling update of all Flux components including itself.

## Useful links

* [Install the Flux CLI](https://fluxcd.io/docs/installation/#install-the-flux-cli)

## Next: 

[Go to lab-04](../lab-04/readme.md)

## Feedback

* Visit the [Github Issue](https://github.com/evgenyb/aks-workshops/issues/xx) to comment on this lab. 