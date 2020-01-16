# Output values which can be referenced in other repos

output "environment" {
  value       = var.environment
  description = "Environment of current state."
}

output "tags" {
  value       = local.tags
  description = "Default tags which should be assigned to all resources"
}


output "account_id" {
  value       = data.aws_caller_identity.current.account_id
  description = "ID of AWS account"
}

output "vpc_id" {
  value       = module.vpc.id
  description = "ID of VPC"
}

output "public_subnet_ids" {
  value       = module.vpc.public_subnet_ids
  description = "List of all public subnet IDs"
}

output "private_subnet_ids" {
  value       = module.vpc.private_subnet_ids
  description = "List of all private subnet IDs"
}

output "nat_gateway_ips" {
  value       = module.vpc.nat_gateway_ips
  description = "List of all NAT Gateway IPs"
}

output "bastion_hostname" {
  value       = module.vpc.bastion_hostname
  description = "Hostname of bastion host for VPC"
}

output "cidr_block" {
  value       = module.vpc.cidr_block
  description = "CIDR for VPC"
}

output "default_security_group_id" {
  value       = aws_security_group.default.id
  description = "ID of default security group"
}

output "key_pairs" {
  value       = values(aws_key_pair.all)[*].key_name
  description = "List of available key pairs"
}

output "authorized_keys_ec2_user" {
  value       = data.template_file.authorized_keys_ec2_user.rendered
  description = "User data script to add keypairs to authorized_key file on EC2 instance"
}

output "kubectl_config" {
  value       = module.eks.kubeconfig
  description = "Configuration snippet for the kubectl CLI tool that allows access to this EKS cluster"
}
