output "invoke_url" {
  value = module.k8s_microservice_routing.api_url
}

output "node_group_names" {
  value = module.k8s_microservice_routing.node_group_names
}