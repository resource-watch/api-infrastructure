# AWS Kubernetes config for the RW API

This cluster configuration assumes that the AWS resources were provisioned using the terraform configuration included in this repository (or equivalent).

The `boostrap.sh` is a convenience command for getting the cluster up and running, mostly as a way to help get the cluster up to a certain state after creation. It will probably not be useful once the cluster is up and running, and day-to-day maintenance of the cluster is needed.

## Helm

Parts of this infrastructure setup rely on Helm 3, so you need to install that beforehand.

## ALB automatic creation from Ingress objects

See also:
- [ALB Ingress Controller user guide](https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html).
- [ALB Ingress Controller reference docs](https://kubernetes-sigs.github.io/aws-alb-ingress-controller/guide/ingress/annotation)

The included terraform configuration includes certain configuration elements to support the above functionality. Once the cluster is created, the additional commands must be executed to support automatically provisioning ALBs from Ingress objects:

```shell
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/rbac-role.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/alb-ingress-controller.yaml
```

## Certificate management

See also:

- [SSL annotations for ALB Ingress Controller](https://kubernetes-sigs.github.io/aws-alb-ingress-controller/guide/ingress/annotation/#ssl)
- [Why we can't use cert-manager.io](https://github.com/jetstack/cert-manager/issues/333)

SSL certificates are managed through a mix of AWS ACM and AWS ALB Ingress Controller.

Prior to creating the Ingress, you need to add the relevant certificates on AWS ACM, with the corresponding domains.

On the ingress side, you need to specify the following annotations:

```yaml
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS": 443}]'
```

The Ingress should also specify the domains for which it will have HTTPS support.
The ALB Ingress Controller will then match that with the ACM certificates.

You can see logs + debug the process by looking into the pods associated with the `alb-ingress-controller` deployment (`kube-system` namespace).