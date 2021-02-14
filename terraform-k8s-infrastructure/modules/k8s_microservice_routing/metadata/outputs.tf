output "endpoints" {
  value = [
    module.metadata_dataset_post_find_by_ids.endpoint_gateway_integration,
    module.metadata_delete_for_dataset.endpoint_gateway_integration,
    module.metadata_delete_for_dataset_layer.endpoint_gateway_integration,
    module.metadata_delete_for_dataset_widget.endpoint_gateway_integration,
    module.metadata_get.endpoint_gateway_integration,
    module.metadata_get_for_dataset.endpoint_gateway_integration,
    module.metadata_get_for_dataset_layer.endpoint_gateway_integration,
    module.metadata_get_for_dataset_widget.endpoint_gateway_integration,
    module.metadata_layer_post_find_by_ids.endpoint_gateway_integration,
    module.metadata_patch_for_dataset.endpoint_gateway_integration,
    module.metadata_patch_for_dataset_layer.endpoint_gateway_integration,
    module.metadata_patch_for_dataset_widget.endpoint_gateway_integration,
    module.metadata_post_for_dataset.endpoint_gateway_integration,
    module.metadata_post_for_dataset_clone.endpoint_gateway_integration,
    module.metadata_post_for_dataset_layer.endpoint_gateway_integration,
    module.metadata_post_for_dataset_widget.endpoint_gateway_integration,
    module.metadata_widget_post_find_by_ids.endpoint_gateway_integration,
  ]
}