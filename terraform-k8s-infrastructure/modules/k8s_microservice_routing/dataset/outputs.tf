output "endpoints" {
  value = [
    module.dataset_get_dataset.endpoint_gateway_integration,
    module.dataset_get_dataset_id.endpoint_gateway_integration,
    module.dataset_update_dataset_id.endpoint_gateway_integration,
    module.dataset_delete_dataset_id.endpoint_gateway_integration,
    module.dataset_post_dataset.endpoint_gateway_integration,
    module.dataset_post_dataset_id_clone.endpoint_gateway_integration,
    module.dataset_post_dataset_id_flush.endpoint_gateway_integration,
    module.dataset_post_dataset_id_recover.endpoint_gateway_integration,
    module.dataset_get_dataset_id_last_updated.endpoint_gateway_integration,
    module.dataset_post_dataset_find_by_ids.endpoint_gateway_integration,
    module.dataset_post_dataset_upload.endpoint_gateway_integration,
  ]
}