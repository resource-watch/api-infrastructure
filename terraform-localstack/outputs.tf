output "api_gateway_id" {
  value = aws_api_gateway_rest_api.rw_api_gateway.id
}

output "access_url" {
  value = "http://${aws_api_gateway_rest_api.rw_api_gateway.id}.execute-api.localhost.localstack.cloud:4566/prod/"
}
