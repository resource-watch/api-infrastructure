resource "kubernetes_service" "analysis_gee_service" {
  metadata {
    name = "analysis-gee"
    namespace = "gfw"

  }
  spec {
    selector = {
      name = "analysis-gee"
    }
    port {
      port        = 30500
      node_port   = 30500
      target_port = 4500
    }

    type = "NodePort"
  }
}

resource "aws_lb_listener" "analysis_gee_nlb_listener" {
  load_balancer_arn = var.load_balancer.arn
  port              = 30500
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.analysis_gee_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "analysis_gee_lb_target_group" {
  name        = "analysis-gee-lb-tg"
  port        = 30500
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_analysis_gee" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.analysis_gee_lb_target_group.arn
}

// /v1
data "aws_api_gateway_resource" "v1_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1"
}

// /v2
data "aws_api_gateway_resource" "v2_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v2"
}

// /v1/recent-tiles-classifier
resource "aws_api_gateway_resource" "v1_recent_tiles_classifier_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "recent-tiles-classifier"
}

// /v1/composite-service
resource "aws_api_gateway_resource" "v1_composite_service_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "composite-service"
}

// /v1/composite-service/geom
resource "aws_api_gateway_resource" "v1_composite_service_geom_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_composite_service_resource.id
  path_part   = "geom"
}

// /v1/mc-analysis
resource "aws_api_gateway_resource" "v1_mc_analysis_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "mc-analysis"
}

// /v1/geodescriber
resource "aws_api_gateway_resource" "v1_geodescriber_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "geodescriber"
}

// /v1/geodescriber/geom
resource "aws_api_gateway_resource" "v1_geodescriber_geom_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_geodescriber_resource.id
  path_part   = "geom"
}

// /v1/umd-loss-gain
resource "aws_api_gateway_resource" "v1_umd_loss_gain_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "umd-loss-gain"
}

// /v1/umd-loss-gain/use
resource "aws_api_gateway_resource" "v1_umd_loss_gain_use_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_umd_loss_gain_resource.id
  path_part   = "use"
}

// /v1/umd-loss-gain/use/{name}
resource "aws_api_gateway_resource" "v1_umd_loss_gain_use_name_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_umd_loss_gain_use_resource.id
  path_part   = "{name}"
}

// /v1/umd-loss-gain/use/{name}/{id}
resource "aws_api_gateway_resource" "v1_umd_loss_gain_use_name_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_umd_loss_gain_use_name_resource.id
  path_part   = "{id}"
}

// /v1/umd-loss-gain/wdpa
resource "aws_api_gateway_resource" "v1_umd_loss_gain_wdpa_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_umd_loss_gain_resource.id
  path_part   = "use"
}

// /v1/umd-loss-gain/wdpa/{id}
resource "aws_api_gateway_resource" "v1_umd_loss_gain_wdpa_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_umd_loss_gain_wdpa_resource.id
  path_part   = "{id}"
}

// /v1/whrc-biomass
resource "aws_api_gateway_resource" "v1_whrc_biomass_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "whrc-biomass"
}

// /v1/whrc-biomass/use
resource "aws_api_gateway_resource" "v1_whrc_biomass_use_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_whrc_biomass_resource.id
  path_part   = "use"
}

// /v1/whrc-biomass/use/{name}
resource "aws_api_gateway_resource" "v1_whrc_biomass_use_name_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_whrc_biomass_use_resource.id
  path_part   = "{name}"
}

// /v1/whrc-biomass/use/{name}/{id}
resource "aws_api_gateway_resource" "v1_whrc_biomass_use_name_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_whrc_biomass_use_name_resource.id
  path_part   = "{id}"
}

// /v1/whrc-biomass/wdpa
resource "aws_api_gateway_resource" "v1_whrc_biomass_wdpa_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_whrc_biomass_resource.id
  path_part   = "wdpa"
}

// /v1/whrc-biomass/wdpa/{id}
resource "aws_api_gateway_resource" "v1_whrc_biomass_wdpa_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_whrc_biomass_wdpa_resource.id
  path_part   = "{id}"
}

