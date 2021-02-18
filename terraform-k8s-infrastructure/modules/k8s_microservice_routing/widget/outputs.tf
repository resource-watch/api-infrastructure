output "endpoints" {
  value = [
    module.widget_get_widget.endpoint_gateway_integration,
    module.widget_get_dataset_id_widget.endpoint_gateway_integration,
    module.widget_get_dataset_id_widget_id.endpoint_gateway_integration,
    module.widget_get_widget_id.endpoint_gateway_integration,
    module.widget_post_dataset_id_widget.endpoint_gateway_integration,
    module.widget_post_widget.endpoint_gateway_integration,
    module.widget_patch_widget_id.endpoint_gateway_integration,
    module.widget_delete_by_id.endpoint_gateway_integration,
    module.widget_delete_dataset_id_widget.endpoint_gateway_integration,
    module.widget_patch_dataset_id_widget_id.endpoint_gateway_integration,
    module.widget_patch_widget_change_environment_dataset_id_env.endpoint_gateway_integration,
    module.widget_delete_dataset_id_widget_id.endpoint_gateway_integration,
    module.widget_post_widget_find_by_ids.endpoint_gateway_integration,
    module.widget_post_dataset_id_clone.endpoint_gateway_integration,
    module.widget_post_dataset_id_widget_id_clone.endpoint_gateway_integration,
  ]
}