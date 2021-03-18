output "endpoints" {
  value = [
    module.gee_tiles_delete_gee_layer_gee_id_expire_cache.endpoint_gateway_integration,
    module.gee_tiles_get_layer_id_tile_gee_z_x_y.endpoint_gateway_integration
  ]
}