// /v1/whrc-biomass/admin
resource "aws_api_gateway_resource" "v1_whrc_biomass_admin_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_whrc_biomass_resource.id
  path_part   = "admin"
}

// /v1/whrc-biomass/admin/{iso}
resource "aws_api_gateway_resource" "v1_whrc_biomass_admin_iso_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_whrc_biomass_admin_resource.id
  path_part   = "{iso}"
}

// /v1/whrc-biomass/admin/{iso}/{admin}
resource "aws_api_gateway_resource" "v1_whrc_biomass_admin_iso_admin_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_whrc_biomass_admin_iso_resource.id
  path_part   = "{admin}"
}

// /v1/whrc-biomass/admin/{iso}/{admin}/{admin2}
resource "aws_api_gateway_resource" "v1_whrc_biomass_admin_iso_admin_admin2_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_whrc_biomass_admin_iso_admin_resource.id
  path_part   = "{admin2}"
}

// /v1/mangrove-biomass
resource "aws_api_gateway_resource" "v1_mangrove_biomass_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "mangrove-biomass"
}

// /v1/mangrove-biomass/use
resource "aws_api_gateway_resource" "v1_mangrove_biomass_use_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_mangrove_biomass_resource.id
  path_part   = "use"
}

// /v1/mangrove-biomass/use/{name}
resource "aws_api_gateway_resource" "v1_mangrove_biomass_use_name_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_mangrove_biomass_use_resource.id
  path_part   = "{name}"
}

// /v1/mangrove-biomass/use/{name}/{id}
resource "aws_api_gateway_resource" "v1_mangrove_biomass_use_name_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_mangrove_biomass_use_name_resource.id
  path_part   = "{id}"
}

// /v1/mangrove-biomass/wdpa
resource "aws_api_gateway_resource" "v1_mangrove_biomass_wdpa_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_mangrove_biomass_resource.id
  path_part   = "wdpa"
}

// /v1/mangrove-biomass/wdpa/{id}
resource "aws_api_gateway_resource" "v1_mangrove_biomass_wdpa_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_mangrove_biomass_wdpa_resource.id
  path_part   = "{id}"
}

// /v1/mangrove-biomass/admin
resource "aws_api_gateway_resource" "v1_mangrove_biomass_admin_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_mangrove_biomass_resource.id
  path_part   = "admin"
}

// /v1/mangrove-biomass/admin/{iso}
resource "aws_api_gateway_resource" "v1_mangrove_biomass_admin_iso_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_mangrove_biomass_admin_resource.id
  path_part   = "{iso}"
}

// /v1/mangrove-biomass/admin/{iso}/{admin}
resource "aws_api_gateway_resource" "v1_mangrove_biomass_admin_iso_admin_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_mangrove_biomass_admin_iso_resource.id
  path_part   = "{admin}"
}

// /v1/mangrove-biomass/admin/{iso}/{admin}/{admin2}
resource "aws_api_gateway_resource" "v1_mangrove_biomass_admin_iso_admin_admin2_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_mangrove_biomass_admin_iso_admin_resource.id
  path_part   = "{admin2}"
}

// /v1/population
resource "aws_api_gateway_resource" "v1_population_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "population"
}

// /v1/population/use
resource "aws_api_gateway_resource" "v1_population_use_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_population_resource.id
  path_part   = "use"
}

// /v1/population/use/{name}
resource "aws_api_gateway_resource" "v1_population_use_name_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_population_use_resource.id
  path_part   = "{name}"
}

// /v1/population/use/{name}/{id}
resource "aws_api_gateway_resource" "v1_population_use_name_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_population_use_name_resource.id
  path_part   = "{id}"
}

// /v1/population/wdpa
resource "aws_api_gateway_resource" "v1_population_wdpa_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_population_resource.id
  path_part   = "wdpa"
}

// /v1/population/wdpa/{id}
resource "aws_api_gateway_resource" "v1_population_wdpa_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_population_wdpa_resource.id
  path_part   = "{id}"
}

