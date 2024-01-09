output "endpoints" {
  value = [
    module.area_get_area_v2.endpoint_gateway_integration,
    module.area_any_area_v2_proxy.endpoint_gateway_integration,
    module.area_post_area_v2.endpoint_gateway_integration,
    module.area_any_v1_area_proxy.endpoint_gateway_integration,
    module.area_get_v1_area.endpoint_gateway_integration,
    module.area_post_v1_area.endpoint_gateway_integration,
    module.area_any_v1_download_tiles_proxy.endpoint_gateway_integration,
    module.area_any_v2_download_tiles_proxy.endpoint_gateway_integration,
  ]
}