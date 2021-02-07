# lab-08 - Configmaps and secrets

## Estimated completion time - xx min

intro 

## Goals

* use Kubernetes secrets to override some properties in an ASP.NET Core app's configuration at runtime
* use config map as mounted configuration file

## Task #1 - create Kubernetes Secret and read it as Configuration parameter from the application



```bash
# Create new secret from the file
kubectl create secret generic secret-appsettings --from-file=./appsettings.secrets.json

```

## Task #2 - ConfigMap

```bash
kubectl exec -it lab8-task2-6f7467ff44-nmxb6 -- bash
```

## Useful links

* [Managing ASP.NET Core App Settings on Kubernetes](https://anthonychu.ca/post/aspnet-core-appsettings-secrets-kubernetes/)
* [.NET Configuration in Kubernetes config maps with auto reload](https://medium.com/@fbeltrao/automatically-reload-configuration-changes-based-on-kubernetes-config-maps-in-a-net-d956f8c8399a)
* [.NET Configuration in Kubernetes config maps with auto reload - repo](https://github.com/fbeltrao/ConfigMapFileProvider)
* [Configuration in ASP.NET Core](https://docs.microsoft.com/en-us/aspnet/core/fundamentals/configuration/?view=aspnetcore-5.0)


## Next: name of next lab

[Go to lab-09](../lab-09/readme.md)
