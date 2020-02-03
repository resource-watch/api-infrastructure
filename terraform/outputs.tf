# Output values which can be referenced in other repos

output "environment" {
  value       = var.environment
  description = "Environment of current state."
}

output "account_id" {
  value       = data.aws_caller_identity.current.account_id
  description = "ID of AWS account"
}

output "nat_gateway_ips" {
  value       = module.vpc.nat_gateway_ips
  description = "List of all NAT Gateway IPs"
}

output "bastion_hostname" {
  value       = module.vpc.bastion_hostname
  description = "Hostname of bastion host for VPC"
}

output "kubectl_config" {
  value       = module.eks.kubeconfig
  description = "Configuration snippet for the kubectl CLI tool that allows access to this EKS cluster"
}

output "jenkins_hostname" {
  value       = module.jenkins.jenkins_hostname
  description = "Hostname for Jenkins"
}