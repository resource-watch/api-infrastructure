resource "kubernetes_service" "arcgis_proxy_service" {
  metadata {
    name = "arcgis-proxy"
    namespace = "gfw"
  }
  spec {
    selector = {
      name = "arcgis-proxy"
    }
    port {
      port        = 30503
      node_port   = 30503
      target_port = 5700
    }

    type = "NodePort"
  }
}

resource "aws_lb_listener" "arcgis_proxy_nlb_listener" {
  load_balancer_arn = var.load_balancer.arn
  port              = 30503
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.arcgis_proxy_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "arcgis_proxy_lb_target_group" {
  name        = "arcgis-proxy-lb-tg"
  port        = 30503
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_arcgis_proxy" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.arcgis_proxy_lb_target_group.arn
}

// /v1
data "aws_api_gateway_resource" "v1_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1"
}

// /v1/arcgis-proxy
resource "aws_api_gateway_resource" "v1_arcgis_proxy_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "arcgis-proxy"
}

// /v1/arcgis-proxy/ImageServer
resource "aws_api_gateway_resource" "v1_arcgis_proxy_image_server_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_arcgis_proxy_resource.id
  path_part   = "arcgis-ImageServer"
}

// /v1/arcgis-proxy/ImageServer/computeHistograms
resource "aws_api_gateway_resource" "v1_arcgis_proxy_image_server_compute_histograms_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_arcgis_proxy_image_server_resource.id
  path_part   = "computeHistograms"
}

module "arcgis_proxy_get_v1_arcgis_proxy_image_server_compute_histograms" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_arcgis_proxy_image_server_compute_histograms_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30503/api/v1/arcgis-proxy/ImageServer/computeHistograms"
  vpc_link     = var.vpc_link
}