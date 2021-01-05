output "cluster_name" {
  value       = aws_docdb_cluster.default.cluster_identifier
  description = "Cluster Identifier"
}

output "arn" {
  value       = aws_docdb_cluster.default.arn
  description = "Amazon Resource Name (ARN) of the cluster"
}

output "endpoint" {
  value       = aws_docdb_cluster.default.endpoint
  description = "Endpoint of the DocumentDB cluster"
}

output "reader_endpoint" {
  value       = aws_docdb_cluster.default.reader_endpoint
  description = "A read-only endpoint of the DocumentDB cluster, automatically load-balanced across replicas"
}

output "port" {
  value       = aws_docdb_cluster.default.port
  description = "Port of Document DB cluster"
}

output "security_group_id" {
  description = "ID of the DocumentDB cluster Security Group"
  value       = aws_security_group.documentdb.id
}

output "security_group_arn" {
  description = "ARN of the DocumentDB cluster Security Group"
  value       = aws_security_group.documentdb.arn
}

output "security_group_name" {
  description = "Name of the DocumentDB cluster Security Group"
  value       = aws_security_group.documentdb.name
}

output "secrets_documentdb_arn" {
  description = "ARN of documemt db secret"
  value       = aws_secretsmanager_secret.documentdb.arn
}

output "secrets_documentdb_name" {
  description = "Name of documemt db secret"
  value       = aws_secretsmanager_secret.documentdb.name
}

output "secrets_documentdb_policy_arn" {
  description = "ARN of policy to allow read access to documemt db secret"
  value       = aws_iam_policy.secrets_documentdb.arn
}