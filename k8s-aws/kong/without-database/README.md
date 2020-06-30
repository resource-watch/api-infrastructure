# Kong

We are using Kong as API Gateway.

To install Kong:

```bash
# using YAMLs
$ kubectl apply -f https://bit.ly/k4k8s

# or using Helm
$ helm repo add kong https://charts.konghq.com
$ helm repo update

# Helm 2
$ helm install kong/kong

# Helm 3
$ helm install kong/kong --generate-name --set ingressController.installCRDs=false
```

## JWT plugin

Add the JWT plugin to Kong:

```bash
# Add JWT plugin to Kong
$ kubectl apply -f kong-jwt-plugin.yaml
```

You then need to apply the routing Ingress Controller in order to proxy all the routes correctly:

```bash
# Apply routing Ingress Controller
$ kubectl apply -f kong-ingress.yaml
```
