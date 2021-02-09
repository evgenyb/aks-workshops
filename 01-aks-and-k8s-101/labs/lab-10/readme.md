# lab-10 - Cleaning up

## Estimated completion time - 10 min

To avoid Azure charges, you should clean up unneeded resources. When the cluster is no longer needed, use the az group delete command to remove the ACR, AKS, resource group and all related resources.

## Goals

* Cleanup unused resources to avoid unnecessary Azure costs


## Task #1 - delete the cluster

Since all resource used by the cluster and cluster itself were provisioned under the same resource group, the simplest way to cleanup is to delete resource group itself.

```bash
az group delete -n iac-aks-ws1-rg --yes --no-wait
```

Since estimated time for this operation to be completed is 5-10 min, you can use `--no-wait` flag to not wait for the long-running operation to finish. 


## Useful links

* [az group delete](https://docs.microsoft.com/en-us/cli/azure/group?view=azure-cli-latest&WT.mc_id=AZ-MVP-5003837#az_group_delete)
