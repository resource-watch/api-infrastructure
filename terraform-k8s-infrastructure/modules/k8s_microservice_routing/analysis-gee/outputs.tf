output "endpoints" {
  value = [
    module.analysis_gee_get_v1_recent_tiles_classifier.endpoint_gateway_integration,
    module.analysis_gee_get_v1_composite_service.endpoint_gateway_integration,
    module.analysis_gee_post_v1_mc_analysis.endpoint_gateway_integration,
    module.analysis_gee_get_v1_composite_service_geom.endpoint_gateway_integration,
    module.analysis_gee_post_v1_composite_service_geom.endpoint_gateway_integration,
    module.analysis_gee_get_v1_geodescriber.endpoint_gateway_integration,
    module.analysis_gee_get_v1_geodescriber_geom.endpoint_gateway_integration,
    module.analysis_gee_post_v1_geodescriber_geom.endpoint_gateway_integration,
    module.analysis_gee_get_v1_umd_loss_gain.endpoint_gateway_integration,
    module.analysis_gee_post_v1_umd_loss_gain.endpoint_gateway_integration,
    module.analysis_gee_any_v1_umd_loss_gain_proxy.endpoint_gateway_integration,
    module.analysis_gee_get_v1_whrc_biomass.endpoint_gateway_integration,
    module.analysis_gee_post_v1_whrc_biomass.endpoint_gateway_integration,
    module.analysis_gee_any_v1_whrc_biomass_proxy.endpoint_gateway_integration,
    module.analysis_gee_post_v1_mangrove_biomass.endpoint_gateway_integration,
    module.analysis_gee_get_v1_mangrove_biomass.endpoint_gateway_integration,
    module.analysis_gee_any_v1_mangrove_biomass_proxy.endpoint_gateway_integration,
    module.analysis_gee_get_v1_population.endpoint_gateway_integration,
    module.analysis_gee_post_v1_population.endpoint_gateway_integration,
    module.analysis_gee_any_v1_population_proxy.endpoint_gateway_integration,
    module.analysis_gee_get_v1_soil_carbon.endpoint_gateway_integration,
    module.analysis_gee_any_v1_soil_carbon_proxy.endpoint_gateway_integration,
    module.analysis_gee_post_v1_forma250gfw.endpoint_gateway_integration,
    module.analysis_gee_get_v1_forma250gfw.endpoint_gateway_integration,
    module.analysis_gee_any_v1_forma250gfw_proxy.endpoint_gateway_integration,
    module.analysis_gee_get_v1_biomass_loss.endpoint_gateway_integration,
    module.analysis_gee_post_v1_biomass_loss.endpoint_gateway_integration,
    module.analysis_gee_any_v1_biomass_loss_proxy.endpoint_gateway_integration,
    module.analysis_gee_get_v1_loss_by_landcover.endpoint_gateway_integration,
    module.analysis_gee_post_v1_loss_by_landcover.endpoint_gateway_integration,
    module.analysis_gee_get_v1_landcover.endpoint_gateway_integration,
    module.analysis_gee_post_v1_landcover.endpoint_gateway_integration,
    module.analysis_gee_any_v1_lansat_tiles_proxy.endpoint_gateway_integration,
    module.analysis_gee_get_v1_sentinel_tiles.endpoint_gateway_integration,
    module.analysis_gee_get_v1_recent_tiles.endpoint_gateway_integration,
    module.analysis_gee_any_v1_recent_tiles_proxy.endpoint_gateway_integration,
    module.analysis_gee_get_v2_nlcd_landcover.endpoint_gateway_integration,
    module.analysis_gee_post_v2_nlcd_landcover.endpoint_gateway_integration,
    module.analysis_gee_any_v2_nlcd_landcover_proxy.endpoint_gateway_integration,
    module.analysis_gee_get_v2_biomass_loss.endpoint_gateway_integration,
    module.analysis_gee_post_v2_biomass_loss.endpoint_gateway_integration,
    module.analysis_gee_any_v2_biomass_loss_proxy.endpoint_gateway_integration,
  ]
}

output "v1_biomass_loss_resource" {
  value = aws_api_gateway_resource.v1_biomass_loss_resource
}

output "v1_umd_loss_gain_resource" {
  value = aws_api_gateway_resource.v1_umd_loss_gain_resource
}