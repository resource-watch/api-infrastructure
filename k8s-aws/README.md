# AWS Kubernetes config for the RW API

This cluster configuration assumes that the AWS resources were provisioned using the terraform configuration included in this repository (or equivalent). 

The `boostrap.sh` is a convenience command for getting the cluster up and running, mostly as a way to help get the cluster up to a certain state after creation. It will probably not be useful once the cluster is up and running, and day-to-day maintenance of the cluster is needed.


## ALB automatic creation from Ingress objects

See also: [https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html](https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html).

The included terraform configuration includes certain configuration elements to support the above functionality. Once the cluster is created, the additional commands must be executed to support automatically provisioning ALBs from Ingress objects:

```shell
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/rbac-role.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/alb-ingress-controller.yaml
```