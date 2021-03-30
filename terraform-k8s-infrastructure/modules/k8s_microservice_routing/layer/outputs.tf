output "endpoints" {
  value = [
    module.layer_get.endpoint_gateway_integration,
    module.layer_get_dataset_id_layer.endpoint_gateway_integration,
    module.layer_get_dataset_id.endpoint_gateway_integration,
    module.layer_get_layer_id.endpoint_gateway_integration,
    module.layer_post_dataset_id_layer.endpoint_gateway_integration,
    module.layer_delete_dataset_id_layer.endpoint_gateway_integration,
    module.layer_patch_dataset_id_layer_id.endpoint_gateway_integration,
    module.layer_any_layer_change_environment_proxy.endpoint_gateway_integration,
    module.layer_delete_dataset_id_layer_id.endpoint_gateway_integration,
    module.layer_post_layer_find_by_ids.endpoint_gateway_integration,
    module.layer_delete_layer_id_expire_cache.endpoint_gateway_integration,
  ]
}