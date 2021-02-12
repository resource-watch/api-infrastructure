output "endpoints" {
  value = [
    module.dataset_clone.endpoint_gateway_integration,
    module.dataset_flush.endpoint_gateway_integration,
    module.dataset_get.endpoint_gateway_integration,
    module.dataset_get_by_id.endpoint_gateway_integration,
    module.dataset_last_updated.endpoint_gateway_integration,
    module.dataset_create.endpoint_gateway_integration,
    module.dataset_post_find_by_ids.endpoint_gateway_integration,
    module.dataset_post_upload.endpoint_gateway_integration,
    module.dataset_recover.endpoint_gateway_integration,
    module.dataset_delete_by_id.endpoint_gateway_integration,
    module.dataset_update_by_id.endpoint_gateway_integration
  ]
}

output "dataset_id_resource" {
  value = aws_api_gateway_resource.dataset_id_resource
}