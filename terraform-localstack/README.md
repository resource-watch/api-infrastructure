# Using localstack

1 - Run localstack locally

```bash
docker run --rm -it -p 4566:4566 -p 4571:4571 localstack/localstack
```

2 - Terraform apply the content of this folder

3 - Start microservices with the following GATEWAY_URL:

```
https://<api gateway id>.execute-api.localhost.localstack.cloud:4566/prod
```