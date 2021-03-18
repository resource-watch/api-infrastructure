output "endpoints" {
  value = [
    module.authorization_get.endpoint_gateway_integration,
    module.authorization_get_login.endpoint_gateway_integration,
    module.authorization_post_login.endpoint_gateway_integration,
    module.authorization_get_fail.endpoint_gateway_integration,
    module.authorization_get_check_logged.endpoint_gateway_integration,
    module.authorization_get_success.endpoint_gateway_integration,
    module.authorization_get_logout.endpoint_gateway_integration,
    module.authorization_get_sign_up.endpoint_gateway_integration,
    module.authorization_post_sign_up.endpoint_gateway_integration,
    module.authorization_get_confirm_token.endpoint_gateway_integration,
    module.authorization_get_reset_password.endpoint_gateway_integration,
    module.authorization_post_reset_password.endpoint_gateway_integration,
    module.authorization_get_reset_password_token.endpoint_gateway_integration,
    module.authorization_post_reset_password_token.endpoint_gateway_integration,
    module.authorization_get_generate_token.endpoint_gateway_integration,
    module.authorization_get_user.endpoint_gateway_integration,
    module.authorization_get_user_me.endpoint_gateway_integration,
    module.authorization_get_user_from_token.endpoint_gateway_integration,
    module.authorization_get_user_id.endpoint_gateway_integration,
    module.authorization_post_user_find_by_ids.endpoint_gateway_integration,
    module.authorization_get_user_ids_role.endpoint_gateway_integration,
    module.authorization_post_user.endpoint_gateway_integration,
    module.authorization_patch_user_me.endpoint_gateway_integration,
    module.authorization_patch_user_id.endpoint_gateway_integration,
    module.authorization_delete_user_id.endpoint_gateway_integration,
    module.authorization_get_authorization_authorization_code_callback.endpoint_gateway_integration
  ]
}