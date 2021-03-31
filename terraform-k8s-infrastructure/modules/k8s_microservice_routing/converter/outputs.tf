output "endpoints" {
  value = [
    module.converter_any_converter_fs2sql.endpoint_gateway_integration
  ]
}