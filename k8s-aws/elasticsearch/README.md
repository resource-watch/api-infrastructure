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

### To S3

- Ensure Elasticsearch has the correct [repository](https://www.elastic.co/guide/en/elasticsearch/reference/5.5/modules-snapshots.html) configured. If not, use something like the `curl` request below:

```bash
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

