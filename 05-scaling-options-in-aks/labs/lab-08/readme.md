# lab-08 - deploy Kubernetes Event-driven Autoscaling KEDA

Before we start working with KEDA, we need to deploy it into the cluster.

## Task #1 - install helm

If you haven't install `helm` before, you need to install it first. 

```bash
# For Mac users, use Homebrew 
brew install helm

# For Window users, use Chocolatey (aka choco)
choco install kubernetes-helm 

# Check helm version
helm version
version.BuildInfo{Version:"v3.7.1", GitCommit:"1d11fcb5d3f3bf00dbe6fe31b8412839a96b3dc4", GitTreeState:"clean", GoVersion:"go1.16.9"}
```

## Task #2 - install KEDA

```bash
# Add KEDA Helm repo
helm repo add kedacore https://kedacore.github.io/charts

# Update Helm repo
helm repo update

# Create keda namespace
kubectl create namespace keda

# Install KEDA Helm chart
helm install keda kedacore/keda --namespace keda

# Check KEDA is up and running
kubectl -n keda get po
keda-operator-5748df494c-grnsq                    1/1     Running   0          7m54s
keda-operator-metrics-apiserver-cb649dd48-lsmzv   1/1     Running   0          7m54s
```

When you install KEDA, it creates four [custom resources](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/):

* scaledobjects.keda.sh
* scaledjobs.keda.sh
* triggerauthentications.keda.sh
* clustertriggerauthentications.keda.sh


Read more about those resources at the [original documentation](https://keda.sh/docs/2.5/concepts/#custom-resources-crd) 
## Useful links

* [Installing Helm](https://helm.sh/docs/intro/install/)
* [Kubernetes Event-driven Autoscaling](https://keda.sh/)
* [The KEDA Documentation](https://keda.sh/docs/2.5/)
* [Deploying KEDA](https://keda.sh/docs/2.5/deploy/)
* [KEDA samples](https://github.com/kedacore/samples)
* [Kubernetes Custom Resources](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/)
* [KEDA Custom Resources](https://keda.sh/docs/2.5/concepts/#custom-resources-crd) 

## Next: use KEDA to autoscale application processing Azure Service Bus Queue

[Go to lab-09](../lab-09/readme.md)