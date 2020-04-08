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



## Backups


### Setup

- Ensure Elasticsearch has the correct [repository](https://www.elastic.co/guide/en/elasticsearch/reference/5.5/modules-snapshots.html) configured.

To get a list of the current repositories, issue the following CURL:

```shell script
curl -X GET \
  http://elasticsearch.default.svc.cluster.local:9200/_snapshot/
```

You should get something like:

```json
{
  "wri-api-backups": {
    "type": "s3",
    "settings": {
      "bucket": "wri-api-backups",
      "region": "us-east-1",
      "base_path": "autoelasticbackup"
    }
  }
}
```

If no repositories are returned, you can register one using:

```shell script
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

Next you want to get a list of snapshots from your repository:

```shell script
curl -X GET \
  http://elasticsearch.default.svc.cluster.local:9200/_snapshot/wri-api-backups/_all
```

You'll get something like:

```json
{
  "snapshots": [
    {
      "snapshot": "2019-05-02_12h16m",
      "uuid": "4T1Jh6_JSSOSRHFCri0o1g",
      "version_id": 5050099,
      "version": "5.5.0",
      "indices": [
        <list of indexes>
      ],
      "state": "SUCCESS",
      "start_time": "2019-05-02T12:16:01.764Z",
      "start_time_in_millis": 1556799361764,
      "end_time": "2019-05-02T14:36:35.289Z",
      "end_time_in_millis": 1556807795289,
      "duration_in_millis": 8433525,
      "failures": [],
      "shards": {
        "total": 4411,
        "failed": 0,
        "successful": 4411
      }
    },
    {
      "snapshot": "2019-05-14_10h04m",
      "uuid": "iKKuZecrQWOZ7DIf5ovPXQ",
      "version_id": 5050099,
      "version": "5.5.0",
      "indices": [
        <list of indexes>
      ],
      "state": "SUCCESS",
      "start_time": "2019-06-27T07:02:30.211Z",
      "start_time_in_millis": 1561618950211,
      "end_time": "2019-06-27T07:11:43.312Z",
      "end_time_in_millis": 1561619503312,
      "duration_in_millis": 553101,
      "failures": [],
      "shards": {
        "total": 1391,
        "failed": 0,
        "successful": 1391
      }
    }
  ]
}
```


### Create a backup

To start a backup, use:

```shell script
curl -X PUT \
  http://elasticsearch.default.svc.cluster.local:9200/_snapshot/wri-api-backups/2020-04-08_09h11m?wait_for_completion=true
```

The backup will take a few minutes to be processed, after which you will get a JSON response like so:

```json
{
  "snapshot": {
    "snapshot": "2020-03-25_32h16m",
    "uuid": "avGC3m6hR2uqxw0rv6XDyA",
    "version_id": 5050099,
    "version": "5.5.0",
    "indices": [
        <list of indexes>
    ],
    "state": "SUCCESS",
    "start_time": "2020-03-25T12:16:54.992Z",
    "start_time_in_millis": 1585138614992,
    "end_time": "2020-03-25T12:23:54.696Z",
    "end_time_in_millis": 1585139034696,
    "duration_in_millis": 419704,
    "failures": [],
    "shards": {
      "total": 3989,
      "failed": 0,
      "successful": 3989
    }
  }
}
```

### Restore a backup

To restore a backup (snapshot) you first need to find out exactly which snapshot you want to restore. You can list all available snapshots for a repository using the following command:

```shell script
curl -X GET \
  http://elasticsearch.default.svc.cluster.local:9200/_snapshot/wri-api-backups/_all
```

To restore the backup, issue the following POST request:

```shell script
curl -X POST \
  http://elasticsearch.default.svc.cluster.local:9200/_snapshot/wri-api-backups/2020-03-25_32h16m/_restore
```

You can confirm your indexes were restored with the following query:

```shell script
curl -X GET http://elasticsearch.default.svc.cluster.local:9200/_cat/indices?pretty
```

You can see your cluster's overall status with the following command:
```shell script
curl -X GET http://elasticsearch.default.svc.cluster.local:9200/_cluster/health?pretty
```

Notice that the cluster status may be yellow, as the shards are being replicated across multiple nodes. Your data should be available while this takes place, but it never hurts to wait for full replication to end (status = green) before starting to hammer the elasticsearch server.