output "endpoints" {
  value = [
    module.widget_get_widget.endpoint_gateway_integration,
    module.widget_any_dataset_id_widget.endpoint_gateway_integration,
    module.widget_any_dataset_id_widget_id.endpoint_gateway_integration,
    module.widget_any_dataset_id_widget_id_proxy.endpoint_gateway_integration,
    module.widget_any_widget_proxy.endpoint_gateway_integration,
    module.widget_post_widget.endpoint_gateway_integration,
  ]
}
output "v1_widget_resource" {
  value = module.widget_resource.aws_api_gateway_resource
}

output "v1_dataset_id_widget_resource" {
  value = module.dataset_id_widget_resource.aws_api_gateway_resource
}

output "v1_dataset_id_widget_id_resource" {
  value = module.dataset_id_widget_id_resource.aws_api_gateway_resource
}