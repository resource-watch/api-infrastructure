resource "kubernetes_service" "converter_service" {
  metadata {
    name = "converter"

  }
  spec {
    selector = {
      name = "converter"
    }
    port {
      port        = 30514
      node_port   = 30514
      target_port = 4100
    }

    type = "NodePort"
  }
}

resource "aws_lb_listener" "convert_nlb_listener" {
  load_balancer_arn = var.load_balancer.arn
  port              = 30514
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.convert_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "convert_lb_target_group" {
  name        = "convert-lb-tg"
  port        = 30514
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_convert" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.convert_lb_target_group.arn
}

// /v1
data "aws_api_gateway_resource" "v1_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1"
}

// /v1/converter
resource "aws_api_gateway_resource" "converter_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "converter"
}

// /v1/converter/fs2SQL
resource "aws_api_gateway_resource" "converter_fs2sql_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.converter_resource.id
  path_part   = "fs2SQL"
}

// /v1/converter/sql2FS
resource "aws_api_gateway_resource" "converter_sql2fs_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.converter_resource.id
  path_part   = "sql2FS"
}

// /v1/converter/checkSQL
resource "aws_api_gateway_resource" "converter_check_sql_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.converter_resource.id
  path_part   = "checkSQL"
}

// /v1/converter/sql2SQL
resource "aws_api_gateway_resource" "converter_sql2sql_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.converter_resource.id
  path_part   = "sql2SQL"
}

// /v1/converter/json2SQL
resource "aws_api_gateway_resource" "converter_json2sql_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.converter_resource.id
  path_part   = "json2SQL"
}

module "converter_get_converter_fs2sql" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.converter_fs2sql_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30514/api/v1/convert/fs2SQL"
  vpc_link     = var.vpc_link
}

module "converter_post_converter_fs2sql" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.converter_fs2sql_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30514/api/v1/convert/fs2SQL"
  vpc_link     = var.vpc_link
}

module "converter_get_converter_sql2fs" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.converter_sql2fs_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30514/api/v1/convert/sql2FS"
  vpc_link     = var.vpc_link
}

module "converter_post_converter_sql2fs" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.converter_sql2fs_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30514/api/v1/convert/sql2FS"
  vpc_link     = var.vpc_link
}

module "converter_get_converter_check_sql" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.converter_check_sql_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30514/api/v1/convert/checkSQL"
  vpc_link     = var.vpc_link
}

module "converter_get_converter_sql2sql" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.converter_sql2sql_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30514/api/v1/convert/sql2SQL"
  vpc_link     = var.vpc_link
}

module "converter_post_converter_sql2sql" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.converter_sql2sql_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30514/api/v1/convert/sql2SQL"
  vpc_link     = var.vpc_link
}

module "converter_post_converter_json2sql" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.converter_json2sql_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30514/api/v1/convert/json2SQL"
  vpc_link     = var.vpc_link
}
