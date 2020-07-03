# Kong

The installation of Kong can be done using Helm charts. Please check the chart itself to see if there are any additional parameters you might want to customize. The recommended installation method for Kong is using Kubernetes Ingress Controller - [see more here](https://github.com/Kong/kubernetes-ingress-controller#get-started).

To install Kong:

```bash
# or using Helm
$ helm repo add kong https://charts.konghq.com
$ helm repo update

# Using Helm 3
$ helm install kong/kong --generate-name --set ingressController.installCRDs=false --set ingressController.enabled=true --set admin.type=LoadBalancer --set proxy.type=LoadBalancer
```

Note: It is not recommended to expose Kong's admin UI to the world (i.e. `--set admin.type=LoadBalancer`), but it usually is useful for the initial setup. Before rolling out any changes, don't forget to hide the admin UI.

## Configuring routing

Routing configuration should be done using a Kubernetes Ingress Controller. You can check the `ingress.yaml` file as an example, but you should extend it with all the routes and services available in the API.

```bash
# Create Kubernetes Ingress Controller
$ kubectl apply -f ingress.yaml
```

## JWT plugin

In order to use the JWT plugin, you need to first create some Consumers and Credentials:

```bash
# Add consumers and credentials
$ kubectl apply -f kong-consumer-credential.yaml
```

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

For more information, check the [docs for the JWT plugin](https://docs.konghq.com/hub/kong-inc/jwt/), or [this tutorial](https://blog.baeke.info/2019/06/15/api-management-with-kong-ingress-controller-on-kubernetes/) on how to setup authentication in Kong in Kubernetes.
