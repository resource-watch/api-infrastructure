output "endpoints" {
  value = [
    module.converter_get_converter_fs2sql.endpoint_gateway_integration,
    module.converter_post_converter_fs2sql.endpoint_gateway_integration,
    module.converter_get_converter_sql2fs.endpoint_gateway_integration,
    module.converter_post_converter_sql2fs.endpoint_gateway_integration,
    module.converter_get_converter_check_sql.endpoint_gateway_integration,
    module.converter_get_converter_sql2sql.endpoint_gateway_integration,
    module.converter_post_converter_sql2sql.endpoint_gateway_integration,
    module.converter_post_converter_json2sql.endpoint_gateway_integration,
  ]
}