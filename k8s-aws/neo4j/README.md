# Neo4j

## Installation

Before deploying the neo4j server, make sure that:
- The `core` namespace has been created.
- The `neo4j` secret has been created in the `core` namespace.
    - `NEO4J_PASSWORD` must be defined in the secret.

To install, run the following commands:

```shell
kubectl apply -f neo4j.service.yaml
kubectl apply -f neo4j.statefulset.yaml
```

## Port forwarding


### Bolt protocol

```shell
kubectl port-forward svc/neo4j-neo4j -n core 7687:7687
```

### HTTP protocol

```shell
kubectl port-forward svc/neo4j-neo4j -n core 7474:7474
```


## Loading backups

Restoring backups on Neo4j on k8s can be tricky
- To restore a backup, you need the `neo4j-admin` CLI tool.
- You also need the Neo4j server to be stopped.
- However, if you stop the server, the container will stop, and k8s will replace it

To work around this, the `restore` folder has a custom deployment using `initContainers`.
This approach is based on [this link](https://medium.com/google-cloud/how-to-restore-neo4j-backups-on-kubernetes-and-gke-6841aa1e3961), with minor modifications
to support the current infrastructure, and all assets have been migrated to this repo, for auditability.

It basically deploys Neo4j with `initContainers` - a container that is executed before the "main" Neo4j container. This container will restore the backup from AWS S3 to the PV, and exit. Once it exits, the Neo4J server "main" container starts, with the restored backup already in place.

The restore container has a few env var requirements:

- `REMOTE_BACKUPSET`: S3 path to the folder containing the neo4j backup. Something like `s3://backups/neo4j/graph.db-backup-2020-01-01/`

Once the secrets are set, you can trigger the restore by deploying the specially crafted neo4j `statefulset`:

```shell
kubectl apply -f restore/neo4j-restore.service.yaml
kubectl apply -f restore/neo4j-restore.statefulset.yaml
```

You can check the backup restore logs using the following command:

```shell
kubectl logs -f neo4j-neo4j-core-0 -n core -c restore-from-file
```

Once the restore process is done, you should reconfigure the statefulset to stop using the initcontainer:

```shell
kubectl apply -f neo4j.statefulset.yaml
```

You may need to manually destroy the pod for this change to be picked up.

## Reference files

The service and statefulset files included are based on the `stable/neo4j` helm chart, with the necessary changes to have neo4j work in single server mode, as opposed to cluster.
The helm config files are still included, for reference, but you should not apply them directly, as they will create a non-functioning cluster.