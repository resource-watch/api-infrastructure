output "endpoints" {
  value = [
    module.gfw_user_any_v1_user_proxy.endpoint_gateway_integration,
    module.gfw_user_get_v1_user.endpoint_gateway_integration,
    module.gfw_user_post_v1_user.endpoint_gateway_integration,
  ]
}