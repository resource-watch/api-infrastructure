output "endpoints" {
  value = [
    module.gfw_umd_loss_any_v1_umd_loss_gain_admin_proxy.endpoint_gateway_integration,
    module.gfw_umd_loss_any_v2_umd_loss_proxy.endpoint_gateway_integration,
    module.gfw_umd_loss_any_v3_umd_loss_proxy.endpoint_gateway_integration,
  ]
}