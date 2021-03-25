output "aws_api_gateway_rest_api" {
  value = aws_api_gateway_rest_api.aws_api_gateway_rest_api
}

output "aws_api_gateway_deployment_base_url" {
  value = trimsuffix(aws_api_gateway_deployment.prod.invoke_url, "/prod")
}