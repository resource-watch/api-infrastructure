sed -e 's/shardX/shard1/g; s/ShardX/Shard1/g' ./mongodb-maindb-service.yaml > /tmp/mongodb-maindb-service.yaml
kubectl apply -f /tmp/mongodb-maindb-service.yaml
sed -e 's/shardX/shard2/g; s/ShardX/Shard2/g' ./mongodb-maindb-service.yaml > /tmp/mongodb-maindb-service.yaml
kubectl apply -f /tmp/mongodb-maindb-service.yaml
sed -e 's/shardX/shard3/g; s/ShardX/Shard3/g' ./mongodb-maindb-service.yaml > /tmp/mongodb-maindb-service.yaml
kubectl apply -f /tmp/mongodb-maindb-service.yaml
rm /tmp/mongodb-maindb-service.yaml
