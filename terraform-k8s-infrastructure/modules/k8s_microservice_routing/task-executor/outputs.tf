output "endpoints" {
  value = [
    module.task_async_get_task.endpoint_gateway_integration,
    module.task_async_post_task_sync_dataset.endpoint_gateway_integration,
    module.task_async_put_task_sync_dataset_by_dataset.endpoint_gateway_integration,
    module.task_async_delete_task_sync_dataset_by_dataset_id.endpoint_gateway_integration,
    module.task_async_post_task_sync_dataset_by_dataset_id_hook.endpoint_gateway_integration
  ]
}