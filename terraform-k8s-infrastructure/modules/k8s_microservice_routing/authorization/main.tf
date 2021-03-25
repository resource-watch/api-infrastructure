resource "kubernetes_service" "authorization_service" {
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

resource "aws_lb_listener" "authorization_nlb_listener" {
  load_balancer_arn = var.load_balancer.arn
  port              = 30505
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.authorization_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "authorization_lb_target_group" {
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
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.authorization_lb_target_group.arn
}

// /
data "aws_api_gateway_resource" "root_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/"
}

// /auth
resource "aws_api_gateway_resource" "authorization_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.root_resource.id
  path_part   = "auth"
}

#
# Apple resources
#

// /auth/apple
resource "aws_api_gateway_resource" "authorization_apple_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.authorization_resource.id
  path_part   = "apple"
}

// /auth/apple/callback
resource "aws_api_gateway_resource" "authorization_apple_callback_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.authorization_apple_resource.id
  path_part   = "callback"
}

// /auth/apple/token
resource "aws_api_gateway_resource" "authorization_apple_token_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.authorization_apple_resource.id
  path_part   = "token"
}

#
# Google resources
#

// /auth/google
resource "aws_api_gateway_resource" "authorization_google_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.authorization_resource.id
  path_part   = "google"
}

// /auth/google/callback
resource "aws_api_gateway_resource" "authorization_google_callback_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.authorization_google_resource.id
  path_part   = "callback"
}

// /auth/google/token
resource "aws_api_gateway_resource" "authorization_google_token_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.authorization_google_resource.id
  path_part   = "token"
}

#
# Facebook resources
#
// /auth/facebook
resource "aws_api_gateway_resource" "authorization_facebook_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.authorization_resource.id
  path_part   = "facebook"
}

// /auth/facebook/callback
resource "aws_api_gateway_resource" "authorization_facebook_callback_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.authorization_facebook_resource.id
  path_part   = "callback"
}

// /auth/facebook/token
resource "aws_api_gateway_resource" "authorization_facebook_token_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.authorization_facebook_resource.id
  path_part   = "token"
}

#
# User management resources
#

// /auth/login
resource "aws_api_gateway_resource" "authorization_login_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.authorization_resource.id
  path_part   = "login"
}

// /auth/fail
resource "aws_api_gateway_resource" "authorization_fail_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.authorization_resource.id
  path_part   = "fail"
}

// /auth/check-logged
resource "aws_api_gateway_resource" "authorization_check_logged_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.authorization_resource.id
  path_part   = "check-logged"
}

// /auth/success
resource "aws_api_gateway_resource" "authorization_success_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.authorization_resource.id
  path_part   = "success"
}

// /auth/logout
resource "aws_api_gateway_resource" "authorization_logout_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.authorization_resource.id
  path_part   = "logout"
}

// /auth/sign-up
resource "aws_api_gateway_resource" "authorization_sign_up_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.authorization_resource.id
  path_part   = "sign-up"
}

// /auth/confirm
resource "aws_api_gateway_resource" "authorization_confirm_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.authorization_resource.id
  path_part   = "confirm"
}

// /auth/confirm/{token}
resource "aws_api_gateway_resource" "authorization_confirm_token_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.authorization_confirm_resource.id
  path_part   = "{token}"
}

// /auth/reset-password
resource "aws_api_gateway_resource" "authorization_reset_password_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.authorization_resource.id
  path_part   = "reset-password"
}

// /auth/reset-password/{token}
resource "aws_api_gateway_resource" "authorization_reset_password_token_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.authorization_reset_password_resource.id
  path_part   = "{token}"
}

// /auth/generate-token
resource "aws_api_gateway_resource" "authorization_generate_token_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.authorization_resource.id
  path_part   = "generate-token"
}

// /auth/user
resource "aws_api_gateway_resource" "authorization_user_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.authorization_resource.id
  path_part   = "user"
}

// /auth/user/from-token
resource "aws_api_gateway_resource" "authorization_user_from_token_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.authorization_user_resource.id
  path_part   = "from-token"
}

// /auth/user/{userId}
resource "aws_api_gateway_resource" "authorization_user_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.authorization_user_resource.id
  path_part   = "{userId}"
}

// /auth/user/find-by-ids
resource "aws_api_gateway_resource" "authorization_user_find_by_ids_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.authorization_user_resource.id
  path_part   = "find-by-ids"
}

// /auth/user/ids
resource "aws_api_gateway_resource" "authorization_user_ids_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.authorization_user_resource.id
  path_part   = "ids"
}

// /auth/user/ids/{role}
resource "aws_api_gateway_resource" "authorization_user_ids_role_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.authorization_user_ids_resource.id
  path_part   = "{role}"
}

// /auth/user/me
resource "aws_api_gateway_resource" "authorization_user_me_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.authorization_user_resource.id
  path_part   = "me"
}

// /auth/authorization-code
resource "aws_api_gateway_resource" "authorization_authorization_code_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.authorization_resource.id
  path_part   = "authorization-code"
}

// /auth/authorization-code/callback
resource "aws_api_gateway_resource" "authorization_authorization_code_callback_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.authorization_authorization_code_resource.id
  path_part   = "callback"
}


