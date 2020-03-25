# PostgreSQL

## Installation

Before deploying the PostgreSQL server, make sure that:
- The `core` namespace has been created.
- The `postgresql` secret has been created in the `core` namespace.
    - `postgres-password` must be defined in the secret.


```shell
helm install postgresql -f postgresql.yaml stable/postgresql --namespace=core
```


## Uninstall

```shell
helm uninstall postgresql --namespace=core
```


## Update cluster configuration based from an updated local file

```shell 
helm upgrade postgresql -f postgresql.yaml stable/postgresql --namespace=core 
```