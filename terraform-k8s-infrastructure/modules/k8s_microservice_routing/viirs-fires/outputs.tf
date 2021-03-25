output "endpoints" {
  value = [
    module.viirs_fires_v1_get_active_fires.endpoint_gateway_integration,
    module.viirs_fires_v1_get_by_area.endpoint_gateway_integration,
    module.viirs_fires_v1_set_active_fires.endpoint_gateway_integration,
    module.viirs_fires_v1_get_wdpa.endpoint_gateway_integration,
    module.viirs_fires_v1_get_latest_fires.endpoint_gateway_integration,
    module.viirs_fires_v1_get_by_iso.endpoint_gateway_integration,
    module.viirs_fires_v1_get_by_id2.endpoint_gateway_integration,
    module.viirs_fires_v1_get_by_id1.endpoint_gateway_integration,
    module.viirs_fires_v2_set_active_fires.endpoint_gateway_integration,
    module.viirs_fires_v2_get_wdpa.endpoint_gateway_integration,
    module.viirs_fires_v2_get_latest_fires.endpoint_gateway_integration,
    module.viirs_fires_v2_get_by_iso.endpoint_gateway_integration,
    module.viirs_fires_v2_get_by_id2.endpoint_gateway_integration,
    module.viirs_fires_v2_get_by_id1.endpoint_gateway_integration,
    module.viirs_fires_v2_get_by_area.endpoint_gateway_integration,
    module.viirs_fires_v2_get_active_fires.endpoint_gateway_integration,
  ]
}