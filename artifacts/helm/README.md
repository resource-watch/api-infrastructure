## chaoskube

helm install --name ck stable/chaoskube -f chaoskube-values.yaml

helm install --name mongo stable/mongodb-replicaset -f mongo-replicaset-values.yaml

helm install --name postgres stable/postgresql -f postgres-values.yaml

helm install --name wordpress stable/wordpress -f wordpress-values.yaml

kubectl patch pv <your-pv-name> -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
