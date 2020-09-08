# AWS Kubernetes config for the RW API

This cluster configuration assumes that the AWS resources were provisioned using the terraform configuration included in this repository (or equivalent).


## Helm

Parts of this infrastructure setup rely on Helm 3, so you need to install that beforehand.

## ALB automatic creation from Ingress objects



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

## DNS

Don't forget to add DNS entries that point the ALB containers to the correct name servers.
