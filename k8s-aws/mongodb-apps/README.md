# MongoDB for RW API Microservices

[Helm chart for RW API Microservices MongoDB server](https://github.com/helm/charts/tree/master/stable/mongodb-replicaset)

Microservices expects Mongodb version 3.x. This deployment uses version 3.6.16 but any 3.x version should be compatible (do test before deploying).

## Installation

Deployment of the actual MongoDB server is done using the attached file and Helm 3 and the following command:

```shell
helm install mongodb-apps stable/mongodb-replicaset -f mongo-apps-values.yaml --namespace=core
```

This should deploy the configured number of pods (3 in this setting), one per each of the nodes above. You should also double check that the respective `PersistentVolumeClaims` are satisfied, otherwise the database will have no storage and won't start.



## Uninstall

```shell
helm uninstall mongodb-apps --namespace=core
```

## Backup restore

To restore a backup, you need a few things:
- The backup files on your local FS, uncompressed and in a folder. These instructions assume that this folder is called `control-tower`
- You can port forward to the mongodb pod on the cluster

```shell script
kubectl port-forward mongodb-apps-mongodb-replicaset-0 27019:27017 -n core

mongorestore -d <database> --port=27019 --dir=<directory>
```

## Update cluster configuration based from an updated local file

```shell 
helm upgrade mongodb-apps stable/mongodb-replicaset -f mongo-apps-values.yaml --namespace=core 
```