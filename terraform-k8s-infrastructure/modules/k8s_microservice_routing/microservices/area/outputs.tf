output "endpoints" {
  value = [
    module.area_get_area_v2.endpoint_gateway_integration,
    module.area_get_area_v2_id.endpoint_gateway_integration,
    module.area_post_area_v2_sync.endpoint_gateway_integration,
    module.area_post_area_v2.endpoint_gateway_integration,
    module.area_patch_area_v2_id.endpoint_gateway_integration,
    module.area_post_area_v2_update.endpoint_gateway_integration,
    module.area_delete_area_v2_id.endpoint_gateway_integration,
    module.area_get_area_v2_download_tiles_geostore_id_min_zoom_max_zoom.endpoint_gateway_integration,
    module.area_get_area_v1.endpoint_gateway_integration,
    module.area_get_area_v1_fw.endpoint_gateway_integration,
    module.area_get_area_v1_fw_id.endpoint_gateway_integration,
    module.area_get_area_v1_id.endpoint_gateway_integration,
    module.area_post_area_v1.endpoint_gateway_integration,
    module.area_post_area_v1_fw_id.endpoint_gateway_integration,
    module.area_patch_area_v1_id.endpoint_gateway_integration,
    module.area_delete_area_v1_id.endpoint_gateway_integration,
    module.area_get_area_v1_id_alerts.endpoint_gateway_integration,
    module.area_get_area_v1_download_tiles_geostore_id_min_zoom_max_zoom.endpoint_gateway_integration
  ]
}