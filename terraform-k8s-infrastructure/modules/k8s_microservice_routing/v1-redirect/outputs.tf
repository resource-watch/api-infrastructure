#output "endpoints" {
#  value = [
#    aws_api_gateway_integration.v1_redirect_proxy_integration,
#  ]
#}

output "aws_api_gateway_resource" {
  value = module.v1_redirect_proxy_resource.aws_api_gateway_resource
}

output "aws_api_gateway_method" {
  value = aws_api_gateway_method.v1_redirect_proxy_method
}