// /v1/population/admin
resource "aws_api_gateway_resource" "v1_population_admin_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_population_resource.id
  path_part   = "admin"
}

// /v1/population/admin/{iso}
resource "aws_api_gateway_resource" "v1_population_admin_iso_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_population_admin_resource.id
  path_part   = "{iso}"
}

// /v1/population/admin/{iso}/{admin}
resource "aws_api_gateway_resource" "v1_population_admin_iso_admin_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_population_admin_iso_resource.id
  path_part   = "{admin}"
}

// /v1/population/admin/{iso}/{admin}/{admin2}
resource "aws_api_gateway_resource" "v1_population_admin_iso_admin_admin2_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_population_admin_iso_admin_resource.id
  path_part   = "{admin2}"
}

// /v1/soil-carbon
resource "aws_api_gateway_resource" "v1_soil_carbon_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "soil-carbon"
}

// /v1/soil-carbon/use
resource "aws_api_gateway_resource" "v1_soil_carbon_use_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_soil_carbon_resource.id
  path_part   = "use"
}

// /v1/soil-carbon/use/{name}
resource "aws_api_gateway_resource" "v1_soil_carbon_use_name_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_soil_carbon_use_resource.id
  path_part   = "{name}"
}

// /v1/soil-carbon/use/{name}/{id}
resource "aws_api_gateway_resource" "v1_soil_carbon_use_name_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_soil_carbon_use_name_resource.id
  path_part   = "{id}"
}

// /v1/soil-carbon/wdpa
resource "aws_api_gateway_resource" "v1_soil_carbon_wdpa_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_soil_carbon_resource.id
  path_part   = "wdpa"
}

// /v1/soil-carbon/wdpa/{id}
resource "aws_api_gateway_resource" "v1_soil_carbon_wdpa_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_soil_carbon_wdpa_resource.id
  path_part   = "{id}"
}

// /v1/soil-carbon/admin
resource "aws_api_gateway_resource" "v1_soil_carbon_admin_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_soil_carbon_resource.id
  path_part   = "admin"
}

// /v1/soil-carbon/admin/{iso}
resource "aws_api_gateway_resource" "v1_soil_carbon_admin_iso_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_soil_carbon_admin_resource.id
  path_part   = "{iso}"
}

// /v1/soil-carbon/admin/{iso}/{admin}
resource "aws_api_gateway_resource" "v1_soil_carbon_admin_iso_admin_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_soil_carbon_admin_iso_resource.id
  path_part   = "{admin}"
}

// /v1/soil-carbon/admin/{iso}/{admin}/{admin2}
resource "aws_api_gateway_resource" "v1_soil_carbon_admin_iso_admin_admin2_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_soil_carbon_admin_iso_admin_resource.id
  path_part   = "{admin2}"
}

// /v1/forma250gfw
resource "aws_api_gateway_resource" "v1_forma250gfw_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "forma250gfw"
}

// /v1/forma250gfw/latest
resource "aws_api_gateway_resource" "v1_forma250gfw_latest_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_forma250gfw_resource.id
  path_part   = "latest"
}

// /v1/forma250gfw/use
resource "aws_api_gateway_resource" "v1_forma250gfw_use_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_forma250gfw_resource.id
  path_part   = "use"
}

// /v1/forma250gfw/use/{name}
resource "aws_api_gateway_resource" "v1_forma250gfw_use_name_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_forma250gfw_use_resource.id
  path_part   = "{name}"
}

// /v1/forma250gfw/use/{name}/{id}
resource "aws_api_gateway_resource" "v1_forma250gfw_use_name_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_forma250gfw_use_name_resource.id
  path_part   = "{id}"
}

// /v1/forma250gfw/wdpa
resource "aws_api_gateway_resource" "v1_forma250gfw_wdpa_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_forma250gfw_resource.id
  path_part   = "wdpa"
}

// /v1/forma250gfw/wdpa/{id}
resource "aws_api_gateway_resource" "v1_forma250gfw_wdpa_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_forma250gfw_wdpa_resource.id
  path_part   = "{id}"
}

