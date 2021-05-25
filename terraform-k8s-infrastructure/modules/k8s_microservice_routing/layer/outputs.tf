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

output "v1_layer_resource" {
  value = aws_api_gateway_resource.layer_resource
}

output "v1_layer_id_resource" {
  value = aws_api_gateway_resource.layer_id_resource
}

output "v1_dataset_id_layer_resource" {
  value = aws_api_gateway_resource.dataset_id_layer_resource
}

output "v1_dataset_id_layer_id_resource" {
  value = aws_api_gateway_resource.dataset_id_layer_id_resource
}