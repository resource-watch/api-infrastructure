output "endpoints" {
  value = [
    module.query_get_query.endpoint_gateway_integration,
    module.query_get_query_id.endpoint_gateway_integration
  ]
}