// /v1/forma250gfw/admin
resource "aws_api_gateway_resource" "v1_forma250gfw_admin_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_forma250gfw_resource.id
  path_part   = "admin"
}

// /v1/forma250gfw/admin/{iso}
resource "aws_api_gateway_resource" "v1_forma250gfw_admin_iso_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_forma250gfw_admin_resource.id
  path_part   = "{iso}"
}

// /v1/forma250gfw/admin/{iso}/{admin}
resource "aws_api_gateway_resource" "v1_forma250gfw_admin_iso_admin_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_forma250gfw_admin_iso_resource.id
  path_part   = "{admin}"
}

// /v1/forma250gfw/admin/{iso}/{admin}/{admin2}
resource "aws_api_gateway_resource" "v1_forma250gfw_admin_iso_admin_admin2_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_forma250gfw_admin_iso_admin_resource.id
  path_part   = "{admin2}"
}

// /v1/biomass-loss
resource "aws_api_gateway_resource" "v1_biomass_loss_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "biomass-loss"
}

// /v1/biomass-loss/use
resource "aws_api_gateway_resource" "v1_biomass_loss_use_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_biomass_loss_resource.id
  path_part   = "use"
}

// /v1/biomass-loss/use/{name}
resource "aws_api_gateway_resource" "v1_biomass_loss_use_name_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_biomass_loss_use_resource.id
  path_part   = "{name}"
}

// /v1/biomass-loss/use/{name}/{id}
resource "aws_api_gateway_resource" "v1_biomass_loss_use_name_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_biomass_loss_use_name_resource.id
  path_part   = "{id}"
}

// /v1/biomass-loss/wdpa
resource "aws_api_gateway_resource" "v1_biomass_loss_wdpa_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_biomass_loss_resource.id
  path_part   = "wdpa"
}

// /v1/biomass-loss/wdpa/{id}
resource "aws_api_gateway_resource" "v1_biomass_loss_wdpa_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_biomass_loss_wdpa_resource.id
  path_part   = "{id}"
}

// /v1/biomass-loss/admin
resource "aws_api_gateway_resource" "v1_biomass_loss_admin_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_biomass_loss_resource.id
  path_part   = "admin"
}

// /v1/biomass-loss/admin/{iso}
resource "aws_api_gateway_resource" "v1_biomass_loss_admin_iso_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_biomass_loss_admin_resource.id
  path_part   = "{iso}"
}

// /v1/biomass-loss/admin/{iso}/{admin}
resource "aws_api_gateway_resource" "v1_biomass_loss_admin_iso_admin_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_biomass_loss_admin_iso_resource.id
  path_part   = "{admin}"
}

// /v1/biomass-loss/admin/{iso}/{admin}/{admin2}
resource "aws_api_gateway_resource" "v1_biomass_loss_admin_iso_admin_admin2_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_biomass_loss_admin_iso_admin_resource.id
  path_part   = "{admin2}"
}

// /v1/loss-by-landcover
resource "aws_api_gateway_resource" "v1_loss_by_landcover_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "loss-by-landcover"
}

// /v1/landcover
resource "aws_api_gateway_resource" "v1_landcover_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "landcover"
}

// /v1/lansat-tiles
resource "aws_api_gateway_resource" "v1_lansat_tiles_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "lansat-tiles"
}

// /v1/lansat-tiles/{year}
resource "aws_api_gateway_resource" "v1_lansat_tiles_year_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_lansat_tiles_resource.id
  path_part   = "{year}"
}

// /v1/lansat-tiles/{year}/{z}
resource "aws_api_gateway_resource" "v1_lansat_tiles_year_z_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_lansat_tiles_year_resource.id
  path_part   = "{x}"
}

// /v1/lansat-tiles/{year}/{z}/{x}
resource "aws_api_gateway_resource" "v1_lansat_tiles_year_z_x_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_lansat_tiles_year_z_resource.id
  path_part   = "{x}"
}

// /v1/lansat-tiles/{year}/{z}/{x}/{y}
resource "aws_api_gateway_resource" "v1_lansat_tiles_year_z_x_y_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_lansat_tiles_year_z_x_resource.id
  path_part   = "{y}"
}

