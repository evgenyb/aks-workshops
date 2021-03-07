# lab-06 - 

## Estimated completion time - xx min


## Goals

## Task #1 - 

```bash

# Add new node pool
az aks nodepool add -g iac-ws2-aks-blue-rg --cluster-name aks-ws2-blue \
    --name workloadpool \
    --node-count 1 \
    --max-pods 110 \
    --node-vm-size Standard_DS2_v2 \
    --kubernetes-version 1.19.6 \
    --mode User

# Set CriticalAddonsOnly=true:NoSchedule taint to nodes from system pool
kubectl taint node -l agentpool=systempool CriticalAddonsOnly=true:NoSchedule
```


## Useful links
https://docs.microsoft.com/en-us/azure/aks/use-multiple-node-pools
https://docs.microsoft.com/en-us/azure/aks/use-system-pools
https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/



## Next: 

[Go to lab-07](../lab-07/readme.md)

## Feedback

* Visit the [Github Issue](https://github.com/evgenyb/aks-workshops/issues/xx) to comment on this lab. 