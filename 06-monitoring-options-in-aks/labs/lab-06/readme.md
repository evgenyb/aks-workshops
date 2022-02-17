# lab-06 - monitoring AKS with Prometheus and Grafana


## Goals

* To get familiar with well known Kubernetes dashboards available in Grafana

## Task #1 - work with different Grafana dashboards for Kubernetes

Open grafana dashboards at `http://localhost:3000/dashboards` and expand `Default` folder.

Open with "play" with the following dashboards: 

* `Kubernetes / Compute Resources / Cluster` 
* `Kubernetes / Compute Resources / Node (Pods)` 
* `Kubernetes / Compute Resources / Namespace (Workloads)` 
* `Kubernetes / Networking / Cluster`
* `Node Exporter / Nodes` 

Note, that you can "navigate" between dashboards. For example if you open `Kubernetes / Compute Resources / Cluster`, find the `CPU Quota` panel and click to `default` namespace, it will open `Kubernetes / Compute Resources / Namespace (Pods)` dashboard filtered by `default` namespace.



## Useful links

* [prometheus-operator/kube-prometheus](https://github.com/prometheus-operator/kube-prometheus.git)

## Next: use Azure Monitor Data Source in Grafana

[Go to lab-07](../lab-07/readme.md)