# Using localstack

In local development, we use localstack to emulate API Gateway functionality of routing requests across the various microservices (by matching request path pattern). To get localstack running and provision it with the API Gateway resources:

1 - Run localstack locally.

```bash
docker run --rm -it -p 4566:4566 localstack/localstack:4.0.3
```

2 - Terraform apply the content of this folder and confirm the changes in the prompt (use terraform version `v1.3.6`). This will output an `access_url` of the form `http://host.docker.internal:4566/_aws/execute-api/{gateway_id}/prod`. If you choose to use a different port in Step 1, update the access_url variable in outputs.tf to reflect the chosen port..
```bash
terraform apply
```

3 - In the microservice repo, set `GATEWAY_URL` variable where it's defined (in `docker-compose-develop` or `dev.env` file) to the `access_url` value from above step and you're all set - requests can now be routed across microservices via the Gateway. Note that as the microservice ports are hardcoded (see `../terraform-k8s-infrastructure/modules/k8s_microservice_routing/microservices/dataset`, for example), need to make sure the local dev container ports match those defined in terraform.