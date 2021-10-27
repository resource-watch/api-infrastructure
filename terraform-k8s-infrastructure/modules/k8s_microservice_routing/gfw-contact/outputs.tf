output "endpoints" {
  value = [
    module.gfw_contact_any_v1_form_proxy.endpoint_gateway_integration
  ]
}