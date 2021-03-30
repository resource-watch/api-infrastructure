output "endpoints" {
  value = [
    module.document_adapter_get_query_csv_dataset_id.endpoint_gateway_integration,
    module.document_adapter_get_query_csv_dataset_id.endpoint_gateway_integration,
    module.document_adapter_get_query_json_dataset_id.endpoint_gateway_integration,
    module.document_adapter_get_query_json_dataset_id.endpoint_gateway_integration,
    module.document_adapter_get_query_tsv_dataset_id.endpoint_gateway_integration,
    module.document_adapter_get_query_tsv_dataset_id.endpoint_gateway_integration,
    module.document_adapter_get_query_xml_dataset_id.endpoint_gateway_integration,
    module.document_adapter_get_query_xml_dataset_id.endpoint_gateway_integration,
    module.document_adapter_get_download_csv_dataset_id.endpoint_gateway_integration,
    module.document_adapter_get_download_csv_dataset_id.endpoint_gateway_integration,
    module.document_adapter_get_download_json_dataset_id.endpoint_gateway_integration,
    module.document_adapter_get_download_json_dataset_id.endpoint_gateway_integration,
    module.document_adapter_get_download_tsv_dataset_id.endpoint_gateway_integration,
    module.document_adapter_get_download_tsv_dataset_id.endpoint_gateway_integration,
    module.document_adapter_get_download_xml_dataset_id.endpoint_gateway_integration,
    module.document_adapter_get_download_xml_dataset_id.endpoint_gateway_integration,
    module.document_adapter_get_fields_csv_dataset_id.endpoint_gateway_integration,
    module.document_adapter_get_fields_json_dataset_id.endpoint_gateway_integration,
    module.document_adapter_get_fields_tsv_dataset_id.endpoint_gateway_integration,
    module.document_adapter_get_fields_xml_dataset_id.endpoint_gateway_integration,
    module.document_adapter_post_dataset_id_concat.endpoint_gateway_integration,
    module.document_adapter_post_dataset_id_reindex.endpoint_gateway_integration,
    module.document_adapter_post_dataset_id_append.endpoint_gateway_integration,
    module.document_adapter_post_dataset_id_data_overwrite.endpoint_gateway_integration,
    module.document_adapter_any_doc_dataset_proxy.endpoint_gateway_integration
  ]
}