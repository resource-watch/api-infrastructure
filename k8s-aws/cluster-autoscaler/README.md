# AWS Cluster autoscaler

To allow the cluster to autoscale based on pod pressure (aka: allow AWS ASG to work based on number of pods provisioned), the cluster autoscaler needs to be installed. 

See also: [https://docs.aws.amazon.com/eks/latest/userguide/cluster-autoscaler.html](https://docs.aws.amazon.com/eks/latest/userguide/cluster-autoscaler.html)

```shell script
kubectl apply -f https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml
kubectl -n kube-system annotate deployment.apps/cluster-autoscaler cluster-autoscaler.kubernetes.io/safe-to-evict="false"
```

Next, edit the cluster-autoscaler deployment by running
```shell script
kubectl -n kube-system edit deployment.apps/cluster-autoscaler
```

Edit the cluster-autoscaler container command to replace <YOUR CLUSTER NAME> with your cluster's name, and add the following options.

        - --balance-similar-node-groups
        - --skip-nodes-with-system-pods=false
        
Example: 

```yaml
    spec:
      containers:
      - command:
        - ./cluster-autoscaler
        - --v=4
        - --stderrthreshold=info
        - --cloud-provider=aws
        - --skip-nodes-with-local-storage=false
        - --expander=least-waste
        - --node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/<YOUR CLUSTER NAME>
        - --balance-similar-node-groups
        - --skip-nodes-with-system-pods=false
```

Next, go to [https://github.com/kubernetes/autoscaler/releases](https://github.com/kubernetes/autoscaler/releases) and find the Cluster Autoscaler version that matches the cluster's Kubernetes major and minor version. At the time of this writing, that would be [https://github.com/kubernetes/autoscaler/releases/tag/cluster-autoscaler-1.15.5](https://github.com/kubernetes/autoscaler/releases/tag/cluster-autoscaler-1.15.5)


The last step would be running the command below, replacing the version tag to match the version of the autoscaler above. At the time of this writing, that would be `1.15.5`.
 
```shell script
kubectl -n kube-system set image deployment.apps/cluster-autoscaler cluster-autoscaler=k8s.gcr.io/cluster-autoscaler:v1.15.5
```