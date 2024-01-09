output "endpoints" {
  value = [
    module.subscriptions_any_v1_subscriptions_proxy.endpoint_gateway_integration,
    module.subscriptions_get_v1_subscriptions.endpoint_gateway_integration,
    module.subscriptions_post_v1_subscriptions.endpoint_gateway_integration
  ]
}