# lab-10 - AKS egress

## Estimated completion time - xx min


## Goals

## Task #1 - 

```bash
# Create public IP address from prefix 
az network public-ip create -g iac-ws2-aks-blue-rg -n iac-ws2-aks-blue-egress-pip --sku Standard --public-ip-prefix <PREFIX-ID> 

# Get public egress IP ID
az network public-ip show -g iac-ws2-aks-blue-rg -n iac-ws2-aks-blue-egress-pip --query id

# Update AKS egress with PIP maintained by us
az aks update -g iac-ws2-aks-blue-rg -n aks-ws2-blue  \
	--load-balancer-outbound-ips <PUBLIC-EGRESS-IP-ID>

```

## Useful links
https://docs.microsoft.com/en-us/azure/aks/limit-egress-traffic
https://docs.microsoft.com/en-us/azure/aks/egress


## Next: 

[Go to lab-11](../lab-11/readme.md)

## Feedback

* Visit the [Github Issue](https://github.com/evgenyb/aks-workshops/issues/xx) to comment on this lab. 