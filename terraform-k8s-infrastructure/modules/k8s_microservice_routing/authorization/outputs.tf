output "endpoints" {
  value = [
    module.authorization_get.endpoint_gateway_integration,
    module.authorization_any_proxy.endpoint_gateway_integration
  ]
}