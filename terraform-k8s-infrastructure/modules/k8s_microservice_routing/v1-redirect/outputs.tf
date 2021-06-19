output "endpoints" {
  value = [
    aws_api_gateway_integration.v1_redirect_proxy_integration,
  ]
}