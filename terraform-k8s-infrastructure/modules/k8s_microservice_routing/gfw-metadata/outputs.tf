output "endpoints" {
  value = [
    aws_api_gateway_integration.gfw_metadata_proxy_integration,
  ]
}