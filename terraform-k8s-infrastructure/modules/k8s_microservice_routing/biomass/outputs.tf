output "endpoints" {
  value = [
    module.biomass_v1_any_biomass_loss_admin_proxy.endpoint_gateway_integration,
  ]
}