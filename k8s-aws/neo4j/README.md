# Neo4j

## Installation

Before deploying the neo4j server, make sure that:
- The `core` namespace has been created.

To install, replace `<neo4j admin password>` in the line below, and run it:

```shell
helm install neo4j -f neo4j.yaml stable/neo4j --set neo4jPassword=<admin password> --namespace=core
```

## Uninstall

```shell
helm uninstall neo4j --namespace=core
```

## Update cluster configuration based from an updated local file

```shell 
helm upgrade neo4j -f neo4j.yaml stable/neo4j --set neo4jPassword=<admin password> --namespace=core
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

It basically deploys Neo4j with `initContainers` - a container that is executed before the "main" Neo4j container. This container will restore the backup from GCP to the PV, and exit. Once it exits, the Neo4J server "main" container starts, with the restored backup already in place.

The restore container has a few env var requirements:

- `REMOTE_BACKUPSET`: GCP path to the folder containing the neo4j backup. Something like `gs://backups-bucket/neo4j/some-date/`
- `GOOGLE_APPLICATION_CREDENTIALS`: Google auth credentials, in JSON format.

As of the date of this writing, the currently deployed `statefulSet` has the initContainer that restores the backup
which should NOT restore a backup if the existing container already has data - hopefully I will have the opportunity to test this soon.

Ideally, we would remove those `initContainers` from the `statefulSet` config.