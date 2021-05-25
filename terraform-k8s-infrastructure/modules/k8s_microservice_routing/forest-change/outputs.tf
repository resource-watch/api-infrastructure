output "endpoints" {
  value = [
    module.forest_change_get_v1_terrai_alerts.endpoint_gateway_integration,
    module.forest_change_post_v1_terrai_alerts.endpoint_gateway_integration,
    module.forest_change_any_v1_terrai_alerts_admin_iso_code.endpoint_gateway_integration,
  ]
}