output "endpoints" {
  value = [
    module.dataset_get_dataset.endpoint_gateway_integration,
    module.dataset_get_dataset_id.endpoint_gateway_integration,
    module.dataset_update_dataset_id.endpoint_gateway_integration,
    module.dataset_delete_dataset_id.endpoint_gateway_integration,
    module.dataset_post_dataset.endpoint_gateway_integration,
    module.dataset_any_dataset_id_proxy.endpoint_gateway_integration,
    module.dataset_post_dataset_find_by_ids.endpoint_gateway_integration,
    module.dataset_post_dataset_upload.endpoint_gateway_integration,
  ]
}

output "v1_dataset_resource" {
  value = module.dataset_resource.aws_api_gateway_resource
}

output "v1_dataset_id_resource" {
  value = module.dataset_id_resource.aws_api_gateway_resource
}

output "v1_rest_datasets_resource" {
  value = module.rest_datasets_resource.aws_api_gateway_resource
}