#
# Apple endpoints
#
module "authorization_get_apple" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.authorization_apple_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30505/auth/apple"
  vpc_link     = var.vpc_link
}

module "authorization_post_apple_callback" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.authorization_apple_callback_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30505/auth/apple/callback"
  vpc_link     = var.vpc_link
}

module "authorization_get_apple_token" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.authorization_apple_token_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30505/auth/apple/callback"
  vpc_link     = var.vpc_link
}

#
# Google endpoints
#
module "authorization_get_google" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.authorization_google_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30505/auth/google"
  vpc_link     = var.vpc_link
}

module "authorization_get_google_callback" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.authorization_google_callback_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30505/auth/google/callback"
  vpc_link     = var.vpc_link
}

module "authorization_get_google_token" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.authorization_google_token_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30505/auth/google/token"
  vpc_link     = var.vpc_link
}

#
# Facebook endpoints
#
module "authorization_get_facebook" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.authorization_facebook_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30505/auth/facebook"
  vpc_link     = var.vpc_link
}

module "authorization_get_facebook_callback" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.authorization_facebook_callback_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30505/auth/facebook/callback"
  vpc_link     = var.vpc_link
}

module "authorization_get_facebook_token" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.authorization_facebook_token_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30505/auth/facebook/token"
  vpc_link     = var.vpc_link
}

#
# User management resources
#
module "authorization_get" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.authorization_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30505/auth"
  vpc_link     = var.vpc_link
}

module "authorization_get_login" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.authorization_login_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30505/auth/login"
  vpc_link     = var.vpc_link
}

module "authorization_post_login" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.authorization_login_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30505/auth/login"
  vpc_link     = var.vpc_link
}

module "authorization_get_fail" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.authorization_fail_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30505/auth/fail"
  vpc_link     = var.vpc_link
}

module "authorization_get_check_logged" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.authorization_check_logged_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30505/auth/check-logged"
  vpc_link     = var.vpc_link
}

module "authorization_get_success" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.authorization_success_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30505/auth/success"
  vpc_link     = var.vpc_link
}

module "authorization_get_logout" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.authorization_logout_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30505/auth/logout"
  vpc_link     = var.vpc_link
}

module "authorization_get_sign_up" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.authorization_sign_up_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30505/auth/sign-up"
  vpc_link     = var.vpc_link
}

module "authorization_post_sign_up" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.authorization_sign_up_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30505/auth/sign-up"
  vpc_link     = var.vpc_link
}

module "authorization_get_confirm_token" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.authorization_confirm_token_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30505/auth/confirm/{token}"
  vpc_link     = var.vpc_link
}

module "authorization_get_reset_password" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.authorization_reset_password_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30505/auth/reset-password"
  vpc_link     = var.vpc_link
}

module "authorization_post_reset_password" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.authorization_reset_password_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30505/auth/reset-password"
  vpc_link     = var.vpc_link
}

module "authorization_get_reset_password_token" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.authorization_reset_password_token_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30505/auth/reset-password/{token}"
  vpc_link     = var.vpc_link
}

module "authorization_post_reset_password_token" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.authorization_reset_password_token_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30505/auth/reset-password/{token}"
  vpc_link     = var.vpc_link
}

module "authorization_get_generate_token" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.authorization_generate_token_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30505/auth/generate-token"
  vpc_link     = var.vpc_link
}

module "authorization_get_user" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.authorization_user_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30505/auth/user"
  vpc_link     = var.vpc_link
}

module "authorization_get_user_me" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.authorization_user_me_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30505/auth/user/me"
  vpc_link     = var.vpc_link
}

module "authorization_get_user_from_token" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.authorization_user_from_token_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30505/auth/user/from-token"
  vpc_link     = var.vpc_link
}

module "authorization_get_user_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.authorization_user_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30505/auth/user/{userId}"
  vpc_link     = var.vpc_link
}

module "authorization_post_user_find_by_ids" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.authorization_user_find_by_ids_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30505/auth/user/find-by-ids"
  vpc_link     = var.vpc_link
}

module "authorization_get_user_ids_role" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.authorization_user_ids_role_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30505/auth/user/ids/{role}"
  vpc_link     = var.vpc_link
}

module "authorization_post_user" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.authorization_user_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30505/auth/user"
  vpc_link     = var.vpc_link
}

module "authorization_patch_user_me" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.authorization_user_me_resource
  method       = "PATCH"
  uri          = "http://api.resourcewatch.org:30505/auth/user/me"
  vpc_link     = var.vpc_link
}

module "authorization_patch_user_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.authorization_user_id_resource
  method       = "PATCH"
  uri          = "http://api.resourcewatch.org:30505/auth/user/{userId}"
  vpc_link     = var.vpc_link
}

module "authorization_delete_user_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.authorization_user_id_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org:30505/auth/user/{userId}"
  vpc_link     = var.vpc_link
}

module "authorization_get_authorization_authorization_code_callback" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.authorization_authorization_code_callback_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30505/auth/authorization-code/callback"
  vpc_link     = var.vpc_link
}
