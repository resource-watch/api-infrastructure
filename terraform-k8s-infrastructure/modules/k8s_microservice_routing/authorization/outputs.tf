output "endpoints" {
  value = [
    module.authorization_get.endpoint_gateway_integration,
    module.authorization_any_proxy.endpoint_gateway_integration,
    module.authorization_get_v1_deletion.endpoint_gateway_integration,
    module.authorization_post_v1_deletion.endpoint_gateway_integration,
    module.authorization_any_v1_deletion_proxy.endpoint_gateway_integration,
    module.authorization_get_v1_organization.endpoint_gateway_integration,
    module.authorization_post_v1_organization.endpoint_gateway_integration,
    module.authorization_any_v1_organization_proxy.endpoint_gateway_integration,
    module.authorization_get_v1_application.endpoint_gateway_integration,
    module.authorization_post_v1_application.endpoint_gateway_integration,
    module.authorization_any_v1_application_proxy.endpoint_gateway_integration
  ]
}
