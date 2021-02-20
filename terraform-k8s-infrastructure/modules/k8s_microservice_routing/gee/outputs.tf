output "endpoints" {
  value = [
    module.gee_delete_rest_datasets_gee_dataset_id.endpoint_gateway_integration,
    module.gee_post_query_gee_dataset_id.endpoint_gateway_integration,
    module.gee_post_download_gee_dataset_id.endpoint_gateway_integration,
    module.gee_get_download_gee_dataset_id,
    module.gee_get_rest_datasets_gee.endpoint_gateway_integration,
    module.gee_get_query_gee_dataset_id.endpoint_gateway_integration,
    module.gee_get_fields_gee_dataset_id.endpoint_gateway_integration,
  ]
}