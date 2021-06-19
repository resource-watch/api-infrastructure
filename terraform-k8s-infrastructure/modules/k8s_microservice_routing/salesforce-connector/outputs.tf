output "endpoints" {
  value = [
    module.salesforce_connector_any_v1_user_proxy.endpoint_gateway_integration
  ]
}