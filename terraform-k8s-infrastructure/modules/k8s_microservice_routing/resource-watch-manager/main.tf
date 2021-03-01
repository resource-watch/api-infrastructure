resource "kubernetes_service" "resource_watch_manager_service" {
  metadata {
    name = "resource-watch-manager"
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


resource "aws_lb_listener" "resource_watch_manager_nlb_listener" {
  load_balancer_arn = var.load_balancer.arn
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

// /v1
data "aws_api_gateway_resource" "v1_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1"
}

// /v1/dashboard
resource "aws_api_gateway_resource" "v1_dashboard_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "dashboard"
}

// /v1/dashboard/{dashboardId}
resource "aws_api_gateway_resource" "v1_dashboard_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_dashboard_resource.id
  path_part   = "{dashboardId}"
}

// /v1/dashboard/{dashboardId}/clone
resource "aws_api_gateway_resource" "v1_dashboard_id_clone_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_dashboard_id_resource.id
  path_part   = "clone"
}

// /v1/partner
resource "aws_api_gateway_resource" "v1_partner_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "partner"
}

// /v1/partner/{partnerId}
resource "aws_api_gateway_resource" "v1_partner_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_partner_resource.id
  path_part   = "{partnerId}"
}

// /v1/static_page
resource "aws_api_gateway_resource" "v1_static_page_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "static_page"
}

// /v1/static_page/{staticPageId}
resource "aws_api_gateway_resource" "v1_static_page_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_static_page_resource.id
  path_part   = "{staticPageId}"
}

// /v1/topic
resource "aws_api_gateway_resource" "v1_topic_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "topic"
}

// /v1/topic/{topicId}
resource "aws_api_gateway_resource" "v1_topic_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_topic_resource.id
  path_part   = "{topicId}"
}

// /v1/topic/{topicId}/clone
resource "aws_api_gateway_resource" "v1_topic_id_clone_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_topic_id_resource.id
  path_part   = "clone"
}

// /v1/topic/{topicId}/clone-dashboard
resource "aws_api_gateway_resource" "v1_topic_id_clone_dashboard_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_topic_id_resource.id
  path_part   = "clone-dashboard"
}

// /v1/tool
resource "aws_api_gateway_resource" "v1_tool_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "tool"
}

// /v1/tool/{toolId}
resource "aws_api_gateway_resource" "v1_tool_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_tool_resource.id
  path_part   = "{toolId}"
}

// /v1/profile
resource "aws_api_gateway_resource" "v1_profile_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "profile"
}

// /v1/profile/{profileId}
resource "aws_api_gateway_resource" "v1_profile_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_profile_resource.id
  path_part   = "{profileId}"
}

// /v1/faq
resource "aws_api_gateway_resource" "v1_faq_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "faq"
}

// /v1/faq/reorder
resource "aws_api_gateway_resource" "v1_faq_reorder_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_faq_resource.id
  path_part   = "reorder"
}

// /v1/faq/{faqId}
resource "aws_api_gateway_resource" "v1_faq_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_faq_resource.id
  path_part   = "{faqId}"
}

// /v1/temporary_content_image
resource "aws_api_gateway_resource" "v1_temporary_content_image_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "temporary_content_image"
}

// /v1/contact-us
resource "aws_api_gateway_resource" "v1_contact_us_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "contact-us"
}

