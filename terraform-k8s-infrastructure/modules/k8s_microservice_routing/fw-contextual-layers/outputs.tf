output "endpoints" {
  value = [
    module.fw_contextual_layers_any_v1_contextual_layer_proxy.endpoint_proxy_integration,
    module.fw_contextual_layers_post_v1_contextual_layer.endpoint_proxy_integration,
    module.fw_contextual_layers_any_v1_contextual_layer_proxy.endpoint_proxy_integration,
  ]
}