# MongoDB for Control Tower API Gateway

Control Tower expects Mongodb version 3.x. This deployment uses version 3.6.16 but any 3.x version should be compatible (do test before deploying).

While not required, we recommend setting aside a dedicated set of nodes for this database. To do so, you can use [Kubernetes taints and tolerations](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/). Specifically, you can run the command below to flag nodes as NOT being available for scheduling pods. Our deployment will then include specific logic that allows it to bypass this, ensuring only these MongoDB pods are scheduled on these nodes.
```shell
kubectl taint nodes <mongodb gateway node ids> type=mongodb-gateway:NoSchedule
```

Deployment of the actual MongoDB server is done using the attached file and Helm 3 and the following command:
```shell
helm install mongodb-gateway stable/mongodb-replicaset -f mongo-gateway-values.yaml 
```

This should deploy the configured number of pods (3 in this setting), one per each of the nodes above. You should also double check that the respective `PersistentVolumeClaims` are satisfied, otherwise the database will have no storage and won't start.

