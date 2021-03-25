output "endpoints" {
  value = [
    module.doc_orchestrator_delete_doc_importer_task_id.endpoint_gateway_integration,
    module.doc_orchestrator_get_doc_importer_task_id.endpoint_gateway_integration,
    module.doc_orchestrator_delete_doc_importer_task_id
  ]
}