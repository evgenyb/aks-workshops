[x] - implement Bicep IaC for AKS infrastructure including:
    RG, VNet, ACR, LA, AKS
    Use parameters files for env specific values

[ ] - implement k8s manifests for the following k8s resources
    [ ] - namespaces
    [ ] - RBAC
    [ ] - aad-pod-identity

[ ] - deploy nginx ingress controller using helm 
[ ] - deploy prometheus + grafana using helm 

[ ] - prepare flux manifests
[ ] - deploy flux

```powershell
flux bootstrap github --owner=$Env:GITHUB_USER --repository=iac-ws4-flux --branch=master --path=./clusters/iac-ws4-blue-aks --personal
```

[ ] - configure flux with git repo
[ ] - upgrade flux using GitOps  
[ ] - implement Helm deployment with flux
