output "endpoints" {
  value = [
    module.fw_teams_any_v1_teams_proxy.endpoint_proxy_integration,
    module.fw_teams_post_v1_teams.endpoint_proxy_integration,
  ]
}