output "endpoints" {
  value = [
    module.aqueduct_analysis_get_v1_aqueduct_analysis.endpoint_gateway_integration,
    module.aqueduct_analysis_post_v1_aqueduct_analysis.endpoint_gateway_integration,
    module.aqueduct_analysis_get_v1_aqueduct_analysis_cba.endpoint_gateway_integration,
    module.aqueduct_analysis_get_v1_aqueduct_analysis_cba_default.endpoint_gateway_integration,
    module.aqueduct_analysis_get_v1_aqueduct_analysis_cba_widget_id.endpoint_gateway_integration,
    module.aqueduct_analysis_get_v1_aqueduct_analysis_cba_expire_cache.endpoint_gateway_integration,
    module.aqueduct_analysis_delete_v1_aqueduct_analysis_risk_widget_id.endpoint_gateway_integration,
  ]
}