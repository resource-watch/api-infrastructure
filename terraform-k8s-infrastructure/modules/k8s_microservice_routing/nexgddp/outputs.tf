output "endpoints" {
  value = [
    module.nexgddp_get_v1_query_nexgddp_dataset_id.endpoint_gateway_integration,
    module.nexgddp_post_v1_query_nexgddp_dataset_id.endpoint_gateway_integration,
    module.nexgddp_get_v1_fields_nexgddp_dataset_id.endpoint_gateway_integration,
    module.nexgddp_post_v1_rest_datasets_nexgddp.endpoint_gateway_integration,
    module.nexgddp_delete_v1_rest_datasets_nexgddp_dataset_id.endpoint_gateway_integration,
    module.nexgddp_get_v1_query_loca_dataset_id.endpoint_gateway_integration,
    module.nexgddp_post_v1_query_loca_dataset_id.endpoint_gateway_integration,
    module.nexgddp_get_v1_fields_loca_dataset_id.endpoint_gateway_integration,
    module.nexgddp_post_v1_rest_datasets_loca.endpoint_gateway_integration,
    module.nexgddp_any_v1_nexgddp_proxy.endpoint_gateway_integration,
    module.nexgddp_any_v1_loca_proxy.endpoint_gateway_integration,
    module.gee_tiles_any_layer_id_tile_nexgddp_proxy_resource.endpoint_gateway_integration,
    module.gee_tiles_any_layer_id_tile_loca_proxy_resource.endpoint_gateway_integration,
    module.gee_tiles_any_layer_nexgddp_proxy_resource.endpoint_gateway_integration,
    module.gee_tiles_any_layer_loca_proxy_resource.endpoint_gateway_integration,
  ]
}