// /v1/sentinel-tiles
resource "aws_api_gateway_resource" "v1_sentinel_tiles_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "sentinel-tiles"
}

// /v1/recent-tiles
resource "aws_api_gateway_resource" "v1_recent_tiles_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "recent-tiles"
}

// /v1/recent-tiles/tiles
resource "aws_api_gateway_resource" "v1_recent_tiles_tiles_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_recent_tiles_resource.id
  path_part   = "tiles"
}

// /v1/recent-tiles/thumbs
resource "aws_api_gateway_resource" "v1_recent_tiles_thumbs_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_recent_tiles_resource.id
  path_part   = "thumbs"
}

// v2
// /v2/nlcd-landcover
resource "aws_api_gateway_resource" "v2_nlcd_landcover_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v2_resource.id
  path_part   = "nlcd-landcover"
}

// /v2/nlcd-landcover/use
resource "aws_api_gateway_resource" "v2_nlcd_landcover_use_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_nlcd_landcover_resource.id
  path_part   = "use"
}

// /v2/nlcd-landcover/use/{name}
resource "aws_api_gateway_resource" "v2_nlcd_landcover_use_name_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_nlcd_landcover_use_resource.id
  path_part   = "{name}"
}

// /v2/nlcd-landcover/use/{name}/{id}
resource "aws_api_gateway_resource" "v2_nlcd_landcover_use_name_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_nlcd_landcover_use_name_resource.id
  path_part   = "{id}"
}

// /v2/nlcd-landcover/wdpa
resource "aws_api_gateway_resource" "v2_nlcd_landcover_wdpa_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_nlcd_landcover_resource.id
  path_part   = "wdpa"
}

// /v2/nlcd-landcover/wdpa/{id}
resource "aws_api_gateway_resource" "v2_nlcd_landcover_wdpa_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_nlcd_landcover_wdpa_resource.id
  path_part   = "{id}"
}

// /v2/nlcd-landcover/admin
resource "aws_api_gateway_resource" "v2_nlcd_landcover_admin_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_nlcd_landcover_resource.id
  path_part   = "admin"
}

// /v2/nlcd-landcover/admin/{iso}
resource "aws_api_gateway_resource" "v2_nlcd_landcover_admin_iso_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_nlcd_landcover_admin_resource.id
  path_part   = "{iso}"
}

// /v2/nlcd-landcover/admin/{iso}/{admin}
resource "aws_api_gateway_resource" "v2_nlcd_landcover_admin_iso_admin_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_nlcd_landcover_admin_iso_resource.id
  path_part   = "{admin}"
}

// /v2/nlcd-landcover/admin/{iso}/{admin}/{admin2}
resource "aws_api_gateway_resource" "v2_nlcd_landcover_admin_iso_admin_admin2_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_nlcd_landcover_admin_iso_admin_resource.id
  path_part   = "{admin2}"
}

// /v2/biomass-loss
resource "aws_api_gateway_resource" "v2_biomass_loss_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v2_resource.id
  path_part   = "biomass-loss"
}

// /v2/biomass-loss/use
resource "aws_api_gateway_resource" "v2_biomass_loss_use_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_biomass_loss_resource.id
  path_part   = "use"
}

// /v2/biomass-loss/use/{name}
resource "aws_api_gateway_resource" "v2_biomass_loss_use_name_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_biomass_loss_use_resource.id
  path_part   = "{name}"
}

// /v2/biomass-loss/use/{name}/{id}
resource "aws_api_gateway_resource" "v2_biomass_loss_use_name_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_biomass_loss_use_name_resource.id
  path_part   = "{id}"
}

// /v2/biomass-loss/wdpa
resource "aws_api_gateway_resource" "v2_biomass_loss_wdpa_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_biomass_loss_resource.id
  path_part   = "wdpa"
}

// /v2/biomass-loss/wdpa/{id}
resource "aws_api_gateway_resource" "v2_biomass_loss_wdpa_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_biomass_loss_wdpa_resource.id
  path_part   = "{id}"
}

