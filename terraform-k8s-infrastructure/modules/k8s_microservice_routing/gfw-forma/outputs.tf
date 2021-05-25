output "endpoints" {
  value = [
    module.gfw_forma_any_v1_forma_alerts_proxy.endpoint_gateway_integration,
    module.gfw_forma_get_v1_forma_alerts.endpoint_gateway_integration,
    module.gfw_forma_post_v1_forma_alerts.endpoint_gateway_integration,
  ]
}