resource "kubernetes_service" "geostore_service" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  metadata {
    name = "geostore"

  }
  spec {
    selector = {
      name = "geostore"
    }
    port {
      port        = 30532
      node_port   = 30532
      target_port = 3100
    }

    type = "NodePort"
  }
}

locals {
  api_gateway_target_url = var.connection_type == "VPC_LINK" ? data.aws_lb.load_balancer[0].dns_name : var.target_url
}

data "aws_lb" "load_balancer" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  arn = var.vpc_link.target_arns[0]
}

resource "aws_lb_listener" "geostore_nlb_listener" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  load_balancer_arn = data.aws_lb.load_balancer[0].arn
  port              = 30532
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.geostore_lb_target_group[0].arn
  }
}

resource "aws_lb_target_group" "geostore_lb_target_group" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  name        = "geostore-lb-tg"
  port        = 30532
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_geostore" {
  count = var.connection_type == "VPC_LINK" ? length(var.eks_asg_names) : 0

  autoscaling_group_name = var.eks_asg_names[count.index]
  lb_target_group_arn    = aws_lb_target_group.geostore_lb_target_group[0].arn
}

#
# V1 Geostore
#


// /v1/geostore
module "v1_geostore_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "geostore"
}

// /v1/geostore/{proxy+}
module "v1_geostore_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_geostore_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

module "geostore_post_v1_geostore" {
  source          = "../../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_geostore_resource.aws_api_gateway_resource
  method          = "POST"
  uri             = "http://${local.api_gateway_target_url}:30532/api/v1/geostore"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
  require_api_key = var.require_api_key
}

module "geostore_any_v1_geostore_proxy" {
  source          = "../../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_geostore_proxy_resource.aws_api_gateway_resource
  method          = "ANY"
  uri             = "http://${local.api_gateway_target_url}:30532/api/v1/geostore/{proxy}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
  require_api_key = var.require_api_key
}

#
# V1 Coverage
#

// /v1/coverage
module "v1_coverage_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "coverage"
}

// /v1/coverage/{proxy+}
module "v1_coverage_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_coverage_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

module "geostore_any_v1_coverage_proxy" {
  source          = "../../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_coverage_proxy_resource.aws_api_gateway_resource
  method          = "ANY"
  uri             = "http://${local.api_gateway_target_url}:30532/api/v1/coverage/{proxy}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
  require_api_key = var.require_api_key
}

#
# V2 Geostore
#

// /v2/geostore
module "v2_geostore_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v2_resource.id
  path_part   = "geostore"
}

// /v2/geostore/{proxy+}
module "v2_geostore_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v2_geostore_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

module "geostore_post_v2_geostore" {
  source          = "../../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v2_geostore_resource.aws_api_gateway_resource
  method          = "POST"
  uri             = "http://${local.api_gateway_target_url}:30532/api/v2/geostore"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
  require_api_key = var.require_api_key
}

module "geostore_any_v2_geostore_proxy" {
  source          = "../../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v2_geostore_proxy_resource.aws_api_gateway_resource
  method          = "ANY"
  uri             = "http://${local.api_gateway_target_url}:30532/api/v2/geostore/{proxy}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
  require_api_key = var.require_api_key
}

#
# V2 Coverage
#

// /v2/coverage
module "v2_coverage_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v2_resource.id
  path_part   = "coverage"
}

// /v2/coverage/{proxy+}
module "v2_coverage_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v2_coverage_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

module "geostore_any_v2_coverage_proxy" {
  source          = "../../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v2_coverage_proxy_resource.aws_api_gateway_resource
  method          = "ANY"
  uri             = "http://${local.api_gateway_target_url}:30532/api/v2/coverage/{proxy}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
  require_api_key = var.require_api_key
}
