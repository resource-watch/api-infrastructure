output "endpoints" {
  value = [
    module.v1_gfw_metadata_proxy_endpoint.endpoint_proxy_integration,
  ]
}