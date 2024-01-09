output "endpoints" {
  value = [
    module.forms_any_v1_questionnaire_proxy.endpoint_proxy_integration,
    module.forms_any_v1_reports_proxy.endpoint_proxy_integration,
    module.forms_any_v1_questionnaire.endpoint_proxy_integration,
    module.forms_any_v1_reports.endpoint_proxy_integration
  ]
}