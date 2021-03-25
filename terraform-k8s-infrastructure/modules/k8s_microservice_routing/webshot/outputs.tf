output "endpoints" {
  value = [
    module.webshot_pdf.endpoint_gateway_integration,
    module.webshot_widget_id_thumbnail.endpoint_gateway_integration
  ]
}