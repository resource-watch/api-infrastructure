output "endpoints" {
  value = [
    module.gee_tiles_any_gee_layer_gee_proxy.endpoint_gateway_integration,
    module.gee_tiles_any_layer_id_tile_gee_proxy.endpoint_gateway_integration
  ]
}

output "v1_gee_tiles_layer_id_tile_resource" {
  value = aws_api_gateway_resource.gee_tiles_layer_id_tile_resource
}