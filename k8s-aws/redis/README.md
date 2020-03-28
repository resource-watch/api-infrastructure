# Redis

## Installation

Before deploying the Redis server, make sure that:
- The `core` namespace has been created.
- The `postgresql` secret has been created in the `core` namespace.
    - `postgres-password` must be defined in the secret.


```shell
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install redis  -f redis.yaml bitnami/redis --namespace=core
```


## Uninstall

```shell
helm uninstall redis --namespace=core
```


## Update cluster configuration based from an updated local file

```shell 
helm upgrade redis -f redis.yaml bitnami/redis --namespace=core 
```