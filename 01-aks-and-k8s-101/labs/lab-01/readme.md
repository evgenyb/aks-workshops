
```bash
az acr create --resource-group aks-lab01-rg -n iacakslab01 --sku Basic
```

```bash
az aks update -n aks-lab01 -g aks-lab01-rg --attach-acr iacakslab01
```