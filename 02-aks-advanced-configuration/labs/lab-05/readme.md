# lab-05 - add aad-pod-identity support into AKS

## Estimated completion time - 20 min

A `managed identity` for Azure resources lets a pod authenticate itself against Azure services that support it, such as KeyVault or SQL. The pod is assigned an `Azure Identity` that lets them authenticate to Azure Active Directory and receive a digital token. This digital token can be presented to other Azure services that check if the pod is authorized to access the service and perform the required actions. This approach means that no secrets are required for database connection strings, for example. The simplified workflow for pod managed identity is shown in the following diagram:

![pod-identity](images/pod-identity.png)

## Goals

* Learn how to install and configure aad-pod-identity component
* Learn how to create a user-assigned managed identity and deploy `AzureIdentity` and `AzureIdentityBinding` resources
* Learn how to configure your AKS pod to use Managed Identity
* Use dotnet api application to test this functionality

## Task #1 - install and configure aad-pod-identity component

For `aad-pod-identity` to function, our cluster needs the correct role assignment configuration to perform Azure-related operations such as assigning and un-assigning the identity on the underlying VM/VMSS. 

We configured AKS cluster with user-assigned managed identity to communicate with Azure. The roles `Managed Identity Operator` and `Virtual Machine Contributor` must be assigned to the cluster managed identity so that it can assign and un-assign identities from the underlying VMSS. If application managed identities are not within the node resource group (this is our case, because we will provision them under `iac-ws2-rg` resource group), additional `Managed Identity Operator` role needs to be assigned to the identity resource group scope.

