output "endpoints" {
  value = [
    module.webshot_any_v1_webshot_proxy.endpoint_gateway_integration,
    module.webshot_get_v1_webshot.endpoint_gateway_integration
  ]
}