// /v2/biomass-loss/admin
resource "aws_api_gateway_resource" "v2_biomass_loss_admin_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_biomass_loss_resource.id
  path_part   = "admin"
}

// /v2/biomass-loss/admin/{iso}
resource "aws_api_gateway_resource" "v2_biomass_loss_admin_iso_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_biomass_loss_admin_resource.id
  path_part   = "{iso}"
}

// /v2/biomass-loss/admin/{iso}/{admin}
resource "aws_api_gateway_resource" "v2_biomass_loss_admin_iso_admin_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_biomass_loss_admin_iso_resource.id
  path_part   = "{admin}"
}

// /v2/biomass-loss/admin/{iso}/{admin}/{admin2}
resource "aws_api_gateway_resource" "v2_biomass_loss_admin_iso_admin_admin2_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_biomass_loss_admin_iso_admin_resource.id
  path_part   = "{admin2}"
}

// /v2/lansat-tiles
resource "aws_api_gateway_resource" "v2_lansat_tiles_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v2_resource.id
  path_part   = "lansat-tiles"
}

// /v2/lansat-tiles/{year}
resource "aws_api_gateway_resource" "v2_lansat_tiles_year_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_lansat_tiles_resource.id
  path_part   = "{year}"
}

// /v2/lansat-tiles/{year}/{z}
resource "aws_api_gateway_resource" "v2_lansat_tiles_year_z_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_lansat_tiles_year_resource.id
  path_part   = "{x}"
}

// /v2/lansat-tiles/{year}/{z}/{x}
resource "aws_api_gateway_resource" "v2_lansat_tiles_year_z_x_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_lansat_tiles_year_z_resource.id
  path_part   = "{x}"
}

// /v2/lansat-tiles/{year}/{z}/{x}/{y}
resource "aws_api_gateway_resource" "v2_lansat_tiles_year_z_x_y_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_lansat_tiles_year_z_x_resource.id
  path_part   = "{y}"
}

module "analysis_gee_get_v1_recent_tiles_classifier" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_recent_tiles_classifier_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v1/recent-tiles-classifier"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_composite_service" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_composite_service_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v1/composite-service"
  vpc_link     = var.vpc_link
}

module "analysis_gee_post_v1_mc_analysis" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_mc_analysis_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30500/api/v1/mc-analysis"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_composite_service_geom" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_composite_service_geom_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v1/composite-service/geom"
  vpc_link     = var.vpc_link
}

module "analysis_gee_post_v1_composite_service_geom" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_composite_service_geom_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30500/api/v1/composite-service/geom"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_geodescriber" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_geodescriber_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v1/geodescriber"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_geodescriber_geom" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_geodescriber_geom_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v1/geodescriber/geom"
  vpc_link     = var.vpc_link
}

module "analysis_gee_post_v1_geodescriber_geom" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_geodescriber_geom_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30500/api/v1/geodescriber/geom"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_umd_loss_gain" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_umd_loss_gain_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v1/umd-loss-gain"
  vpc_link     = var.vpc_link
}

module "analysis_gee_post_v1_umd_loss_gain" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_umd_loss_gain_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30500/api/v1/umd-loss-gain"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_umd_loss_gain_use_name_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_umd_loss_gain_use_name_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v1/umd-loss-gain/use/{name}/{id}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_umd_loss_gain_wdpa_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_umd_loss_gain_wdpa_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v1/umd-loss-gain/wdpa/{id}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_whrc_biomass" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_whrc_biomass_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v1/whrc-biomass"
  vpc_link     = var.vpc_link
}

