output "endpoints" {
  value = [
    module.gfw_ogr_any_v1_ogr_proxy.endpoint_gateway_integration,
    module.gfw_ogr_any_v2_ogr_proxy.endpoint_gateway_integration,
  ]
}