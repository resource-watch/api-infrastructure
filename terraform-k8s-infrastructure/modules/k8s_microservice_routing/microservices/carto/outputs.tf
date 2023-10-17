output "endpoints" {
  value = [
    module.carto_get_v1_download_cartodb_dataset_id.endpoint_gateway_integration,
    module.carto_get_v1_fields_cartodb_dataset_id.endpoint_gateway_integration,
    module.carto_get_v1_query_cartodb_dataset_id.endpoint_gateway_integration,
    module.carto_post_v1_download_cartodb_dataset_id.endpoint_gateway_integration,
    module.carto_post_v1_query_cartodb_dataset_id.endpoint_gateway_integration,
    module.carto_post_v1_rest_datasets_cartodb.endpoint_gateway_integration,
    module.carto_delete_v1_rest_datasets_cartodb_dataset_id.endpoint_gateway_integration
  ]
}