module "analysis_gee_post_v1_whrc_biomass" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_whrc_biomass_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30500/api/v1/whrc-biomass"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_whrc_biomass_use_name_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_whrc_biomass_use_name_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v1/whrc-biomass/use/{name}/{id}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_whrc_biomass_wdpa_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_whrc_biomass_wdpa_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v1/whrc-biomass/wdpa/{id}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_whrc_biomass_admin_iso" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_whrc_biomass_admin_iso_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v1/whrc-biomass/admin/{iso}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_whrc_biomass_admin_iso_admin" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_whrc_biomass_admin_iso_admin_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v1/whrc-biomass/admin/{iso}/{admin}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_whrc_biomass_admin_iso_admin_admin2" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_whrc_biomass_admin_iso_admin_admin2_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v1/whrc-biomass/admin/{iso}/{admin}/{admin2}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_post_v1_mangrove_biomass" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_mangrove_biomass_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30500/api/v1/mangrove-biomass"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_mangrove_biomass" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_mangrove_biomass_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v1/mangrove-biomass"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_mangrove_biomass_use_name_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_mangrove_biomass_use_name_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v1/mangrove-biomass/use/{name}/{id}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_mangrove_biomass_wdpa_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_mangrove_biomass_wdpa_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v1/mangrove-biomass/wdpa/{id}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_mangrove_biomass_admin_iso" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_mangrove_biomass_admin_iso_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v1/mangrove-biomass/admin/{iso}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_mangrove_biomass_admin_iso_admin" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_mangrove_biomass_admin_iso_admin_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v1/mangrove-biomass/admin/{iso}/{admin}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_mangrove_biomass_admin_iso_admin_admin2" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_mangrove_biomass_admin_iso_admin_admin2_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v1/mangrove-biomass/admin/{iso}/{admin}/{admin2}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_population" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_population_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v1/population"
  vpc_link     = var.vpc_link
}

module "analysis_gee_post_v1_population" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_population_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30500/api/v1/population"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_population_use_name_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_population_use_name_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v1/population/use/{name}/{id}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_population_wdpa_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_population_wdpa_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v1/population/wdpa/{id}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_population_admin_iso" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_population_admin_iso_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v1/population/admin/{iso}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_population_admin_iso_admin" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_population_admin_iso_admin_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v1/population/admin/{iso}/{admin}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_population_admin_iso_admin_admin2" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_population_admin_iso_admin_admin2_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v1/population/admin/{iso}/{admin}/{admin2}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_soil_carbon" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_soil_carbon_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v1/soil-carbon"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_soil_carbon_use_name_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_soil_carbon_use_name_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v1/soil-carbon/use/{name}/{id}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_soil_carbon_wdpa_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_soil_carbon_wdpa_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v1/soil-carbon/wdpa/{id}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_soil_carbon_admin_iso" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_soil_carbon_admin_iso_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v1/soil-carbon/admin/{iso}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_soil_carbon_admin_iso_admin" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_soil_carbon_admin_iso_admin_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v1/soil-carbon/admin/{iso}/{admin}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_soil_carbon_admin_iso_admin_admin2" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_soil_carbon_admin_iso_admin_admin2_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v1/soil-carbon/admin/{iso}/{admin}/{admin2}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_post_v1_forma250gfw" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_forma250gfw_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30500/api/v1/forma250gfw"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_forma250gfw" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_forma250gfw_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v1/forma250gfw"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_forma250gfw_latest" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_forma250gfw_latest_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v1/forma250gfw/latest"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_forma250gfw_use_name_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_forma250gfw_use_name_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v1/forma250gfw/use/{name}/{id}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_forma250gfw_wdpa_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_forma250gfw_wdpa_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v1/forma250gfw/wdpa/{id}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_forma250gfw_admin_iso" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_forma250gfw_admin_iso_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v1/forma250gfw/admin/{iso}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_forma250gfw_admin_iso_admin" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_forma250gfw_admin_iso_admin_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v1/forma250gfw/admin/{iso}/{admin}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_forma250gfw_admin_iso_admin_admin2" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_forma250gfw_admin_iso_admin_admin2_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v1/forma250gfw/admin/{iso}/{admin}/{admin2}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_biomass_loss" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_biomass_loss_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v1/biomass-loss"
  vpc_link     = var.vpc_link
}

