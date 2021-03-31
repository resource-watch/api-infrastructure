output "endpoints" {
  value = [
    module.arcgis_proxy_any_v1_arcgis_proxy_proxy.endpoint_gateway_integration,
  ]
}