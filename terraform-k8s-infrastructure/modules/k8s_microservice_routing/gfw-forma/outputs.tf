output "endpoints" {
  value = [
    module.gfw_forma_get_v1_terrai_alerts_admin_iso.endpoint_gateway_integration,
    module.gfw_forma_get_v1_terrai_alerts_admin_iso_id.endpoint_gateway_integration,
    module.gfw_forma_get_v1_terrai_alerts_use_name_id.endpoint_gateway_integration,
    module.gfw_forma_get_v1_terrai_alerts_wdpa_id.endpoint_gateway_integration,
    module.gfw_forma_get_v1_terrai_alerts.endpoint_gateway_integration,
    module.gfw_forma_post_v1_terrai_alerts.endpoint_gateway_integration,
    module.gfw_forma_get_v1_terrai_alerts_latest.endpoint_gateway_integration
  ]
}