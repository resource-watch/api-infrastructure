output "endpoints" {
  value = [
    module.gfw_get_v1_download_gfw_dataset_id.endpoint_gateway_integration,
    module.gfw_get_v1_fields_gfw_dataset_id.endpoint_gateway_integration,
    module.gfw_get_v1_query_gfw_dataset_id.endpoint_gateway_integration,
    module.gfw_post_v1_download_gfw_dataset_id.endpoint_gateway_integration,
    module.gfw_post_v1_query_gfw_dataset_id.endpoint_gateway_integration,
    module.gfw_post_v1_rest_datasets_gfw.endpoint_gateway_integration,
    module.gfw_delete_v1_rest_datasets_gfw_dataset_id.endpoint_gateway_integration
  ]
}