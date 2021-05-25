resource "kubernetes_service" "arcgis_service" {
  metadata {
    name = "arcgis"

  }
  spec {
    selector = {
      name = "arcgis"
    }
    port {
      port        = 30502
      node_port   = 30502
      target_port = 3055
    }

    type = "NodePort"
  }
}

data "aws_lb" "load_balancer" {
  arn  = var.vpc_link.target_arns[0]
}

resource "aws_lb_listener" "arcgis_nlb_listener" {
  load_balancer_arn = data.aws_lb.load_balancer.arn
  port              = 30502
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.arcgis_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "arcgis_lb_target_group" {
  name        = "arcgis-lb-tg"
  port        = 30502
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_arcgis" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.arcgis_lb_target_group.arn
}

// /v1/query/featureservice
resource "aws_api_gateway_resource" "v1_query_featureservice_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_query_resource.id
  path_part   = "featureservice"
}

// /v1/query/featureservice/{datasetId}
resource "aws_api_gateway_resource" "v1_query_featureservice_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_query_featureservice_resource.id
  path_part   = "{datasetId}"
}

// /v1/download/featureservice
resource "aws_api_gateway_resource" "v1_download_featureservice_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_download_resource.id
  path_part   = "featureservice"
}

// /v1/download/featureservice/{datasetId}
resource "aws_api_gateway_resource" "v1_download_featureservice_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_download_featureservice_resource.id
  path_part   = "{datasetId}"
}

// /v1/fields/featureservice
resource "aws_api_gateway_resource" "v1_fields_featureservice_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_fields_resource.id
  path_part   = "featureservice"
}

// /v1/fields/featureservice/{datasetId}
resource "aws_api_gateway_resource" "v1_fields_featureservice_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_fields_featureservice_resource.id
  path_part   = "{datasetId}"
}

// /v1/rest-datasets/featureservice
resource "aws_api_gateway_resource" "v1_rest_datasets_featureservice_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_rest_datasets_resource.id
  path_part   = "featureservice"
}

// /v1/rest-datasets/featureservice/{datasetId}
resource "aws_api_gateway_resource" "v1_rest_datasets_featureservice_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_rest_datasets_featureservice_resource.id
  path_part   = "{datasetId}"
}

module "arcgis_get_v1_query_featureservice_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_query_featureservice_dataset_id_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30502/api/v1/arcgis/query/{datasetId}"
  vpc_link     = var.vpc_link
}

module "arcgis_post_v1_query_featureservice_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_query_featureservice_dataset_id_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30502/api/v1/arcgis/query/{datasetId}"
  vpc_link     = var.vpc_link
}

module "arcgis_get_v1_download_featureservice_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_download_featureservice_dataset_id_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30502/api/v1/arcgis/download/{datasetId}"
  vpc_link     = var.vpc_link
}

module "arcgis_post_v1_download_featureservice_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_download_featureservice_dataset_id_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30502/api/v1/arcgis/download/{datasetId}"
  vpc_link     = var.vpc_link
}

module "arcgis_get_v1_fields_featureservice_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_fields_featureservice_dataset_id_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30502/api/v1/arcgis/fields/{datasetId}"
  vpc_link     = var.vpc_link
}

module "arcgis_post_v1_rest_datasets_featureservice" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_rest_datasets_featureservice_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30502/api/v1/arcgis/rest-datasets/featureservice"
  vpc_link     = var.vpc_link
}

module "arcgis_delete_v1_rest_datasets_featureservice_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_rest_datasets_featureservice_dataset_id_resource
  method       = "DELETE"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30502/api/v1/arcgis/rest-datasets/featureservice/{datasetId}"
  vpc_link     = var.vpc_link
}
