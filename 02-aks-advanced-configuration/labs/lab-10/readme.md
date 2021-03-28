# lab-10 - AKS egress

## Estimated completion time - xx min


## Goals

## Task #1 - 

```bash
# Get Public IP prefix ID
az network public-ip prefix show  -g iac-ws2-base-rg -n iac-ws2-pip-prefix --query id -o tsv

# Create public IP address from prefix 
az network public-ip create -g iac-ws2-aks-blue-rg -n iac-ws2-aks-blue-egress1-pip --sku Standard --public-ip-prefix <PREFIX-ID> 
az network public-ip create -g iac-ws2-aks-blue-rg -n iac-ws2-aks-blue-egress2-pip --sku Standard --public-ip-prefix <PREFIX-ID> 

# Get public egress IP ID
EGRESS1=$(az network public-ip show -g iac-ws2-aks-blue-rg -n iac-ws2-aks-blue-egress1-pip --query id -o tsv)
EGRESS2=$(az network public-ip show -g iac-ws2-aks-blue-rg -n iac-ws2-aks-blue-egress2-pip --query id -o tsv)

# Update AKS egress with PIP maintained by us
az aks update -g iac-ws2-aks-blue-rg -n aks-ws2-blue --load-balancer-outbound-ips /subscriptions/8878beb2-5e5d-4418-81ae-783674eea324/resourceGroups/iac-ws2-aks-blue-rg/providers/Microsoft.Network/publicIPAddresses/iac-ws2-aks-blue-egress1-pip, /subscriptions/8878beb2-5e5d-4418-81ae-783674eea324/resourceGroups/iac-ws2-aks-blue-rg/providers/Microsoft.Network/publicIPAddresses/iac-ws2-aks-blue-egress2-pip

```

## Useful links
https://docs.microsoft.com/en-us/azure/aks/limit-egress-traffic
https://docs.microsoft.com/en-us/azure/aks/egress


## Next: 

[Go to lab-11](../lab-11/readme.md)

## Feedback

* Visit the [Github Issue](https://github.com/evgenyb/aks-workshops/issues/xx) to comment on this lab. 