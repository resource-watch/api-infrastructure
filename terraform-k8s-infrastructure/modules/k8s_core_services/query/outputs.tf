output "endpoints" {
  value = [
    module.query_get_query.endpoint_gateway_integration,
    module.query_get_query_id.endpoint_gateway_integration,
    module.query_post_query_id.endpoint_gateway_integration,
    module.query_post_query.endpoint_gateway_integration,
    module.download_get_download.endpoint_gateway_integration,
    module.download_get_download_id.endpoint_gateway_integration,
    module.download_post_download.endpoint_gateway_integration,
    module.download_post_download_id.endpoint_gateway_integration,
    module.jiminy_post_jiminy.endpoint_gateway_integration,
    module.jiminy_get_jiminy.endpoint_gateway_integration,
    module.fields_get_id.endpoint_gateway_integration,
  ]
}