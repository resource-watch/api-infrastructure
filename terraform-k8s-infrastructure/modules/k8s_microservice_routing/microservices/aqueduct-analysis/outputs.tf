output "endpoints" {
  value = [
    module.aqueduct_analysis_any_v1_aqueduct_proxy.endpoint_gateway_integration,
  ]
}