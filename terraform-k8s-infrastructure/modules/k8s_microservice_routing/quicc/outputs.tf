output "endpoints" {
  value = [
    module.quicc_any_v1_quicc_alerts_proxy.endpoint_gateway_integration,
    module.quicc_get_v1_quicc_alerts.endpoint_gateway_integration,
  ]
}