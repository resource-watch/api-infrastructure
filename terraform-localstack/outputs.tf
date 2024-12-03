output "api_gateway_id" {
  value = aws_api_gateway_rest_api.rw_api_gateway.id
}

output "access_url" {
  value = "http://host.docker.internal:4566/restapis/${aws_api_gateway_rest_api.rw_api_gateway.id}/prod/_user_request_"
}
