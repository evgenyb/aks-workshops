# lab-06 - Deployments

## Estimated completion time - xx min

A Deployment provides declarative updates for Pods and ReplicaSets. Deployments abstract away the low level details of managing Pods. 
Deployments sit on top of ReplicaSets and add the ability to define how updates to Pods should be rolled out. 
You describe a desired state in a Deployment, and the Deployment Controller changes the actual state to the desired state at a controlled rate. You can define Deployments to create new ReplicaSets, or to remove existing Deployments and adopt all their resources with new Deployments.

## Goals

In this lab you will learn how to:

* create a Deployment with `kubectl create deployment`
* create a Deployment with yaml definition file
* check the status of Deployment
* scale up and scale down the Deployment 
* delete Deployment

## Task #1 - prepare your lab environment

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

To see the labels automatically generated for each Pod, run `get pods`  with `--show-labels`. The output is similar to:

```bash
kubectl get po --show-labels | grep lab6-task3
lab6-task3-59b9fcb587-79dmg   1/1     Running            0          5m46s   app=lab6-task3,pod-template-hash=59b9fcb587
lab6-task3-59b9fcb587-9vlsk   1/1     Running            0          5m46s   app=lab6-task3,pod-template-hash=59b9fcb587
lab6-task3-59b9fcb587-cjd6x   1/1     Running            0          5m46s   app=lab6-task3,pod-template-hash=59b9fcb587
```

## Task #4 - Updating a Deployment

To work with Deployment update task, we need some extra version of our application images in ACR. Let's push 3 more versions. 

```bash
# Navigate to `01-aks-and-k8s-101\app\api-a` folder

# Push version v6
az acr build --registry iacaksws1<YOU-NAME>acr --image apia:v6 --file Dockerfile ..

# Push version v7
az acr build --registry iacaksws1<YOU-NAME>acr --image apia:v7 --file Dockerfile ..

# Push version v8
az acr build --registry iacaksws1<YOU-NAME>acr --image apia:v7 --file Dockerfile ..
```

A Deployment's rollout is only triggered if Pod's template `.spec.template` is changed. 

```bash
# Let's update the api container and use the apia:v6 image instead of the apia:v1 image
kubectl set image deployment/lab6-task3 api=iacaksws1evgacr.azurecr.io/apia:v6 --record

# To see the Deployment rollout status, run
kubectl rollout status deployment/lab6-task3
Waiting for deployment "lab6-task3" rollout to finish: 1 out of 3 new replicas have been updated...
Waiting for deployment "lab6-task3" rollout to finish: 1 out of 3 new replicas have been updated...
Waiting for deployment "lab6-task3" rollout to finish: 1 out of 3 new replicas have been updated...
Waiting for deployment "lab6-task3" rollout to finish: 2 out of 3 new replicas have been updated...
Waiting for deployment "lab6-task3" rollout to finish: 2 out of 3 new replicas have been updated...
Waiting for deployment "lab6-task3" rollout to finish: 2 out of 3 new replicas have been updated...
Waiting for deployment "lab6-task3" rollout to finish: 1 old replicas are pending termination...
Waiting for deployment "lab6-task3" rollout to finish: 1 old replicas are pending termination...
deployment "lab6-task3" successfully rolled out
```

You can also update Deployment by editing yaml file. Open `lab6-task3-deployment.yaml` file and change image from `apia:v1` to `apia:v7` and deploy it with `kubectl apply `

```bash
# Deploy updated version of lab6-task3-deployment.yaml Deployment
kubectl apply -f .\lab6-task3-deployment.yaml

# To see the Deployment rollout status, run
kubectl rollout status deployment/lab6-task3
Waiting for deployment "lab6-task3" rollout to finish: 1 out of 3 new replicas have been updated...
Waiting for deployment "lab6-task3" rollout to finish: 1 out of 3 new replicas have been updated...
Waiting for deployment "lab6-task3" rollout to finish: 1 out of 3 new replicas have been updated...
Waiting for deployment "lab6-task3" rollout to finish: 2 out of 3 new replicas have been updated...
Waiting for deployment "lab6-task3" rollout to finish: 2 out of 3 new replicas have been updated...
Waiting for deployment "lab6-task3" rollout to finish: 2 out of 3 new replicas have been updated...
Waiting for deployment "lab6-task3" rollout to finish: 1 old replicas are pending termination...
Waiting for deployment "lab6-task3" rollout to finish: 1 old replicas are pending termination...
deployment "lab6-task3" successfully rolled out
```

Alternatively, you can edit the Deployment with `kubectl edit deployment` command

```bash
# Edit lab6-task3 Deployment
kubectl edit deployment lab6-task3
```
Depending what shell and environment you are using, the default editor for your environment will be opened (in Windows it's notepad, in Ubuntu it's vi, ect...)
Edit Deployment definition, change change image from `apia:v7` to `apia:v8`, Save the file and close the editor. The output will be similar to this:

```bash
deployment.apps/lab6-task3 edited

# Check  Deployment rollout status
kubectl rollout status deployment/lab6-task3
Waiting for deployment "lab6-task3" rollout to finish: 2 out of 3 new replicas have been updated...
Waiting for deployment "lab6-task3" rollout to finish: 2 out of 3 new replicas have been updated...
Waiting for deployment "lab6-task3" rollout to finish: 2 out of 3 new replicas have been updated...
Waiting for deployment "lab6-task3" rollout to finish: 1 old replicas are pending termination...
Waiting for deployment "lab6-task3" rollout to finish: 1 old replicas are pending termination...
deployment "lab6-task3" successfully rolled out
```

## Task #5 - scaling up and scaling down a Deployment

You can scale a Deployment by running the following command:

```bash
# Scale lab6-task3 Deployment up to 6 replicas
kubectl scale deployment lab6-task3 --replicas=6
deployment.apps/lab6-task3 scaled

# Check Deployment status
kubectl get deployment lab6-task3
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
lab6-task3   6/6     6            6           55m

# Scale lab6-task3 Deployment down to 2 replicas
kubectl scale deployment lab6-task3 --replicas=2
deployment.apps/lab6-task3 scaled

# Check Deployment status
kubectl get deployment lab6-task3
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
lab6-task3   2/2     2            2           57m
```

You can also scale Deployment down to zero

```bash
# Scale lab6-task3 Deployment down to 2 replicas
kubectl scale deployment lab6-task3 --replicas=0
deployment.apps/lab6-task3 scaled

# Check Deployment status
kubectl get deployment lab6-task3
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
lab6-task3   0/0     0            0           58m
```

## Task #6 - delete a Deployment

You can remove your Deployment using the `kubectl delete deployment` command

```bash
# Delete Deployment lab6-task3
kubectl delete deployment lab6-task3
deployment.apps "lab6-task3" deleted
```

## Useful links

* [Using kubectl to Create a Deployment](https://kubernetes.io/docs/tutorials/kubernetes-basics/deploy-app/deploy-intro/)
* [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
* [ReplicaSet](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/)
* [kubectl create deployment](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#-em-deployment-em-)
* [Labels and Selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/)

## Next: Creating and Managing Services

[Go to lab-07](../lab-07/readme.md)

