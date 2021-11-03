# lab-08 - working with notifications

## Estimated completion time - xx min

When operating a cluster, you may want to receive notifications about the status of GitOps pipelines. For example, the on-call team would receive alerts about reconciliation failures in the cluster, while the dev team may wish to be alerted when a new version of an app was deployed and if the deployment is healthy.

![notification-controller](https://fluxcd.io/img/notification-controller.png)

The Flux controllers emit Kubernetes events whenever a resource status changes. You can use the notification-controller to forward these events to `Slack` or `Microsoft Teams`. The notification controller is part of the default Flux installation.


## Goals

* Setup Flux Notifications into the `Slack`

## Task #1 - Install Slack and create workspace

If you already using `Slack`, you can skip this step. 

First, [download](https://slack.com/downloads/windows) install Slack.
Next, create new Slack workspace by following the following [instructions](https://slack.com/help/articles/206845317-Create-a-Slack-workspace).

Here is how my newly created Workspace looks like

![ws](images/slack-new-ws.png)

## Task #2 - set up incoming webhook

Follow the following [instructions](https://slack.com/help/articles/115005265063-Incoming-webhooks-for-Slack) to create a new webhook.

The last step at this process should look similar to this

![webhook](images/slack-webhook.png)

and you need tp copy this URL. 


## Task #3 - create a secret with your Slack incoming webhook

```bash
# Create a secret with your Slack incoming webhook
kubectl -n flux-system create secret generic slack-url --from-literal=address=your_slack_webhook
secret/slack-url created

# Create slack alert provider
flux create alert-provider slack --type slack --channel aks-flux-gitops --secret-ref slack-url 
✚ generating Provider
► applying Provider
✔ Provider created
◎ waiting for Provider reconciliation
✔ Provider slack is ready
```

I want my alerts to be sent into the `aks-flux-gitops` Slack channel. Change it if you use different channel name.

```bash
# Create an alert definition for all github repositories and kustomizations
flux create alert slack-alert --event-severity info --event-source Kustomization/* --event-source GitRepository/* --provider-ref slack
✚ generating Alert
► applying Alert
✔ Alert created
◎ waiting for Alert reconciliation
✔ Alert slack-alert is ready
```

As always, if you need to generate Kubernetes manifest files without creating resources, use `--export` flag.

## Useful links

* [Notification Controller](https://fluxcd.io/docs/components/notification/)
* [Flux: Alert](https://fluxcd.io/docs/components/notification/alert/)
* [Flux: Provider](https://fluxcd.io/docs/components/notification/provider/)
* [flux create alert-provider](https://fluxcd.io/docs/cmd/flux_create_alert-provider/)
* [flux create alert](https://fluxcd.io/docs/cmd/flux_create_alert/)
* [Incoming webhooks for Slack](https://slack.com/help/articles/115005265063-Incoming-webhooks-for-Slack)
* [Create a Slack workspace](https://slack.com/help/articles/206845317-Create-a-Slack-workspace)

## Next: monorepo as Flux repository structure

[Go to lab-08](../lab-08/readme.md)

## Feedback

* Visit the [Github Issue](https://github.com/evgenyb/aks-workshops/issues/xx) to comment on this lab.