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

output "jenkins_hostname" {
  value       = module.jenkins.jenkins_hostname
  description = "Hostname of the Jenkins host"
}

output "bastion_dns" {
  value       = cloudflare_record.bastion_dns.hostname
  description = "DNS name of bastion host for VPC"
}

output "jenkins_dns" {
  value       = cloudflare_record.jenkins_dns.hostname
  description = "DNS name of the Jenkins host"
}

output "kubectl_config" {
  value       = module.eks.kubeconfig
  description = "Configuration snippet for the kubectl CLI tool that allows access to this EKS cluster"
}

locals {
  kube_configmap = <<KUBECONFIGMAP
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${module.vpc.eks_manager_role.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:masters
    - rolearn: ${module.eks.node_role_arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes

KUBECONFIGMAP
}

output "kube_configmap" {
  value = local.kube_configmap
}

output "postgresql_security_group_id" {
  value       = module.postgresql.security_group_id
  description = "Security group ID to access postgresql database"
}

output "secrets_postgresql-writer_arn" {
  value = module.postgresql.secrets_postgresql-writer_arn
}

output "secrets_postgresql-writer_name" {
  value = module.postgresql.secrets_postgresql-writer_name
}

output "secrets_postgresql-writer_policy_arn" {
  value = module.postgresql.secrets_postgresql-writer_policy_arn
}

# TODO: enable once app have multiDB support
//output "secrets_postgresql-reader_arn" {
//  value = module.postgresql.secrets_postgresql-reader_arn
//}
//
//output "secrets_postgresql-reader_name" {
//  value = module.postgresql.secrets_postgresql-reader_name
//}
//
//output "secrets_postgresql-reader_policy_arn" {
//  value = module.postgresql.secrets_postgresql-reader_policy_arn
//}

output "aurora_cluster_instance_class" {
  value = module.postgresql.aurora_cluster_instance_class
}

output "aurora_user_name" {
  value = module.postgresql.username
}

output "aurora_host" {
  value = module.postgresql.host
}

output "aurora_port" {
  value = module.postgresql.port
}
output "aurora_dbname" {
  value = module.postgresql.dbname
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