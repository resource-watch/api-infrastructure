output "endpoints" {
  value = [
    module.imazon_any_v1_imazon_alerts_proxy.endpoint_gateway_integration,
    module.imazon_post_v1_imazon_alerts.endpoint_gateway_integration,
    module.imazon_get_v1_imazon_alerts.endpoint_gateway_integration,
    module.imazon_any_v2_imazon_alerts_proxy.endpoint_gateway_integration,
    module.imazon_post_v2_imazon_alerts.endpoint_gateway_integration,
    module.imazon_get_v2_imazon_alerts.endpoint_gateway_integration,
  ]
}