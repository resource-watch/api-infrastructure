output "endpoints" {
  value = [
    module.glad_analysis_tiled_any_v1_glad_alerts_admin_proxy.endpoint_gateway_integration,
    module.glad_analysis_tiled_get_v1_glad_alerts_download.endpoint_gateway_integration,
    module.glad_analysis_tiled_post_v1_glad_alerts_download.endpoint_gateway_integration,
    module.glad_analysis_tiled_get_v1_glad_alerts.endpoint_gateway_integration,
    module.glad_analysis_tiled_post_v1_glad_alerts.endpoint_gateway_integration,
    module.glad_analysis_tiled_get_v1_glad_alerts_latest.endpoint_gateway_integration,
    module.glad_analysis_tiled_any_v1_glad_alerts_wdpa_proxy.endpoint_gateway_integration,
    module.glad_analysis_tiled_any_v1_glad_alerts_use_proxy.endpoint_gateway_integration
  ]
}

