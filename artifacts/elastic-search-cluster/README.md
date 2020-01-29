# Elasticsearch StatefulSet Data Pod
This directory contains Kubernetes configurations which run elasticsearch data pods as a [`StatefulSet`](https://kubernetes.io/docs/concepts/abstractions/controllers/statefulsets/), using storage provisioned using a [`StorageClass`](http://blog.kubernetes.io/2016/10/dynamic-provisioning-and-storage-in-kubernetes.html). Be sure to read and understand the documentation in the root directory, which deploys the data pods as a `Deployment` using an `emptyDir` for storage.

## Storage
The [`gce-storage-class.yaml`](gce-storage-class.yaml) file creates a `StorageClass` which allocates persistent disks in a google compute engine environment. It should be relatively simple to modify this file to suit your needs for a different environment.

The [`es-data-stateful.yaml`](production/es-data-stateful.yaml) file contains a `volumeClaimTemplates` section which references the `StorageClass` defined in [`gce-storage-class.yaml`](gce-storage-class.yaml), and requests a 12 GB disk. This is plenty of space for a demonstration cluster, but will fill up quickly under moderate to heavy load. Consider modifying the disk size to your needs.

## Deploy
The root directory contains instructions for deploying elasticsearch using a `Deployment` with transient storage for data pods. These brief instructions show a deployment using the `StatefulSet` and `StorageClass`.

```
kubectl create -f es-discovery-svc.yaml
kubectl create -f es-svc.yaml
kubectl create -f es-master.yaml
```

Wait until `es-master` deployment is provisioned, and

```
kubectl create -f es-client.yaml
kubectl create -f es-data-svc.yaml
kubectl create -f es-data-stateful.yaml
```

Kubernetes creates the pods for a `StatefulSet` one at a time, waiting for each to come up before starting the next, so it may take a few minutes for all pods to be provisioned. Refer back to the documentation in the root directory for details on testing the cluster, and configuring a curator job to clean up.


# Backups

## To S3

- Ensure Elasticsearch has the correct [repository](https://www.elastic.co/guide/en/elasticsearch/reference/5.5/modules-snapshots.html) configured. If not, use something like the `curl` request below:

```bash
curl -X PUT \
  http://elasticsearch.default.svc.cluster.local:9200/_snapshot/wri-api-backups/ \
  -d '{
  "type": "s3",
  "settings": {
    "bucket": "wri-api-backups",
    "region": "us-east-1",
    "base_path": "autoelasticbackup"
  }
}'
```

