output "endpoints" {
  value = [
    module.bigquery_get_v1_download_bigquery_dataset_id.endpoint_gateway_integration,
    module.bigquery_get_v1_fields_bigquery_dataset_id.endpoint_gateway_integration,
    module.bigquery_get_v1_query_bigquery_dataset_id.endpoint_gateway_integration,
    module.bigquery_post_v1_download_bigquery_dataset_id.endpoint_gateway_integration,
    module.bigquery_post_v1_query_bigquery_dataset_id.endpoint_gateway_integration,
    module.bigquery_post_v1_rest_datasets_bigquery.endpoint_gateway_integration,
  ]
}