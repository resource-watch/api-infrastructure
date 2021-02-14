output "endpoints" {
  value = [
    module.layer_get.endpoint_gateway_integration,
    module.layer_get_by_id.endpoint_gateway_integration,
    module.layer_get_for_dataset.endpoint_gateway_integration,
    module.layer_get_for_dataset_by_id.endpoint_gateway_integration,
    module.layer_change_environment_for_dataset_by_id.endpoint_gateway_integration,
    module.layer_delete_for_dataset.endpoint_gateway_integration,
    module.layer_delete_for_dataset_by_id.endpoint_gateway_integration,
    module.layer_post_for_dataset.endpoint_gateway_integration,
    module.layer_post_find_by_ids.endpoint_gateway_integration,
    module.layer_patch_for_dataset_by_id.endpoint_gateway_integration,
    module.layer_expire_cache.endpoint_gateway_integration
  ]
}