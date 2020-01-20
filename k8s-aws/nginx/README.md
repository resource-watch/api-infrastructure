# Deploying nginx reverse proxy 

Start by deploying the nginx configuration `configmaps`

```shell
kubectl create configmap nginx-hosts --from-file=nginx-hosts.configmap.conf
kubectl create configmap nginx-conf --from-file=nginx-config.configmap.conf
```

Next, deploy the service and deployment

```shell
kubectl apply -f nginx.deployment.yaml
kubectl apply -f nginx.service.yaml
```

# Reload nginx configuration

```shell
kubectl delete configmap nginx-hosts

kubectl create configmap nginx-hosts --from-file=nginx-hosts.configmap.conf
```

You may need to destroy the pods after to force reloading of the settings