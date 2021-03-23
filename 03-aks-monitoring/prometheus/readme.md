
```bash
# Create resource group
az group create -n iac-aks-ws3-rg -l westeurope

# Create a blob storage account
az storage account create --name iacaksws3premetheussa --resource-group iac-aks-ws3-rg --location westeurope --sku Standard_LRS --encryption-services blob

# Create container for the metrics
az storage container create --account-name iacaksws3premetheussa --name thanos

# Get the storage keys
az storage account keys list -g iac-aks-ws3-rg -n iacaksws3premetheussa --query [0].value -o tsv
```

Create `thanos-objectstorage.yaml` file for the storage settings with the following content:

```yaml
type: AZURE
config:
  storage_account: "iacaksws3premetheussa"
  storage_account_key: "<key>"
  container: "thanos"
```

Create a Kubernetes Secret with `thanos` configuration

```bash
kubectl create ns monitoring
kubectl -n monitoring create secret generic thanos-objstoreconfig --from-file=thanos.yaml=thanos-objstoreconfig.yaml
```

Create `prometheus-operator-values.yaml` values file to override the default Prometheus-Operator settings with the following content:

```yaml
```

Deploy prometheus

```bash
helm install prometheus --namespace monitoring prometheus-community/kube-prometheus-stack -f prometheus-operator-values.yaml
```

## Links

* https://itnext.io/monitoring-kubernetes-workloads-with-prometheus-and-thanos-4ddb394b32c
* https://kruschecompany.com/kubernetes-prometheus-operator/
* https://github.com/prometheus-operator/kube-prometheus#quickstart
* https://howchoo.com/kubernetes/install-prometheus-and-grafana-in-your-kubernetes-cluster
* https://github.com/prometheus-operator/prometheus-operator/blob/master/Documentation/api.md#thanosspec
* https://docs.bitnami.com/tutorials/create-multi-cluster-monitoring-dashboard-thanos-grafana-prometheus/
* https://banzaicloud.com/blog/multi-cluster-monitoring/
* https://aws.amazon.com/blogs/opensource/improving-ha-and-long-term-storage-for-prometheus-using-thanos-on-eks-with-s3/