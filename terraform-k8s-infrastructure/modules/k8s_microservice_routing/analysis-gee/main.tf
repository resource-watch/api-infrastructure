resource "kubernetes_service" "analysis_gee_service" {
  metadata {
    name      = "analysis-gee"
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

data "aws_lb" "load_balancer" {
  arn = var.vpc_link.target_arns[0]
}

resource "aws_lb_listener" "analysis_gee_nlb_listener" {
  load_balancer_arn = data.aws_lb.load_balancer.arn
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


// /v1/recent-tiles-classifier
module "v1_recent_tiles_classifier_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "recent-tiles-classifier"
}

// /v1/composite-service
module "v1_composite_service_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "composite-service"
}

// /v1/composite-service/geom
module "v1_composite_service_geom_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_composite_service_resource.aws_api_gateway_resource.id
  path_part   = "geom"
}

// /v1/mc-analysis
module "v1_mc_analysis_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "mc-analysis"
}

// /v1/geodescriber
module "v1_geodescriber_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "geodescriber"
}

// /v1/geodescriber/geom
module "v1_geodescriber_geom_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_geodescriber_resource.aws_api_gateway_resource.id
  path_part   = "geom"
}

// /v1/umd-loss-gain
module "v1_umd_loss_gain_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "umd-loss-gain"
}

// /v1/umd-loss-gain/{proxy+}
module "v1_umd_loss_gain_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_umd_loss_gain_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

// /v1/whrc-biomass
module "v1_whrc_biomass_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "whrc-biomass"
}

// /v1/whrc-biomass/{proxy+}
module "v1_whrc_biomass_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_whrc_biomass_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

// /v1/mangrove-biomass
module "v1_mangrove_biomass_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "mangrove-biomass"
}

// /v1/mangrove-biomass/{proxy+}
module "v1_mangrove_biomass_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_mangrove_biomass_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

// /v1/population
module "v1_population_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "population"
}

// /v1/population/{proxy+}
module "v1_population_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_population_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

// /v1/soil-carbon
module "v1_soil_carbon_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "soil-carbon"
}

// /v1/soil-carbon/{proxy+}
module "v1_soil_carbon_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_soil_carbon_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

// /v1/forma250gfw
module "v1_forma250gfw_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "forma250gfw"
}

// /v1/forma250gfw/{proxy+}
module "v1_forma250gfw_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_forma250gfw_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

// /v1/biomass-loss
module "v1_biomass_loss_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "biomass-loss"
}

// /v1/biomass-loss/{proxy+}
module "v1_biomass_loss_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_biomass_loss_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

// /v1/loss-by-landcover
module "v1_loss_by_landcover_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "loss-by-landcover"
}

// /v1/landcover
module "v1_landcover_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "landcover"
}

// /v1/landsat-tiles
module "v1_landsat_tiles_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "landsat-tiles"
}

// /v1/landsat-tiles/{proxy+}
module "v1_landsat_tiles_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_landsat_tiles_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

// /v1/sentinel-tiles
module "v1_sentinel_tiles_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "sentinel-tiles"
}

// /v1/recent-tiles
module "v1_recent_tiles_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "recent-tiles"
}

// /v1/recent-tiles/{proxy+}
module "v1_recent_tiles_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_recent_tiles_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

// v2
// /v2/nlcd-landcover
module "v2_nlcd_landcover_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v2_resource.id
  path_part   = "nlcd-landcover"
}

// /v2/nlcd-landcover/{proxy+}
module "v2_nlcd_landcover_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v2_nlcd_landcover_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

// /v2/biomass-loss
module "v2_biomass_loss_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v2_resource.id
  path_part   = "biomass-loss"
}

// /v2/biomass-loss/{proxy+}
module "v2_biomass_loss_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v2_biomass_loss_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

// /v2/landsat-tiles
module "v2_landsat_tiles_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v2_resource.id
  path_part   = "landsat-tiles"
}

// /v2/landsat-tiles/{proxy+}
module "v2_landsat_tiles_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v2_landsat_tiles_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

module "analysis_gee_get_v1_recent_tiles_classifier" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_recent_tiles_classifier_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30500/api/v1/recent-tiles-classifier"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_composite_service" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_composite_service_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30500/api/v1/composite-service"
  vpc_link     = var.vpc_link
}

module "analysis_gee_post_v1_mc_analysis" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_mc_analysis_resource.aws_api_gateway_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30500/api/v1/mc-analysis"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_composite_service_geom" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_composite_service_geom_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30500/api/v1/composite-service/geom"
  vpc_link     = var.vpc_link
}

module "analysis_gee_post_v1_composite_service_geom" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_composite_service_geom_resource.aws_api_gateway_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30500/api/v1/composite-service/geom"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_geodescriber" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_geodescriber_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30500/api/v1/geodescriber"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_geodescriber_geom" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_geodescriber_geom_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30500/api/v1/geodescriber/geom"
  vpc_link     = var.vpc_link
}

module "analysis_gee_post_v1_geodescriber_geom" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_geodescriber_geom_resource.aws_api_gateway_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30500/api/v1/geodescriber/geom"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_umd_loss_gain" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_umd_loss_gain_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30500/api/v1/umd-loss-gain"
  vpc_link     = var.vpc_link
}

module "analysis_gee_post_v1_umd_loss_gain" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_umd_loss_gain_resource.aws_api_gateway_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30500/api/v1/umd-loss-gain"
  vpc_link     = var.vpc_link
}

