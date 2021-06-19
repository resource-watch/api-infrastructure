resource "kubernetes_service" "resource_watch_manager_service" {
  metadata {
    name      = "resource-watch-manager"
    namespace = "rw"
  }
  spec {
    selector = {
      name = "resource-watch-manager"
    }
    port {
      port        = 30558
      node_port   = 30558
      target_port = 3000
    }

    type = "NodePort"
  }
}

data "aws_lb" "load_balancer" {
  arn = var.vpc_link.target_arns[0]
}

resource "aws_lb_listener" "resource_watch_manager_nlb_listener" {
  load_balancer_arn = data.aws_lb.load_balancer.arn
  port              = 30558
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.resource_watch_manager_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "resource_watch_manager_lb_target_group" {
  name        = "resource-watch-manager-lb-tg"
  port        = 30558
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_resource_watch_manager" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.resource_watch_manager_lb_target_group.arn
}

// /v1/dashboard
module "v1_dashboard_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "dashboard"
}

// /v1/dashboard/{proxy+}
module "v1_dashboard_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_dashboard_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

// /v1/partner
module "v1_partner_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "partner"
}

// /v1/partner/{partnerId}
module "v1_partner_id_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_partner_resource.aws_api_gateway_resource.id
  path_part   = "{partnerId}"
}

// /v1/static_page
module "v1_static_page_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "static_page"
}

// /v1/static_page/{staticPageId}
module "v1_static_page_id_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_static_page_resource.aws_api_gateway_resource.id
  path_part   = "{staticPageId}"
}

// /v1/topic
module "v1_topic_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "topic"
}

// /v1/topic/{topicId}
module "v1_topic_id_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_topic_resource.aws_api_gateway_resource.id
  path_part   = "{topicId}"
}

// /v1/topic/{proxy+}
module "v1_topic_id_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_topic_id_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

// /v1/tool
module "v1_tool_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "tool"
}

// /v1/tool/{toolId}
module "v1_tool_id_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_tool_resource.aws_api_gateway_resource.id
  path_part   = "{toolId}"
}

// /v1/profile
module "v1_profile_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "profile"
}

// /v1/profile/{profileId}
module "v1_profile_id_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_profile_resource.aws_api_gateway_resource.id
  path_part   = "{profileId}"
}

// /v1/faq
module "v1_faq_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "faq"
}

// /v1/faq/{proxy+}
module "v1_faq_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_faq_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

// /v1/temporary_content_image
module "v1_temporary_content_image_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "temporary_content_image"
}

// /v1/contact-us
module "v1_contact_us_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "contact-us"
}

module "resource_watch_manager_get_v1_dashboard" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_dashboard_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30558/api/dashboards"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_post_v1_dashboard" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_dashboard_resource.aws_api_gateway_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30558/api/dashboards"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_any_v1_dashboard_proxy" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_dashboard_proxy_resource.aws_api_gateway_resource
  method       = "ANY"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30558/api/dashboards/{proxy}"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_get_v1_partner" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_partner_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30558/api/partners"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_post_v1_partner" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_partner_resource.aws_api_gateway_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30558/api/partners"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_get_v1_partner_id" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_partner_id_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30558/api/partners/{partnerId}"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_patch_v1_partner_id" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_partner_id_resource.aws_api_gateway_resource
  method       = "PATCH"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30558/api/partners/{partnerId}"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_put_v1_partner_id" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_partner_id_resource.aws_api_gateway_resource
  method       = "PUT"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30558/api/partners/{partnerId}"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_delete_v1_partner_id" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_partner_id_resource.aws_api_gateway_resource
  method       = "DELETE"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30558/api/partners/{partnerId}"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_get_v1_static_page" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_static_page_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30558/api/static_pages"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_post_v1_static_page" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_static_page_resource.aws_api_gateway_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30558/api/static_pages"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_get_v1_static_page_id" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_static_page_id_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30558/api/static_pages/{staticPageId}"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_patch_v1_static_page_id" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_static_page_id_resource.aws_api_gateway_resource
  method       = "PATCH"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30558/api/static_pages/{staticPageId}"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_put_v1_static_page_id" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_static_page_id_resource.aws_api_gateway_resource
  method       = "PUT"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30558/api/static_pages/{staticPageId}"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_delete_v1_static_page_id" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_static_page_id_resource.aws_api_gateway_resource
  method       = "DELETE"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30558/api/static_pages/{staticPageId}"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_get_v1_topic_page" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_topic_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30558/api/topics"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_any_v1_topic_id_proxy_page" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_topic_id_proxy_resource.aws_api_gateway_resource
  method       = "ANY"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30558/api/topics/{proxy}"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_post_v1_topic" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_topic_resource.aws_api_gateway_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30558/api/topics"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_get_v1_topic_id" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_topic_id_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30558/api/topics/{topicId}"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_patch_v1_topic_id" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_topic_id_resource.aws_api_gateway_resource
  method       = "PATCH"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30558/api/topics/{topicId}"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_put_v1_topic_id" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_topic_id_resource.aws_api_gateway_resource
  method       = "PUT"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30558/api/topics/{topicId}"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_delete_v1_topic_id" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_topic_id_resource.aws_api_gateway_resource
  method       = "DELETE"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30558/api/topics/{topicId}"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_get_v1_tool" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_tool_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30558/api/tools"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_post_v1_tool" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_tool_resource.aws_api_gateway_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30558/api/tools"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_get_v1_tool_id" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_tool_id_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30558/api/tools/{toolId}"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_patch_v1_tool_id" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_tool_id_resource.aws_api_gateway_resource
  method       = "PATCH"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30558/api/tools/{toolId}"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_put_v1_tool_id" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_tool_id_resource.aws_api_gateway_resource
  method       = "PUT"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30558/api/tools/{toolId}"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_delete_v1_tool_id" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_tool_id_resource.aws_api_gateway_resource
  method       = "DELETE"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30558/api/tools/{toolId}"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_post_v1_profile" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_profile_resource.aws_api_gateway_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30558/api/profiles"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_get_v1_profile_id" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_profile_id_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30558/api/profiles/{profileId}"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_patch_v1_profile_id" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_profile_id_resource.aws_api_gateway_resource
  method       = "PATCH"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30558/api/profiles/{profileId}"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_put_v1_profile_id" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_profile_id_resource.aws_api_gateway_resource
  method       = "PUT"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30558/api/profiles/{profileId}"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_delete_v1_profile_id" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_profile_id_resource.aws_api_gateway_resource
  method       = "DELETE"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30558/api/profiles/{profileId}"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_get_v1_faq" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_faq_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30558/api/faqs"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_post_v1_faq" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_faq_resource.aws_api_gateway_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30558/api/faqs"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_any_v1_faq_proxy" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_faq_proxy_resource.aws_api_gateway_resource
  method       = "ANY"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30558/api/faqs/{proxy}"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_post_v1_temporary_content_image" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_temporary_content_image_resource.aws_api_gateway_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30558/api/temporary_content_image"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_post_v1_contact_us" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_contact_us_resource.aws_api_gateway_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30558/api/contact-us"
  vpc_link     = var.vpc_link
}