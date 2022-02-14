# lab-07 - use Azure Monitor Data Source in Grafana

## Estimated completion time - xx min

Grafana supports many different storage backends for your time series data (data source). Refer to [Add a data source](https://grafana.com/docs/grafana/latest/datasources/add-a-data-source/) for instructions on how to add a data source to Grafana. 

Grafana includes built-in support for Azure Monitor. The Azure Monitor data source supports visualizing data from three Azure services:

* Azure Monitor Metrics to collect numeric data from resources in your Azure account.
* Azure Monitor Logs to collect log and performance data from your Azure account, and query using the powerful Kusto Language.
* Azure Resource Graph to quickly query your Azure resources across subscriptions.


## Goals

* 

## Task #1 - create an Azure AD application and service principal

We must create an Azure AD app registration and service principal to authenticate the data source from Grafana. 

> You must have sufficient permissions to register an application with your Azure AD tenant, and assign to the application a role in your Azure subscription.

If you are more comfortable working in the portal, [use the portal to create an Azure AD application and service principal](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal#get-tenant-and-app-id-values-for-signing-in). 

Otherwise, use the following script:

```bash
# Get resource group resource id
az group show -n iac-ws6-rg --query id

# Create new SPN with  'Monitoring Reader' role at the iac-ws6-rg scope. Use resource group id from the previous query 
az ad sp create-for-rbac -n 'grafana-data-source-spn' --role 'Monitoring Reader' --scope <RG-ID> --years 3
```

If succeeded, you will get the following json back

```json
{
  "appId": "...",
  "displayName": "grafana-data-source-spn",
  "password": "...",
  "tenant": "..."
}
```

Don't close this window or copy result somewhere. We will need this information at the next Task when we create Azure Monitor Data Source.

## Task #2 - add Azure Monitor Data Source into Grafana

First, make sure that you still have access to your Grafana instance.

```bash
# Access Grafana dashboard
kubectl --namespace monitoring port-forward svc/grafana 3000
```

Navigate to `Data sources` http://localhost:3000/datasources and click `Add data source`

![g-ds-1](images/g-ds-1.png)

Search for `azure` and select `Azure Monitor` data source

![g-ds-1](images/g-ds-2.png)

Use `appId`, `tenant` and `password` from the `Task #1` and 



## Useful links

* [Azure Monitor data source](https://grafana.com/docs/grafana/latest/datasources/azuremonitor/)
* [Add a data source](https://grafana.com/docs/grafana/latest/datasources/add-a-data-source/)
* [Grafana data source as code - or how to automate deployment of Azure Monitor data sources to Grafana for multi-team setup](https://borzenin.com/grafana-data-source-as-code-or-how-to-deploy-azure-monitor-data-course-to-grafana/)
* [Use the portal to create an Azure AD application and service principal that can access resources](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal)
* [Azure Monitor Log Analytics API Overview](https://docs.microsoft.com/en-gb/azure/azure-monitor/logs/api/overview)

## Next: cleaning up resources

[Go to lab-08](../lab-08/readme.md)