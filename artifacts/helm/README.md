## Install things

helm install --name ck stable/chaoskube -f chaoskube-values.yaml

helm install --name mongo stable/mongodb-replicaset -f mongo-replicaset-values.yaml

helm install --name postgres stable/postgresql -f postgres-values.yaml

helm install --name wordpress stable/wordpress -f wordpress-values.yaml

kubectl patch pv <your-pv-name> -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'



## Update things

First update your charts (templates) from upstream

```
helm repo update
``` 

Then change whatever files you want locally

Finally run something like the line below, which will update both the chart and the values

```
helm upgrade mongo-rs-gateway -f artifacts/helm/mongo-gateway-values.yaml stable/mongodb-replicaset
```