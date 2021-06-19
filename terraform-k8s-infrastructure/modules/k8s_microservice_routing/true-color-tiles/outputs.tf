output "endpoints" {
  value = [
    module.true_color_tiles_get_v1_true_color_tiles_proxy.endpoint_gateway_integration,
  ]
}