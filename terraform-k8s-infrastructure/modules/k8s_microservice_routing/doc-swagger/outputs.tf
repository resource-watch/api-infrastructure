output "endpoints" {
  value = [
    module.doc_swagger_any.endpoint_gateway_integration,
    module.doc_swagger_proxy_any.endpoint_gateway_integration,
  ]
}