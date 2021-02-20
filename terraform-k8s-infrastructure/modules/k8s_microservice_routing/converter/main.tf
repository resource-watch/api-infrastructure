resource "kubernetes_service" "converter_service" {
  metadata {
    name = "converter"
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type"                     = "nlb"
      "service.beta.kubernetes.io/aws-load-balancer-internal"                 = "true"
      "service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags" = "service=converter"
    }
  }
  spec {
    selector = {
      name = "converter"
    }
    port {
      port        = 80
      target_port = 4100
    }

    type = "LoadBalancer"
  }
}

data "aws_lb" "converter_lb" {
  name = split("-", kubernetes_service.converter_service.status.0.load_balancer.0.ingress.0.hostname).0

  depends_on = [
    kubernetes_service.converter_service
  ]
}

resource "aws_api_gateway_vpc_link" "converter_lb_vpc_link" {
  name        = "Converter LB VPC link"
  description = "VPC link to the converter service load balancer"
  target_arns = [data.aws_lb.converter_lb.arn]

  lifecycle {
    create_before_destroy = true
  }
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
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.converter_fs2sql_resource
  method         = "GET"
  uri            = "http://api.resourcewatch.org/api/v1/convert/fs2SQL"
  vpc_link       = aws_api_gateway_vpc_link.converter_lb_vpc_link
}

module "converter_post_converter_fs2sql" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.converter_fs2sql_resource
  method         = "POST"
  uri            = "http://api.resourcewatch.org/api/v1/convert/fs2SQL"
  vpc_link       = aws_api_gateway_vpc_link.converter_lb_vpc_link
}

module "converter_get_converter_sql2fs" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.converter_sql2fs_resource
  method         = "GET"
  uri            = "http://api.resourcewatch.org/api/v1/convert/sql2FS"
  vpc_link       = aws_api_gateway_vpc_link.converter_lb_vpc_link
}

module "converter_post_converter_sql2fs" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.converter_sql2fs_resource
  method         = "POST"
  uri            = "http://api.resourcewatch.org/api/v1/convert/sql2FS"
  vpc_link       = aws_api_gateway_vpc_link.converter_lb_vpc_link
}

module "converter_get_converter_check_sql" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.converter_check_sql_resource
  method         = "GET"
  uri            = "http://api.resourcewatch.org/api/v1/convert/checkSQL"
  vpc_link       = aws_api_gateway_vpc_link.converter_lb_vpc_link
}

module "converter_get_converter_sql2sql" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.converter_sql2sql_resource
  method         = "GET"
  uri            = "http://api.resourcewatch.org/api/v1/convert/sql2SQL"
  vpc_link       = aws_api_gateway_vpc_link.converter_lb_vpc_link
}

module "converter_post_converter_sql2sql" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.converter_sql2sql_resource
  method         = "POST"
  uri            = "http://api.resourcewatch.org/api/v1/convert/sql2SQL"
  vpc_link       = aws_api_gateway_vpc_link.converter_lb_vpc_link
}

module "converter_post_converter_json2sql" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.converter_json2sql_resource
  method         = "POST"
  uri            = "http://api.resourcewatch.org/api/v1/convert/json2SQL"
  vpc_link       = aws_api_gateway_vpc_link.converter_lb_vpc_link
}
