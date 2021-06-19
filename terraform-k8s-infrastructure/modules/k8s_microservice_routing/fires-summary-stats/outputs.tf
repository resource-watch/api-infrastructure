output "endpoints" {
  value = [
    module.fires_summary_stats_any_fire_alerts_proxy.endpoint_gateway_integration,
    module.fires_summary_stats_any_glad_alerts_summary_stats_proxy.endpoint_gateway_integration,
  ]
}

output "v1_glad_alerts_resource" {
  value = module.glad_alerts_resource.aws_api_gateway_resource
}