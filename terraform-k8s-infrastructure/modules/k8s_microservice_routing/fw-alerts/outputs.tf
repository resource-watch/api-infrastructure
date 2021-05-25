output "endpoints" {
  value = [
    module.fw_alerts_any_v1_form_proxy.endpoint_gateway_integration,
  ]
}