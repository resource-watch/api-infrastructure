# Elasticsearch cluster

This directory contains Kubernetes configurations which run an Elasticsearch server cluster. This cluster relies on different [Elasticsearch node types](https://www.elastic.co/guide/en/elasticsearch/reference/5.6/modules-node.html), each deployed to a different pod, and the underlying storage is handled by Kubernetes  [`StatefulSet`](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/).

## Cluster architecture

The cluster is built using Elasticsearch's 3 node types:

- [Master nodes](https://www.elastic.co/guide/en/elasticsearch/reference/5.6/modules-node.html#master-node) defined in `master` folder.
- [Data nodes](https://www.elastic.co/guide/en/elasticsearch/reference/5.6/modules-node.html#data-node) defined in `data` folder.
- [Ingest nodes](https://www.elastic.co/guide/en/elasticsearch/reference/5.6/ingest.html) defined in `ingest` folder.

`Master` and `ingest` nodes are deployed using a regular kubernetes `Deployment` object, while `data` nodes use a `StatefulSet`, as a way to provision consistent and reliable storage along with the pods.

Each of these pod groups has a service. `Master` and `data` nodes rely on [Headless Services](https://dev.to/kaoskater08/building-a-headless-service-in-kubernetes-3bk8), as the service is meant to be used only within the Elasticsearch cluster. The `ingress` pods use a more traditional `Service`, which is the one meant to be used by applications trying to access the cluster. 

It's also worth noting that the `Service` associated with the `master` nodes is also used for internal discovery of Elasticsearch nodes.

## Installation

Before deploying the Elasticsearch cluster, make sure that:
- The `core` namespace has been created.
- The `elasticsearch` secret has been created in the `core` namespace.

Deploying the cluster means deploying the 3 different types of Elasticsearch nodes. Each of these node types is configured in its own folder. Deploying the whole Elasticsearch cluster can be done using the following commands:

```shell
kubectl apply -f data/es-data.statefulset.yaml
kubectl apply -f data/es-data.service.yaml

kubectl apply -f ingest/es-ingest.deployment.yaml
kubectl apply -f ingest/es-ingest.service.yaml

kubectl apply -f master/es-master.deployment.yaml
kubectl apply -f master/es-master.service.yaml
```

## Backups


### Setup

- Ensure Elasticsearch has the correct [repository](https://www.elastic.co/guide/en/elasticsearch/reference/5.5/modules-snapshots.html) configured.

To get a list of the current repositories, issue the following CURL:

```shell script
curl -X GET \
  http://elasticsearch.core.svc.cluster.local:9200/_snapshot/
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
  http://elasticsearch.core.svc.cluster.local:9200/_snapshot/wri-api-backups/ \
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
  http://elasticsearch.core.svc.cluster.local:9200/_snapshot/wri-api-backups/_all
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
  http://elasticsearch.core.svc.cluster.local:9200/_snapshot/wri-api-backups/2020-03-25_11h09m?wait_for_completion=true
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
  http://elasticsearch.core.svc.cluster.local:9200/_snapshot/wri-api-backups/_all
```

To restore the backup, issue the following POST request:

```shell script
curl -X POST \
  http://elasticsearch.core.svc.cluster.local:9200/_snapshot/wri-api-backups/2020-03-25_32h16m/_restore
```

You can confirm your indexes were restored with the following query:

```shell script
curl -X GET http://elasticsearch.core.svc.cluster.local:9200/_cat/indices?pretty
```

You can see your cluster's overall status with the following command:
```shell script
curl -X GET http://elasticsearch.core.svc.cluster.local:9200/_cluster/health?pretty
```

Notice that the cluster status may be yellow, as the shards are being replicated across 
multiple nodes. Your data should be available while this takes place, but it never hurts to wait for full replication to end (status = green) before starting to hammer the elasticsearch server.