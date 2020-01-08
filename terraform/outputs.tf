output "environment" {
  value       = var.environment
  description = "Environment of current state."
}

output "tags" {
  value = local.tags
}


output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "vpc_id" {
  value = module.vpc.id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "nat_gateway_ips" {
  value = module.vpc.nat_gateway_ips
}

output "bastion_hostname" {
  value = module.vpc.bastion_hostname
}

output "cidr_block" {
  value = module.vpc.cidr_block
}

output "default_security_group_id" {
  value = aws_security_group.default.id
}

output "key_pair_tmaschler_gfw" {
  value = aws_key_pair.tmaschler_gfw.key_name
}


