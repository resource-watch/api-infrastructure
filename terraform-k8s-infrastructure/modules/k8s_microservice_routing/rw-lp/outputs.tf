output "endpoints" {
  value = [
    module.rw_lp_get_home.endpoint_gateway_integration,
    module.rw_lp_get_rw_lp_proxy.endpoint_gateway_integration
  ]
}