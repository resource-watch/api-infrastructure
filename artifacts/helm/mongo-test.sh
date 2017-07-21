#! /bin/bash

NS="${RELEASE_NAMESPACE:-default}"
POD_NAME="${RELEASE_NAME:-mongo}-mongodb-replicaset"

for i in $(seq 0 2); do
    pod="${POD_NAME}-$i"
    kubectl exec --namespace $NS $pod -- sh -c 'mongo --eval="printjson(rs.isMaster())"' | grep '"ismaster" : true'

    if [ $? -eq 0 ]; then
        echo "Found master: $pod"
        MASTER=$pod
        break
    fi
done

kubectl exec --namespace $NS $MASTER -- mongo --eval='printjson(db.test.insert({"status": "success"}))'

# TODO: find maximum duration to wait for slaves to be up-to-date with master.
sleep 2

for i in $(seq 0 2); do
    pod="${POD_NAME}-$i"
    if [[ $pod != $MASTER ]]; then
        echo "Reading from slave: $pod"
        kubectl exec --namespace $NS $pod -- mongo --eval='rs.slaveOk(); db.test.find().forEach(printjson)'
    fi
done
