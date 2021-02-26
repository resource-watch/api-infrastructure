output "endpoints" {
  value = [
    module.forest_change_get_v1_terrai_alerts.endpoint_gateway_integration,
    module.forest_change_post_v1_terrai_alerts.endpoint_gateway_integration,
    module.forest_change_get_v1_terrai_alerts_admin_iso_code.endpoint_gateway_integration,
    module.forest_change_get_v1_terrai_alerts_admin_iso_code_admin_id.endpoint_gateway_integration,
    module.forest_change_get_v1_terrai_alerts_admin_iso_code_admin_dist_id_id.endpoint_gateway_integration,
    module.forest_change_get_v1_terrai_alerts_use_type_use_id.endpoint_gateway_integration,
    module.forest_change_get_v1_terrai_alerts_wdpa_id.endpoint_gateway_integration,
    module.forest_change_get_v1_terrai_alerts_date_range.endpoint_gateway_integration,
    module.forest_change_get_v1_terrai_alerts_latest.endpoint_gateway_integration
  ]
}