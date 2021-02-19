output "endpoints" {
  value = [
    module.arcgis_get_v1_query_featureservice_dataset_id.endpoint_gateway_integration,
    module.arcgis_post_v1_query_featureservice_dataset_id.endpoint_gateway_integration,
    module.arcgis_get_v1_download_featureservice_dataset_id.endpoint_gateway_integration,
    module.arcgis_post_v1_download_featureservice_dataset_id.endpoint_gateway_integration,
    module.arcgis_post_v1_fields_featureservice_dataset_id.endpoint_gateway_integration,
    module.arcgis_post_v1_rest_datasets_featureservice.endpoint_gateway_integration,
    module.arcgis_delete_v1_rest_datasets_featureservice_dataset_id.endpoint_gateway_integration
  ]
}