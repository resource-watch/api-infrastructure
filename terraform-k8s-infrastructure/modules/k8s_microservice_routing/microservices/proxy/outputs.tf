output "endpoints" {
  value = [
    module.gee_tiles_any_proxy_v1_proxy_proxy.endpoint_gateway_integration,
  ]
}