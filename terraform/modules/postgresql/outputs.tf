output "security_group_id" {
  value       = aws_security_group.postgresql.id
  description = "Security group ID to access postgresql database"
}

output "secrets_postgresql-writer_arn" {
  value = aws_secretsmanager_secret.postgresql-writer.arn
}

output "secrets_postgresql-writer_name" {
  value = aws_secretsmanager_secret.postgresql-writer.name
}

output "secrets_postgresql-writer_policy_arn" {
  value = aws_iam_policy.secrets_postgresql-writer.arn
}

# TODO: uncomment once apps support multiDB
//output "secrets_postgresql-reader_arn" {
//  value = aws_secretsmanager_secret.postgresql-reader.arn
//}
//
//output "secrets_postgresql-reader_name" {
//  value = aws_secretsmanager_secret.postgresql-reader.name
//}
//
//output "secrets_postgresql-reader_policy_arn" {
//  value = aws_iam_policy.secrets_postgresql-reader.arn
//}

output "aurora_cluster_instance_class" {
  value = aws_rds_cluster_instance.aurora_cluster_instance[0].instance_class
}