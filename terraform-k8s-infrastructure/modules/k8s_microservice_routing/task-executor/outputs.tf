output "endpoints" {
  value = [
    module.task_async_get_task.endpoint_gateway_integration,
    module.task_async_any_task_proxy.endpoint_gateway_integration
  ]
}