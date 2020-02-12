# RabbitMQ

## Installation

Before deploying the RabbitMQ server, make sure that:
- The `core` namespace has been created.
- The `rabbitmq-passwords` secret has been created in the `core` namespace.
    - `rabbitmq-erlang-cookie` and `rabbitmq-password` must be defined in the secret.


```shell
helm install rabbitmq -f rabbitmq.yaml stable/rabbitmq --namespace=core
```

## Uninstall

```shell
helm uninstall rabbitmq --namespace=core
```

## Update cluster configuration based from an updated local file

```shell 
helm upgrade rabbitmq -f rabbitmq.yaml stable/rabbitmq --namespace=core 
```