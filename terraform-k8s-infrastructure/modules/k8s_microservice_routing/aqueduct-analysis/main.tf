resource "kubernetes_service" "aqueduct_analysis_service" {
  metadata {
    name = "aqueduct-analysis"
    namespace = "aqueduct"
  }
  spec {
    selector = {
      name = "aqueduct-analysis"
    }
    port {
      port        = 30501
      node_port   = 30501
      target_port = 5700
    }

    type = "NodePort"
  }
}

resource "aws_lb_listener" "aqueduct_analysis_nlb_listener" {
  load_balancer_arn = var.load_balancer.arn
  port              = 30501
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.aqueduct_analysis_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "aqueduct_analysis_lb_target_group" {
  name        = "aqueduct-analysis-lb-tg"
  port        = 30501
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_aqueduct_analysis" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.aqueduct_analysis_lb_target_group.arn
}

// /v1
data "aws_api_gateway_resource" "v1_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1"
}

// /v1/aqueduct
resource "aws_api_gateway_resource" "v1_aqueduct_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "aqueduct"
}

// /v1/aqueduct/analysis
resource "aws_api_gateway_resource" "v1_aqueduct_analysis_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_aqueduct_resource.id
  path_part   = "analysis"
}

// /v1/aqueduct/analysis/cba
resource "aws_api_gateway_resource" "v1_aqueduct_analysis_cba_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_aqueduct_analysis_resource.id
  path_part   = "cba"
}

// /v1/aqueduct/analysis/cba/default
resource "aws_api_gateway_resource" "v1_aqueduct_analysis_cba_default_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_aqueduct_analysis_cba_resource.id
  path_part   = "default"
}

// /v1/aqueduct/analysis/cba/expire-cache
resource "aws_api_gateway_resource" "v1_aqueduct_analysis_cba_expire_cache_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_aqueduct_analysis_cba_resource.id
  path_part   = "expire-cache"
}

// /v1/aqueduct/analysis/cba/widget
resource "aws_api_gateway_resource" "v1_aqueduct_analysis_cba_widget_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_aqueduct_analysis_cba_resource.id
  path_part   = "widget"
}

// /v1/aqueduct/analysis/cba/widget/{widgetId}
resource "aws_api_gateway_resource" "v1_aqueduct_analysis_cba_widget_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_aqueduct_analysis_cba_widget_resource.id
  path_part   = "{widgetId}"
}

// /v1/aqueduct/analysis/risk
resource "aws_api_gateway_resource" "v1_aqueduct_analysis_risk_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_aqueduct_analysis_resource.id
  path_part   = "risk"
}

// /v1/aqueduct/analysis/risk/widget
resource "aws_api_gateway_resource" "v1_aqueduct_analysis_risk_widget_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_aqueduct_analysis_risk_resource.id
  path_part   = "widget"
}

// /v1/aqueduct/analysis/risk/widget/{widgetId}
resource "aws_api_gateway_resource" "v1_aqueduct_analysis_risk_widget_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_aqueduct_analysis_risk_widget_resource.id
  path_part   = "{widgetId}"
}

module "aqueduct_analysis_get_v1_aqueduct_analysis" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_aqueduct_analysis_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30501/api/v1/aqueduct/analysis"
  vpc_link     = var.vpc_link
}

module "aqueduct_analysis_post_v1_aqueduct_analysis" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_aqueduct_analysis_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30501/api/v1/aqueduct/analysis"
  vpc_link     = var.vpc_link
}

module "aqueduct_analysis_get_v1_aqueduct_analysis_cba" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_aqueduct_analysis_cba_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30501/api/v1/aqueduct/analysis/cba"
  vpc_link     = var.vpc_link
}

module "aqueduct_analysis_get_v1_aqueduct_analysis_cba_default" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_aqueduct_analysis_cba_default_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30501/api/v1/aqueduct/analysis/cba/default"
  vpc_link     = var.vpc_link
}

module "aqueduct_analysis_get_v1_aqueduct_analysis_cba_widget_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_aqueduct_analysis_cba_widget_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30501/api/v1/aqueduct/analysis/cba/widget/{widgetId}"
  vpc_link     = var.vpc_link
}

module "aqueduct_analysis_delete_v1_aqueduct_analysis_cba_expire_cache" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.v1_aqueduct_analysis_cba_expire_cache_resource
  method         = "DELETE"
  backend_method = "POST"
  uri            = "http://api.resourcewatch.org:30501/api/v1/aqueduct/analysis/cba/expire-cache"
  vpc_link       = var.vpc_link
}

module "aqueduct_analysis_get_v1_aqueduct_analysis_risk_widget_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_aqueduct_analysis_risk_widget_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30501/api/v1/aqueduct/analysis/risk/widget/{widgetId}"
  vpc_link     = var.vpc_link
}
