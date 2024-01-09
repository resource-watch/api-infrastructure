output "endpoints" {
  value = [
    module.doc_orchestrator_any_doc_importer_proxy.endpoint_gateway_integration,
  ]
}