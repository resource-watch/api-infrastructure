output "endpoints" {
  value = [
    module.viirs_fires_any_v1_viirs_active_fires_proxy.endpoint_gateway_integration,
    module.viirs_fires_get_v1_viirs_active_fires.endpoint_gateway_integration,
    module.viirs_fires_post_v1_viirs_active_fires.endpoint_gateway_integration,
    module.viirs_fires_any_v2_viirs_active_fires_proxy.endpoint_gateway_integration,
    module.viirs_fires_get_v2_viirs_active_fires.endpoint_gateway_integration,
    module.viirs_fires_post_v2_viirs_active_fires.endpoint_gateway_integration
  ]
}