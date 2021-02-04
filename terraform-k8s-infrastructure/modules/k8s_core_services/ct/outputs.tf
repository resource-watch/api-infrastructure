output "endpoints" {
  value = [
    module.control_tower_any.endpoint_gateway_integration
  ]
}