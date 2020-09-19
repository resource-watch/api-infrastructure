#################
# Provider using Aurora cluster created in core terraform module
#################

provider "postgresql" {
  host     = var.rds_host
  port     = var.rds_port
  database = var.rds_dbname
  username = var.rds_username
  password = var.rds_password

}

#################
# Project databases, roles and passwords
#################

resource "postgresql_database" "default" {
  count    = length(var.postgresql_databases)
  name     = element(var.postgresql_databases, count.index)
  owner    = var.rds_username
  template = var.rds_dbname
}

resource "postgresql_role" "default" {
  count    = length(var.postgresql_databases)
  name     = element(var.postgresql_databases, count.index)
  login    = true
  password = random_password.default[count.index].result
}

resource "random_password" "default" {
  count            = length(var.postgresql_databases)
  length           = 16
  special          = true
  override_special = "_%@"
}

###################
# AWS Secret Manager
###################

resource "aws_secretsmanager_secret" "postgresql" {
  count       = length(var.postgresql_databases)
  description = "Connection string for PostgreSQL database ${element(var.postgresql_databases, count.index)}"
  name        = "${var.project}-postgresql-${element(var.postgresql_databases, count.index)}-secret"
  tags        = var.tags
}

resource "aws_secretsmanager_secret_version" "postgresql" {
  count     = length(var.postgresql_databases)
  secret_id = aws_secretsmanager_secret.postgresql[count.index].id
  secret_string = jsonencode({
    "username"             = postgresql_role.default[count.index].name,
    "engine"               = "postgresql",
    "dbname"               = postgresql_database.default[count.index].name,
    "host"                 = var.rds_host,
    "password"             = random_password.default[count.index].result,
    "port"                 = var.rds_port
  })
}

data "template_file" "secrets_postgresql" {
  count    = length(var.postgresql_databases)
  template = file("${path.root}/../terraform/policies/iam_policy_secrets_read.json.tpl")
  vars = {
    secret_arn = aws_secretsmanager_secret.postgresql[count.index].arn
  }
}

resource "aws_iam_policy" "secrets_postgresql" {
  count  = length(var.postgresql_databases)
  name   = "${var.project}-secrets_postgresql-${element(var.postgresql_databases, count.index)}"
  policy = data.template_file.secrets_postgresql[count.index].rendered
}