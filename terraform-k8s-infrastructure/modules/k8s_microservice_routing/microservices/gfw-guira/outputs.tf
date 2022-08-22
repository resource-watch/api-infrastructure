output "endpoints" {
  value = [
    module.gfw_guira_any_v2_guira_loss_proxy.endpoint_gateway_integration,
    module.gfw_guira_get_v2_guira_loss.endpoint_gateway_integration,
    module.gfw_guira_post_v2_guira_loss.endpoint_gateway_integration,
    module.gfw_guira_get_v1_guira_loss.endpoint_gateway_integration,
    module.gfw_guira_any_v1_guira_loss_proxy.endpoint_gateway_integration,
    module.gfw_guira_post_v1_guira_loss.endpoint_gateway_integration,
  ]
}