resource "kubernetes_service" "authorization_service" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  metadata {
    name      = "authorization"
    namespace = "core"

  }
  spec {
    selector = {
      name = "authorization"
    }
    port {
      port        = 30505
      node_port   = 30505
      target_port = 9000
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

resource "aws_lb_listener" "authorization_nlb_listener" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  load_balancer_arn = data.aws_lb.load_balancer[0].arn
  port              = 30505
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.authorization_lb_target_group[0].arn
  }
}

resource "aws_lb_target_group" "authorization_lb_target_group" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  name        = "authorization-lb-tg"
  port        = 30505
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_authorization" {
  count = var.connection_type == "VPC_LINK" ? length(var.eks_asg_names) : 0

  autoscaling_group_name = var.eks_asg_names[count.index]
  lb_target_group_arn    = aws_lb_target_group.authorization_lb_target_group[0].arn
}

// /auth
module "authorization_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.root_resource_id
  path_part   = "auth"
}
// /auth/{proxy+}
module "authorization_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.authorization_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

// /v1/deletion
module "v1_deletion_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "deletion"
}

// /v1/deletion/{proxy+}
module "v1_deletion_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_deletion_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

// /v1/request
module "v1_request_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "request"
}

// /v1/request/validate
module "v1_request_validate_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_request_resource.aws_api_gateway_resource.id
  path_part   = "validate"
}

// /v1/organization
module "v1_organization_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "organization"
}

// /v1/organization/{proxy+}
module "v1_organization_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_organization_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

// /v1/application
module "v1_application_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "application"
}

// /v1/application/{proxy+}
module "v1_application_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_application_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

module "authorization_any_proxy" {
  source          = "../../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.authorization_proxy_resource.aws_api_gateway_resource
  method          = "ANY"
  uri             = "http://${local.api_gateway_target_url}:30505/auth/{proxy}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
  require_api_key = false
}

module "authorization_get" {
  source          = "../../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.authorization_resource.aws_api_gateway_resource
  method          = "GET"
  uri             = "http://${local.api_gateway_target_url}:30505/auth"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
  require_api_key = false
}

module "authorization_get_v1_deletion" {
  source          = "../../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_deletion_resource.aws_api_gateway_resource
  method          = "GET"
  uri             = "http://${local.api_gateway_target_url}:30505/api/v1/deletion"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
  require_api_key = var.require_api_key
}

module "authorization_post_v1_deletion" {
  source          = "../../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_deletion_resource.aws_api_gateway_resource
  method          = "POST"
  uri             = "http://${local.api_gateway_target_url}:30505/api/v1/deletion"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
  require_api_key = var.require_api_key
}

module "authorization_any_v1_deletion_proxy" {
  source          = "../../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_deletion_proxy_resource.aws_api_gateway_resource
  method          = "ANY"
  uri             = "http://${local.api_gateway_target_url}:30505/api/v1/deletion/{proxy}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
  require_api_key = var.require_api_key
}

module "authorization_get_v1_organization" {
  source          = "../../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_organization_resource.aws_api_gateway_resource
  method          = "GET"
  uri             = "http://${local.api_gateway_target_url}:30505/api/v1/organization"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
  require_api_key = false
}

module "authorization_post_v1_organization" {
  source          = "../../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_organization_resource.aws_api_gateway_resource
  method          = "POST"
  uri             = "http://${local.api_gateway_target_url}:30505/api/v1/organization"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
  require_api_key = false
}

module "authorization_any_v1_organization_proxy" {
  source          = "../../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_organization_proxy_resource.aws_api_gateway_resource
  method          = "ANY"
  uri             = "http://${local.api_gateway_target_url}:30505/api/v1/organization/{proxy}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
  require_api_key = false
}

module "authorization_get_v1_application" {
  source          = "../../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_application_resource.aws_api_gateway_resource
  method          = "GET"
  uri             = "http://${local.api_gateway_target_url}:30505/api/v1/application"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
  require_api_key = false
}

module "authorization_post_v1_application" {
  source          = "../../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_application_resource.aws_api_gateway_resource
  method          = "POST"
  uri             = "http://${local.api_gateway_target_url}:30505/api/v1/application"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
  require_api_key = false
}

module "authorization_any_v1_application_proxy" {
  source          = "../../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_application_proxy_resource.aws_api_gateway_resource
  method          = "ANY"
  uri             = "http://${local.api_gateway_target_url}:30505/api/v1/application/{proxy}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
  require_api_key = false
}

module "authorization_post_v1_request_validate" {
  source          = "../../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_request_validate_resource.aws_api_gateway_resource
  method          = "POST"
  uri             = "http://${local.api_gateway_target_url}:30505/api/v1/request/validate"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
  require_api_key = false
}