module "resource_watch_manager_get_v1_dashboard" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_dashboard_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30558/api/dashboards"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_post_v1_dashboard" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_dashboard_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30558/api/dashboards"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_get_v1_dashboard_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_dashboard_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30558/api/dashboards/{dashboardId}"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_patch_v1_dashboard_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_dashboard_id_resource
  method       = "PATCH"
  uri          = "http://api.resourcewatch.org:30558/api/dashboards/{dashboardId}"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_put_v1_dashboard_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_dashboard_id_resource
  method       = "PUT"
  uri          = "http://api.resourcewatch.org:30558/api/dashboards/{dashboardId}"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_delete_v1_dashboard_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_dashboard_id_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org:30558/api/dashboards/{dashboardId}"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_post_v1_dashboard_id_clone" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_dashboard_id_clone_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30558/api/dashboards/{dashboardId}/clone"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_get_v1_partner" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_partner_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30558/api/partners"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_post_v1_partner" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_partner_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30558/api/partners"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_get_v1_partner_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_partner_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30558/api/partners/{partnerId}"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_patch_v1_partner_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_partner_id_resource
  method       = "PATCH"
  uri          = "http://api.resourcewatch.org:30558/api/partners/{partnerId}"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_put_v1_partner_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_partner_id_resource
  method       = "PUT"
  uri          = "http://api.resourcewatch.org:30558/api/partners/{partnerId}"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_delete_v1_partner_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_partner_id_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org:30558/api/partners/{partnerId}"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_get_v1_static_page" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_static_page_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30558/api/static_pages"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_post_v1_static_page" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_static_page_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30558/api/static_pages"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_get_v1_static_page_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_static_page_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30558/api/static_pages/{staticPageId}"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_patch_v1_static_page_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_static_page_id_resource
  method       = "PATCH"
  uri          = "http://api.resourcewatch.org:30558/api/static_pages/{staticPageId}"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_put_v1_static_page_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_static_page_id_resource
  method       = "PUT"
  uri          = "http://api.resourcewatch.org:30558/api/static_pages/{staticPageId}"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_delete_v1_static_page_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_static_page_id_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org:30558/api/static_pages/{staticPageId}"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_get_v1_topic_page" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_topic_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30558/api/topics"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_post_topic_v1_id_clone_page" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_topic_id_clone_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30558/api/topics/{topicId}/clone"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_post_topic_v1_topic_id_clone_dashboard" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_topic_id_clone_dashboard_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30558/api/topics/{topicId}/clone-dashboard"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_post_v1_topic" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_topic_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30558/api/topics"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_get_v1_topic_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_topic_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30558/api/topics/{topicId}"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_patch_v1_topic_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_topic_id_resource
  method       = "PATCH"
  uri          = "http://api.resourcewatch.org:30558/api/topics/{topicId}"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_put_v1_topic_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_topic_id_resource
  method       = "PUT"
  uri          = "http://api.resourcewatch.org:30558/api/topics/{topicId}"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_delete_v1_topic_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_topic_id_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org:30558/api/topics/{topicId}"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_get_v1_tool" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_tool_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30558/api/tools"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_post_v1_tool" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_tool_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30558/api/tools"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_get_v1_tool_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_tool_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30558/api/tools/{toolId}"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_patch_v1_tool_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_tool_id_resource
  method       = "PATCH"
  uri          = "http://api.resourcewatch.org:30558/api/tools/{toolId}"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_put_v1_tool_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_tool_id_resource
  method       = "PUT"
  uri          = "http://api.resourcewatch.org:30558/api/tools/{toolId}"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_delete_v1_tool_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_tool_id_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org:30558/api/tools/{toolId}"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_post_v1_profile" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_profile_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30558/api/profiles"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_get_v1_profile_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_profile_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30558/api/profiles/{profileId}"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_patch_v1_profile_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_profile_id_resource
  method       = "PATCH"
  uri          = "http://api.resourcewatch.org:30558/api/profiles/{profileId}"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_put_v1_profile_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_profile_id_resource
  method       = "PUT"
  uri          = "http://api.resourcewatch.org:30558/api/profiles/{profileId}"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_delete_v1_profile_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_profile_id_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org:30558/api/profiles/{profileId}"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_get_v1_faq" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_faq_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30558/api/faqs"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_post_v1_faq" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_faq_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30558/api/faqs"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_get_v1_faq_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_faq_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30558/api/faqs/{faqId}"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_patch_v1_faq_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_faq_id_resource
  method       = "PATCH"
  uri          = "http://api.resourcewatch.org:30558/api/faqs/{faqId}"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_put_v1_faq_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_faq_id_resource
  method       = "PUT"
  uri          = "http://api.resourcewatch.org:30558/api/faqs/{faqId}"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_delete_v1_faq_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_faq_id_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org:30558/api/faqs/{faqId}"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_post_v1_faq_reorder" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_faq_reorder_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30558/api/faqs/reorder"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_post_v1_temporary_content_image" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_temporary_content_image_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30558/api/temporary_content_image"
  vpc_link     = var.vpc_link
}

module "resource_watch_manager_post_v1_contact_us" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_contact_us_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30558/api/contact-us"
  vpc_link     = var.vpc_link
}