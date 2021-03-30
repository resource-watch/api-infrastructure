output "endpoints" {
  value = [
    module.widget_get_widget.endpoint_gateway_integration,
    module.widget_get_dataset_id_widget.endpoint_gateway_integration,
    module.widget_get_dataset_id_widget_id.endpoint_gateway_integration,
    module.widget_any_dataset_id_widget_id_proxy.endpoint_gateway_integration,
    module.widget_any_widget_proxy.endpoint_gateway_integration,
    module.widget_post_dataset_id_widget.endpoint_gateway_integration,
    module.widget_post_widget.endpoint_gateway_integration,
    module.widget_delete_dataset_id_widget.endpoint_gateway_integration,
  ]
}