module "analysis_gee_post_v1_biomass_loss" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_biomass_loss_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30500/api/v1/biomass-loss"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_biomass_loss_use_name_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_biomass_loss_use_name_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v1/biomass-loss/use/{name}/{id}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_biomass_loss_wdpa_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_biomass_loss_wdpa_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v1/biomass-loss/wdpa/{id}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_biomass_loss_admin_iso" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_biomass_loss_admin_iso_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v1/biomass-loss/admin/{iso}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_biomass_loss_admin_iso_admin" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_biomass_loss_admin_iso_admin_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v1/biomass-loss/admin/{iso}/{admin}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_biomass_loss_admin_iso_admin_admin2" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_biomass_loss_admin_iso_admin_admin2_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v1/biomass-loss/admin/{iso}/{admin}/{admin2}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_loss_by_landcover" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_loss_by_landcover_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v1/loss-by-landcover"
  vpc_link     = var.vpc_link
}

module "analysis_gee_post_v1_loss_by_landcover" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_loss_by_landcover_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30500/api/v1/loss-by-landcover"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_landcover" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_landcover_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v1/landcover"
  vpc_link     = var.vpc_link
}

module "analysis_gee_post_v1_landcover" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_landcover_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30500/api/v1/landcover"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_lansat_tiles_year_z_x_y" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_lansat_tiles_year_z_x_y_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v1/landsat-tiles/{year}/{z}/{x}/{y}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_sentinel_tiles" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_sentinel_tiles_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v1/sentinel-tiles"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_recent_tiles" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_recent_tiles_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v1/recent-tiles"
  vpc_link     = var.vpc_link
}

module "analysis_gee_post_v1_recent_tiles_tiles" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_recent_tiles_tiles_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30500/api/v1/recent-tiles/tiles"
  vpc_link     = var.vpc_link
}

module "analysis_gee_post_v1_recent_tiles_thumbs" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_recent_tiles_tiles_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30500/api/v1/recent-tiles/thumbs"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v2_nlcd_landcover" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_nlcd_landcover_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v2/nlcd-landcover"
  vpc_link     = var.vpc_link
}

module "analysis_gee_post_v2_nlcd_landcover" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_nlcd_landcover_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30500/api/v2/nlcd-landcover"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v2_nlcd_landcover_use_name_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_nlcd_landcover_use_name_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v2/nlcd-landcover/use/{name}/{id}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v2_nlcd_landcover_wdpa_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_nlcd_landcover_wdpa_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v2/nlcd-landcover/wdpa/{id}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v2_nlcd_landcover_admin_iso" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_nlcd_landcover_admin_iso_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v2/nlcd-landcover/admin/{iso}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v2_nlcd_landcover_admin_iso_admin" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_nlcd_landcover_admin_iso_admin_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v2/nlcd-landcover/admin/{iso}/{admin}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v2_nlcd_landcover_admin_iso_admin_admin2" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_nlcd_landcover_admin_iso_admin_admin2_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v2/nlcd-landcover/admin/{iso}/{admin}/{admin2}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v2_biomass_loss" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_biomass_loss_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v2/biomass-loss"
  vpc_link     = var.vpc_link
}

module "analysis_gee_post_v2_biomass_loss" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_biomass_loss_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30500/api/v2/biomass-loss"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v2_biomass_loss_use_name_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_biomass_loss_use_name_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v2/biomass-loss/use/{name}/{id}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v2_biomass_loss_wdpa_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_biomass_loss_wdpa_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v2/biomass-loss/wdpa/{id}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v2_biomass_loss_admin_iso" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_biomass_loss_admin_iso_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v2/biomass-loss/admin/{iso}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v2_biomass_loss_admin_iso_admin" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_biomass_loss_admin_iso_admin_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v2/biomass-loss/admin/{iso}/{admin}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v2_lansat_tiles_year_z_x_y" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_lansat_tiles_year_z_x_y_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v2/landsat-tiles/{year}/{z}/{x}/{y}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v2_biomass_loss_admin_iso_admin_admin2" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_biomass_loss_admin_iso_admin_admin2_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30500/api/v2/biomass-loss/admin/{iso}/{admin}/{admin2}"
  vpc_link     = var.vpc_link
}