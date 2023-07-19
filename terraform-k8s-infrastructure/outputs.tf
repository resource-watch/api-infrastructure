output "invoke_url" {
  value = module.k8s_microservice_routing.api_url
}

output "node_group_names" {
  value = module.k8s_microservice_routing.node_group_names
}

output "api_gateway_open_usage_plan_id" {
  value = module.k8s_microservice_routing.open_usage_plan_id
}
