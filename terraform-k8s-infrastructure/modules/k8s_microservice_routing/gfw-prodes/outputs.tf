output "endpoints" {
  value = [
    module.gfw_prodes_loss_any_v1_prodes_loss_proxy.endpoint_gateway_integration,
    module.gfw_prodes_loss_any_v2_prodes_loss_proxy.endpoint_gateway_integration,
  ]
}