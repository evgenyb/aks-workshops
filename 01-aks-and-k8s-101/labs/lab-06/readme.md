# lab-06 - Deployments

## Estimated completion time - xx min

Deployments abstract away the low level details of managing Pods. When the node goes away so does the Pod. ReplicaSets can be used to ensure one or more replicas of a Pods are always running.

Deployments sit on top of ReplicaSets and add the ability to define how updates to Pods should be rolled out.

## Goals

In this lab you will learn how to:

* create a Deployment with `kubectl create deployment`
* create a Deployment with yaml definition file
* check the status of Deployment
* scale up and scale down the Deployment 
* delete Deployment

## Task #1 - configure your lab environment

As with `lab-05`, split your terminal in two. At the right-hand window, run `kubectl get po -w` command and at the left-hand window execute labs commands.

## Task #2 - deploy our app with the `kubectl create deployment` command

```bash
# Let’s deploy our app with the `kubectl create deployment` command
kubectl create deployment lab6-task2 --image=iacaksws1<YOUR-NAME>acr.azurecr.io/apia:v1

# To list your deployments use the `get deployments` command
kubectl get deployments
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
lab6-task2   1/1     1            1           6m19s

# Get lab6-task2 deployment expanded (aka "wide") output
kubectl get deployment lab6-task2 -o wide
NAME         READY   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS   IMAGES                               SELECTOR
lab6-task2   1/1     1            1           6m58s   apia         iacaksws1evgacr.azurecr.io/apia:v5   app=lab6-task2

# Get lab6-task2 deployment yaml definition
kubectl get deployment lab6-task2 -o yaml

# Get pods created by deployment
kubectl get po | grep lab-06
lab6-task2-9d58f9659-ksr5g   1/1     Running            0          12m

# Get pods with specified labels
kubectl get po -l app=lab6-task2
NAME                         READY   STATUS    RESTARTS   AGE
lab6-task2-9d58f9659-ksr5g   1/1     Running   0          14m
```

## Task #3 - deploy our app using yaml definition file

Create new `lab6-task3-deployment.yaml` file with the following content

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: lab6-task3
  labels:
    app: lab6-task3
spec:
  replicas: 3
  selector:
    matchLabels:
      app: lab6-task3
  template:
    metadata:
      labels:
        app: lab6-task3
    spec:
      containers:
      - name: api
        image: iacaksws1<YOUR-NAME>acr.azurecr.io/apia:v1
        imagePullPolicy: IfNotPresent
        resources: {}
        livenessProbe:
          httpGet:
            path: /health
            port: 80
          initialDelaySeconds: 3
          periodSeconds: 3    
        readinessProbe:
          httpGet:
            path: /readiness
            port: 80
          initialDelaySeconds: 3
          periodSeconds: 3
```

In this definition:

* A Deployment named `lab6-task3-deployment` is created, specified by the `metadata.name` field.
* The Deployment creates three replicated Pods, specified by the `.spec.replicas` field.
* The `.spec.selector` field defines how the Deployment finds which Pods to manage. In our case, we simply select a label that is defined in the Pod template (`app: lab6-task3`). 
* The `template` field contains the following sub-fields:
    * The Pods are labeled `app: lab6-task3` using the `.metadata.labels` field
* The `.spec.containers` section is copied from the `.spec.containers` section of `Lab-04 Task #4` pod definition

Now let's deploy it 

```bash
# Deploy lab6-task3-deployment.yaml
kubectl apply -f .\lab6-task3-deployment.yaml

# kubectl get deployments
kubectl get deployments lab6-task3
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
lab6-task3   3/3     3            3           3m5s
```
When you inspect the Deployments in your cluster, the following fields are displayed:

* `READY` displays how many replicas of the application are available to your users. It follows the pattern ready/desired
* `UP-TO-DATE` displays the number of replicas that have been updated to achieve the desired state
* `AVAILABLE` displays how many replicas of the application are available to your users
* `AGE` displays how long application has been running

Notice how the number of desired replicas is 3 according to `.spec.replicas` field.

To see the labels automatically generated for each Pod, run `get pods`  with `--show-labels`. The output is similar to:

```bash
kubectl get po --show-labels | grep lab6-task3
lab6-task3-59b9fcb587-79dmg   1/1     Running            0          5m46s   app=lab6-task3,pod-template-hash=59b9fcb587
lab6-task3-59b9fcb587-9vlsk   1/1     Running            0          5m46s   app=lab6-task3,pod-template-hash=59b9fcb587
lab6-task3-59b9fcb587-cjd6x   1/1     Running            0          5m46s   app=lab6-task3,pod-template-hash=59b9fcb587
```



## Useful links

* [Using kubectl to Create a Deployment](https://kubernetes.io/docs/tutorials/kubernetes-basics/deploy-app/deploy-intro/)
* [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
* [ReplicaSet](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/)
* [kubectl create deployment](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#-em-deployment-em-)
* [Labels and Selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/)

## Next: Creating and Managing Services

[Go to lab-07](../lab-07/readme.md)

