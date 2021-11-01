
```powershell
# Create a Secret containing the slack webhook
kubectl -n flux-system create secret generic slack-url --from-literal=address=your_slack_webhook

# 
flux create alert-provider slack --type slack --channel general --secret-ref slack-url --export > ./clusters/iac-ws4-green-aks/slack-alert-provider.yaml

# 
flux create alert slack-alert --event-severity info --event-source Kustomization/* --event-source GitRepository/* --provider-ref slack --export > ./clusters/iac-ws4-green-aks/slack-alert.yaml

```