output "endpoints" {
  value = [
    module.widget_get.endpoint_gateway_integration,
    module.widget_get_by_id.endpoint_gateway_integration,
    module.widget_get_for_dataset.endpoint_gateway_integration,
    module.widget_get_for_dataset_by_id.endpoint_gateway_integration,
    module.widget_change_environment_for_dataset_by_id.endpoint_gateway_integration,
    module.widget_clone.endpoint_gateway_integration,
    module.widget_clone_for_dataset_id.endpoint_gateway_integration,
    module.widget_delete_by_id.endpoint_gateway_integration,
    module.widget_delete_for_dataset.endpoint_gateway_integration,
    module.widget_delete_for_dataset_by_id.endpoint_gateway_integration,
    module.widget_patch_by_id.endpoint_gateway_integration,
    module.widget_post.endpoint_gateway_integration,
    module.widget_post_for_dataset.endpoint_gateway_integration,
    module.widget_post_find_by_ids.endpoint_gateway_integration,
    module.widget_patch_for_dataset_by_id.endpoint_gateway_integration,
  ]
}