output "endpoints" {
  value = [
    module.forms_any_v1_form_proxy.endpoint_gateway_integration,
    module.forms_any_v1_questionnaire_proxy.endpoint_gateway_integration,
    module.forms_any_v1_reports_proxy.endpoint_gateway_integration,
  ]
}