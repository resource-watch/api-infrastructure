## chaoskube

helm install --name ck stable/chaoskube -f chaoskube-values.yaml

helm install --name mongo stable/mongodb-replicaset -f mongo-replicaset-values.yaml

helm install --name postgres stable/postgresql -f postgres-values.yaml