`aad-pod-identity` provides [bash script](https://raw.githubusercontent.com/Azure/aad-pod-identity/master/hack/role-assignment.sh) that does all necessary roles assignment. You can find this script under `02-aks-advanced-configuration\k8s\aad-pod-identity` folder. 
Let's use this script to configure our cluster:

```bash
# Go to 02-aks-advanced-configuration\k8s\aad-pod-identity folder
cd 02-aks-advanced-configuration\k8s\aad-pod-identity

export SUBSCRIPTION_ID="<YOUR SUBSCRIPTION ID>"
export RESOURCE_GROUP="iac-ws2-blue-rg"
export CLUSTER_NAME="iac-ws2-blue-aks"

# Optional: if you are planning to deploy your user-assigned identities
# in a separate resource group instead of your node resource group
export IDENTITY_RESOURCE_GROUP="iac-ws2-rg"

# Configure role assignments
./role-assignment.sh 

# Create msi namespace
kubectl create ns msi

# Deploy msi components into msi namespace
kubectl apply -f ./deployment.yaml

# Deploy msi exceptions
kubectl apply -f ./mic-exception.yaml

# Check what is deployed to msi namespace
kubectl get po -n msi
mic-7984844578-5cfbl   1/1     Running   0          74m
mic-7984844578-w695v   1/1     Running   0          74m
nmi-j9dzw              1/1     Running   0          74m
nmi-v6d7q              1/1     Running   0          74m
```

You should have two `mic` pods and one `nmi` daemon set at each node. 

## Task #2 - create KeyVault and create new secret

As described at tha application use-case, our `api-b` application needs to get access to the secrets from the key-vault.
Let's create new `iac-ws2-<YOUR-NAME>-api-b-kv` key-vault in `iac-ws2-rg` resource group.

```bash
# Create api-b KeyVault 
az keyvault create -g iac-ws2-rg -n iac-ws2-<YOUR-NAME>-api-b-kv -l westeurope

# Create secret foobar with value barfoo
az keyvault secret set --vault-name iac-ws2-<YOUR-NAME>-api-b-kv -n foobar --value barfoo
```

## Task #3 - deploy app and verify functionality

Open `aks-workshops\01-aks-and-k8s-101\app\apps.sln` solution in Visual Studio and check `aks-workshops\02-aks-advanced-configuration\src\api-b\Controllers\KeyVaultTestController.cs` file. This is a test controller that we will use to test access to keyvault with managed identities. 

```c#
var uri = _configuration["KeyVaultUrl"];
_logger.LogInformation($"Trying to get secret foobar from {uri} key-vault.");
var options = new SecretClientOptions()
{
    Retry =
    {
        Delay= TimeSpan.FromSeconds(2),
        MaxDelay = TimeSpan.FromSeconds(16),
        MaxRetries = 5,
        Mode = RetryMode.Exponential
    }
};
var client = new SecretClient(new Uri(uri), new DefaultAzureCredential(), options);
```

This code first reads keyvault URL from app settings, then uses `DefaultAzureCredential()` to authenticate to Key Vault, which uses a token from managed identity to authenticate. For more information about authenticating to Key Vault, see the [Developer's Guide](https://docs.microsoft.com/en-us/azure/key-vault/general/developers-guide?WT.mc_id=AZ-MVP-5003837#authenticate-to-key-vault-in-code). The code also uses exponential back-off for retries in case Key Vault is being throttled. For more information about Key Vault transaction limits, see [Azure Key Vault throttling guidance](https://docs.microsoft.com/en-us/azure/key-vault/general/overview-throttling?WT.mc_id=AZ-MVP-5003837). 

Then it retrieves secret `foobar` from the keyvault and logs it. 

```c#
var secret = await client.GetSecretAsync("foobar");
_logger.LogInformation($"foobar: {secret.Value.Value}");
```

## Task #4 - create User-Assigned Managed Identity 

In order for code from  `KeyVaultTestController` to work, we need to create managed identity for our `api-b` application. 
Based on our [naming convention](../../naming-conventions.md), we call it `iac-ws2-api-b-mi`.

Create an identity on Azure and store the client ID and resource ID of the identity as environment variables:

```bash
# Create User Assigned Managed Identity iac-ws2-api-b-mi
az identity create -g iac-ws2-rg -n iac-ws2-api-b-mi

# Get Managed Identity client ID
export IDENTITY_CLIENT_ID="$(az identity show -n iac-ws2-api-b-mi -g iac-ws2-rg --query clientId -o tsv)"
export IDENTITY_RESOURCE_ID="$(az identity show -n iac-ws2-api-b-mi -g iac-ws2-rg --query id -o tsv)"
```

We need to grant managed identity with `secret get` permissions at the KeyVault.

```bash
# Get managed identity AAD object ID
export OBJECT_ID="$(az identity show -n iac-ws2-api-b-mi -g iac-ws2-rg --query principalId -o tsv)"

# Grant iac-ws2-api-b-mi managed identity with get secret permission at iac-ws2-<YOUR-NAME>-api-b-kv keyvault
az keyvault set-policy -g iac-ws2-rg -n iac-ws2-<YOUR-NAME>-api-b-kv --secret-permissions get --object-id ${OBJECT_ID}

```

For Azure managed identity, we need to create a corresponding kubernetes `AzureIdentity` and `AzureIdentityBinding` Kubernetes resources.

```bash
# Create an AzureIdentity in your cluster that references the identity you created above:

cat <<EOF | kubectl apply -f -
apiVersion: "aadpodidentity.k8s.io/v1"
kind: AzureIdentity
metadata:
  name: api-b
spec:
  type: 0
  resourceID: ${IDENTITY_RESOURCE_ID}
  clientID: ${IDENTITY_CLIENT_ID}
EOF

# Get azureidentity resource
kubectl get azureidentity
NAME    AGE
api-b   2m4s

# Get azureidentity description
kubectl describe azureidentity api-b

# Create an AzureIdentityBinding that reference the AzureIdentity you created above:
cat <<EOF | kubectl apply -f -
apiVersion: "aadpodidentity.k8s.io/v1"
kind: AzureIdentityBinding
metadata:
  name: api-b-binding
spec:
  azureIdentity: api-b
  selector: api-b
EOF

# Get azureidentitybinding resource
kubectl get azureidentitybinding
NAME            AGE
api-b-binding   2m

# Get azureidentitybinding description
kubectl describe azureidentitybinding api-b-binding
```

## Task #5 - deploy api-b application and test functionality

For a pod to match an identity binding, it needs a label with the key `aadpodidbinding` whose value is that of the `selector:` field in the `AzureIdentityBinding`. In our case, `selector:` field of `api-b-binding` is `api-b`, therefore we need to add additional label `aadpodidbinding: api-b` to the pod manifest.

We also need to add `KeyVaultUrl` setting into `appsettings`, pointing to our Azure KeyVault url.

```bash
# Get KeyVault url 
az keyvault show -g iac-ws2-rg -n iac-ws2-<YOUR-NAME>-api-b-kv --query properties.vaultUri -o tsv
https://iac-ws2-evg-api-b-kv.vault.azure.net/
```

Create new `lab5-task5.yaml` file with the following deployment manifest. Note that we added `configmap` with reference to the keyvault url and mount it as a `volume` to the pod. 

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: lab5-task5-appsettings
data:
  appsettings.json: |-
    {
      "KeyVaultUrl": "<Use properties.vaultUri value from the above command>"
    }
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: lab5-task5
  labels:
    app: lab5-task5
spec:
  replicas: 1
  selector:
    matchLabels:
      app: lab5-task5
  template:
    metadata:
      labels:
        app: lab5-task5
        aadpodidbinding: api-b
    spec:
      containers:
      - name: api
        image: iacws2<YOUR-NAME>acr.azurecr.io/apib:v1
        imagePullPolicy: IfNotPresent
        resources: {}
        volumeMounts:
        - name: appsettings
          mountPath: /app/config          
      volumes:
      - name: appsettings
        configMap:
          name: lab5-task5-appsettings
```

Deploy a pod:

```bash
# Deploy api-b application
kubectl apply -f .\lab5-task5.yaml
```

In the right-hand terminal session, start streaming logs form the pod

```bash
# Get lab5-task5 pod name
kubectl get po -o wide
lab5-task5-75fb8c5b75-nfqrc   1/1     Running   0          13m   10.11.0.148   aks-workload-27376456-vmss000000   <none>           <none>

# Start streaming logs 
kubectl logs lab5-task5-75fb8c5b75-nfqrc -f
```

Test and verify functionality:

```bash
# Create and attach to curl pod with interactive shell
kubectl run curl -i --tty --rm --restart=Never --image=radial/busyboxplus:curl -- sh

# Test keyvaulttest endpoint. Use pod IP from  "kubectl get po -o wide" command
[ root@curl:/ ]$ curl http://10.11.0.148/keyvaulttest
[api-b.keyvaulttest] - OK
```

In the logs stream session, you should see thr following traces:

```bash
...
11.04.2021 07:54:22 [Information] Trying to get secret foobar from https://iac-ws2-<YOU-NAME>-api-b-kv.vault.azure.net/ key-vault.
11.04.2021 07:54:22 [Information] foobar: barfoo
...
```

## Useful links

* [What are managed identities for Azure resources?](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview)
* [Services that support managed identities for Azure resources](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/services-support-managed-identities)
* [Use Key Vault from App Service with Azure Managed Identity](https://docs.microsoft.com/en-us/samples/azure-samples/app-service-msi-keyvault-dotnet/keyvault-msi-appservice-sample/?WT.mc_id=AZ-MVP-5003837)
* [Azure Key Vault configuration provider in ASP.NET Core](https://docs.microsoft.com/en-us/aspnet/core/security/key-vault-configuration?view=aspnetcore-5.0&WT.mc_id=AZ-MVP-5003837)
* [Tutorial: Use a managed identity to connect Key Vault to an Azure web app in .NET](https://docs.microsoft.com/en-us/azure/key-vault/general/tutorial-net-create-vault-azure-web-app?WT.mc_id=AZ-MVP-5003837)
* [Azure Active Directory Pod Identity for Kubernetes](https://azure.github.io/aad-pod-identity/docs/)
* [Standard Walkthrough](https://azure.github.io/aad-pod-identity/docs/demo/standard_walkthrough/)
* [AAD Pod Identity Tutorial](https://azure.github.io/aad-pod-identity/docs/demo/tutorial/)
* [Role Assignment](https://azure.github.io/aad-pod-identity/docs/getting-started/role-assignment/)
* [aad-pod-identity releases](https://github.com/Azure/aad-pod-identity/releases)

## Next: 

[Go to lab-06](../lab-06/readme.md)

## Feedback

* Visit the [Github Issue](https://github.com/evgenyb/aks-workshops/issues/19) to comment on this lab. 