module "analysis_gee_any_v1_umd_loss_gain_proxy" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_umd_loss_gain_proxy_resource.aws_api_gateway_resource
  method       = "ANY"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30500/api/v1/umd-loss-gain/{proxy}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_whrc_biomass" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_whrc_biomass_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30500/api/v1/whrc-biomass"
  vpc_link     = var.vpc_link
}

module "analysis_gee_post_v1_whrc_biomass" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_whrc_biomass_resource.aws_api_gateway_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30500/api/v1/whrc-biomass"
  vpc_link     = var.vpc_link
}

module "analysis_gee_any_v1_whrc_biomass_proxy" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_whrc_biomass_proxy_resource.aws_api_gateway_resource
  method       = "ANY"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30500/api/v1/whrc-biomass/{proxy}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_post_v1_mangrove_biomass" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_mangrove_biomass_resource.aws_api_gateway_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30500/api/v1/mangrove-biomass"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_mangrove_biomass" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_mangrove_biomass_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30500/api/v1/mangrove-biomass"
  vpc_link     = var.vpc_link
}

module "analysis_gee_any_v1_mangrove_biomass_proxy" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_mangrove_biomass_proxy_resource.aws_api_gateway_resource
  method       = "ANY"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30500/api/v1/mangrove-biomass/{proxy}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_population" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_population_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30500/api/v1/population"
  vpc_link     = var.vpc_link
}

module "analysis_gee_post_v1_population" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_population_resource.aws_api_gateway_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30500/api/v1/population"
  vpc_link     = var.vpc_link
}

module "analysis_gee_any_v1_population_proxy" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_population_proxy_resource.aws_api_gateway_resource
  method       = "ANY"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30500/api/v1/population/{proxy}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_soil_carbon" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_soil_carbon_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30500/api/v1/soil-carbon"
  vpc_link     = var.vpc_link
}

module "analysis_gee_any_v1_soil_carbon_proxy" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_soil_carbon_proxy_resource.aws_api_gateway_resource
  method       = "ANY"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30500/api/v1/soil-carbon/{proxy}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_post_v1_forma250gfw" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_forma250gfw_resource.aws_api_gateway_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30500/api/v1/forma250gfw"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_forma250gfw" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_forma250gfw_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30500/api/v1/forma250gfw"
  vpc_link     = var.vpc_link
}

module "analysis_gee_any_v1_forma250gfw_proxy" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_forma250gfw_proxy_resource.aws_api_gateway_resource
  method       = "ANY"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30500/api/v1/forma250gfw/{proxy}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_biomass_loss" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_biomass_loss_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30500/api/v1/biomass-loss"
  vpc_link     = var.vpc_link
}

module "analysis_gee_post_v1_biomass_loss" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_biomass_loss_resource.aws_api_gateway_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30500/api/v1/biomass-loss"
  vpc_link     = var.vpc_link
}

module "analysis_gee_any_v1_biomass_loss_proxy" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_biomass_loss_proxy_resource.aws_api_gateway_resource
  method       = "ANY"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30500/api/v1/biomass-loss/{proxy}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_loss_by_landcover" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_loss_by_landcover_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30500/api/v1/loss-by-landcover"
  vpc_link     = var.vpc_link
}

module "analysis_gee_post_v1_loss_by_landcover" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_loss_by_landcover_resource.aws_api_gateway_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30500/api/v1/loss-by-landcover"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_landcover" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_landcover_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30500/api/v1/landcover"
  vpc_link     = var.vpc_link
}

module "analysis_gee_post_v1_landcover" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_landcover_resource.aws_api_gateway_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30500/api/v1/landcover"
  vpc_link     = var.vpc_link
}

module "analysis_gee_any_v1_landsat_tiles_proxy" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_landsat_tiles_proxy_resource.aws_api_gateway_resource
  method       = "ANY"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30500/api/v1/landsat-tiles/{proxy}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_sentinel_tiles" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_sentinel_tiles_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30500/api/v1/sentinel-tiles"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v1_recent_tiles" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_recent_tiles_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30500/api/v1/recent-tiles"
  vpc_link     = var.vpc_link
}

module "analysis_gee_any_v1_recent_tiles_proxy" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_recent_tiles_proxy_resource.aws_api_gateway_resource
  method       = "ANY"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30500/api/v1/recent-tiles/{proxy}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_any_v2_landsat_tiles_proxy" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v2_landsat_tiles_proxy_resource.aws_api_gateway_resource
  method       = "ANY"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30500/api/v2/landsat-tiles/{proxy}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v2_nlcd_landcover" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v2_nlcd_landcover_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30500/api/v2/nlcd-landcover"
  vpc_link     = var.vpc_link
}

module "analysis_gee_post_v2_nlcd_landcover" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v2_nlcd_landcover_resource.aws_api_gateway_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30500/api/v2/nlcd-landcover"
  vpc_link     = var.vpc_link
}

module "analysis_gee_any_v2_nlcd_landcover_proxy" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v2_nlcd_landcover_proxy_resource.aws_api_gateway_resource
  method       = "ANY"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30500/api/v2/nlcd-landcover/{proxy}"
  vpc_link     = var.vpc_link
}

module "analysis_gee_get_v2_biomass_loss" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v2_biomass_loss_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30500/api/v2/biomass-loss"
  vpc_link     = var.vpc_link
}

module "analysis_gee_post_v2_biomass_loss" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v2_biomass_loss_resource.aws_api_gateway_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30500/api/v2/biomass-loss"
  vpc_link     = var.vpc_link
}

module "analysis_gee_any_v2_biomass_loss_proxy" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v2_biomass_loss_proxy_resource.aws_api_gateway_resource
  method       = "ANY"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30500/api/v2/biomass-loss/{proxy}"
  vpc_link     = var.vpc_link
}