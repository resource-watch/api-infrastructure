output "endpoints" {
  value = [
    module.biomass_v1_get_biomass_loss_admin_iso.endpoint_gateway_integration,
    module.biomass_v1_get_biomass_loss_admin_iso_id.endpoint_gateway_integration,
  ]
}