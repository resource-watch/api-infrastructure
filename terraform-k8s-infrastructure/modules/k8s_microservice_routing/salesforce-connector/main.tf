resource "kubernetes_service" "salesforce_connector_service" {
  metadata {
    name      = "salesforce-connector"
    namespace = "gfw"
  }
  spec {
    selector = {
      name = "salesforce-connector"
    }
    port {
      port        = 30569
      node_port   = 30569
      target_port = 9500
    }

    type = "NodePort"
  }
}

data "aws_lb" "load_balancer" {
  arn = var.vpc_link.target_arns[0]
}

resource "aws_lb_listener" "salesforce_connector_nlb_listener" {
  load_balancer_arn = data.aws_lb.load_balancer.arn
  port              = 30569
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.salesforce_connector_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "salesforce_connector_lb_target_group" {
  name        = "salesforce-connector-lb-tg"
  port        = 30569
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_salesforce_connector" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.salesforce_connector_lb_target_group.arn
}

// /v1/salesforce
module "v1_salesforce_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "salesforce"
}

// /v1/salesforce/{proxy+}
module "v1_salesforce_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_salesforce_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

module "salesforce_connector_any_v1_user_proxy" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_salesforce_proxy_resource.aws_api_gateway_resource
  method       = "ANY"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30569/api/v1/salesforce/{proxy}"
  vpc_link     = var.vpc_link
}
