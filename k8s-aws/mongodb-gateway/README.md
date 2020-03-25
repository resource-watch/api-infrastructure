# MongoDB for Control Tower API Gateway

[Helm chart for CT MongoDB server](https://github.com/helm/charts/tree/master/stable/mongodb-replicaset)

Control Tower expects Mongodb version 3.x. This deployment uses version 3.6.16 but any 3.x version should be compatible (do test before deploying).

## Installation

While not required, we recommend setting aside a dedicated set of nodes for this database. To do so, you can use [Kubernetes taints and tolerations](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/). Specifically, you can run the command below to flag nodes as NOT being available for scheduling pods. Our deployment will then include specific logic that allows it to bypass this, ensuring only these MongoDB pods are scheduled on these nodes.

```shell
kubectl taint nodes <mongodb gateway node ids> type=mongodb-gateway:NoSchedule
```

Deployment of the actual MongoDB server is done using the attached file and Helm 3 and the following command:

```shell
helm install mongodb-gateway stable/mongodb-replicaset -f mongo-gateway-values.yaml --namespace=gateway
```

This should deploy the configured number of pods (3 in this setting), one per each of the nodes above. You should also double check that the respective `PersistentVolumeClaims` are satisfied, otherwise the database will have no storage and won't start.



## Uninstall

```shell
helm uninstall mongodb-gateway --namespace=gateway
```


## User access configuration

Control Tower assumes a `control-tower` user on the `control-tower` database. To set up this requirement, connect to the MongoDB cluster, and run the following commands:

```shell
use control-tower

db.createUser({
    user: "control-tower",
    pwd: "<plain text password>",
    roles: [
      { role: "readWrite", db: "control-tower" },
    ]
})
```

## Backup restore

To restore a backup, you need a few things:
- The backup files on your local FS, uncompressed and in a folder. These instructions assume that this folder is called `control-tower`
- You can port forward to the mongodb pod on the cluster

```shell script
kubectl port-forward mongo-mongodb-replicaset-1 27019:27017

mongorestore -d control-tower --port=27019 --dir=control-tower --username=control-tower --password=<password>
```
