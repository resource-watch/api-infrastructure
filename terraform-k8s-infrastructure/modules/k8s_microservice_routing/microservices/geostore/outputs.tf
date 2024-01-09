output "endpoints" {
  value = [
    module.geostore_post_v1_geostore.endpoint_gateway_integration,
    module.geostore_any_v1_coverage_proxy.endpoint_gateway_integration,
    module.geostore_any_v1_geostore_proxy.endpoint_gateway_integration,
    module.geostore_post_v2_geostore.endpoint_gateway_integration,
    module.geostore_any_v2_coverage_proxy.endpoint_gateway_integration,
    module.geostore_any_v2_geostore_proxy.endpoint_gateway_integration,
  ]
}