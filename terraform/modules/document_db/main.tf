##################
# Cluster
##################

resource "aws_docdb_cluster" "default" {
  cluster_identifier              = "${var.project}-documentdb-cluster"
  master_username                 = var.master_username
  master_password                 = random_password.documentdb_superuser.result
  backup_retention_period         = var.backup_retention_period
  preferred_backup_window         = var.preferred_backup_window
  final_snapshot_identifier       = lower("${var.project}-documentdb-cluster")
  skip_final_snapshot             = var.skip_final_snapshot
  apply_immediately               = var.apply_immediately
  storage_encrypted               = var.storage_encrypted
  kms_key_id                      = var.kms_key_id
  snapshot_identifier             = var.snapshot_identifier
  vpc_security_group_ids          = [aws_security_group.documentdb.id]
  db_subnet_group_name            = aws_docdb_subnet_group.default.name
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.default.name
  engine                          = var.engine
  engine_version                  = var.engine_version
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  tags = merge(
    {
      Name = "${var.project}-DocumentDB-Cluster"
    },
    var.tags
  )

}

resource "aws_docdb_cluster_instance" "default" {
  count              = var.cluster_size
  identifier         = "${var.project}-documentdb-instance-${count.index}"
  cluster_identifier = aws_docdb_cluster.default.id
  apply_immediately  = var.apply_immediately
  instance_class     = var.instance_class
  engine             = var.engine
  tags = merge(
    {
      Name = "${var.project}-DocumentDB-Instance-${count.index}"
    },
    var.tags
  )

  lifecycle {
    create_before_destroy = true
  }
}


# https://docs.aws.amazon.com/documentdb/latest/developerguide/db-cluster-parameter-group-create.html
resource "aws_docdb_cluster_parameter_group" "default" {
  name        = lower("${var.project}-documentdb-parameter-group")
  description = "DB cluster parameter group"
  family      = var.cluster_family

  dynamic "parameter" {
    for_each = var.cluster_parameters
    content {
      apply_method = lookup(parameter.value, "apply_method", null)
      name         = parameter.value.name
      value        = parameter.value.value
    }
  }

  tags = merge(
    {
      Name = "${var.project}-DocumentDB-Parameter-Group"
    },
    var.tags
  )
}

###############
# Subnet group
###############

resource "aws_docdb_subnet_group" "default" {
  name        = "${var.project}-documentdb-subnet_group"
  description = "Allowed subnets for DB cluster instances"
  subnet_ids  = var.private_subnet_ids
  tags = merge(
    {
      Name = "${var.project}-DocumentDB-Subnet-Group"
    },
    var.tags
  )
}

#################
# Security Group
#################

resource "aws_security_group" "documentdb" {
  vpc_id                 = var.vpc_id
  description            = "Security Group for DocumentDB cluster"
  name                   = "${var.project}-sgDocumentDB"
  revoke_rules_on_delete = true
  tags = merge(
    {
      Name = "${var.project}-sgDocumentDB"
    },
    var.tags
  )
}

resource "aws_security_group_rule" "documentdb_ingress" {
  type              = "ingress"
  from_port         = var.db_port
  to_port           = var.db_port
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr_block]
  security_group_id = aws_security_group.documentdb.id
}


###############
# Logging
###############


resource "aws_cloudwatch_log_group" "default" {
  count             = length(var.enabled_cloudwatch_logs_exports)
  name              = "/aws/rds/cluster/${aws_docdb_cluster.default.cluster_identifier}/${element(var.enabled_cloudwatch_logs_exports, count.index)}"
  retention_in_days = var.log_retention_period

  tags = merge(
    {
      Name = "${var.project}-Aurora-DB-Logs-${element(var.enabled_cloudwatch_logs_exports, count.index)}"
    },
    var.tags
  )
}


####################
# Secret Manager
####################

resource "random_password" "documentdb_superuser" {
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "documentdb" {
  description = "Connection string for DocumentDB cluster"
  name        = "${var.project}-documentdb-secret"
  tags        = var.tags
}

resource "aws_secretsmanager_secret_version" "documentdb" {

  secret_id = aws_secretsmanager_secret.documentdb.id
  secret_string = jsonencode({
    "username"             = var.master_username,
    "password"             = random_password.documentdb_superuser.result,
    "engine"               = var.engine,
    "endpoint"             = aws_docdb_cluster.default.endpoint,
    "reader_endpoint"      = aws_docdb_cluster.default.reader_endpoint,
    "port"                 = var.db_port,
    "dbInstanceIdentifier" = aws_docdb_cluster.default.cluster_identifier
  })
}

data "template_file" "secrets_documentdb" {
  template = file("${path.root}/policies/iam_policy_secrets_read.json.tpl")
  vars = {
    secret_arn = aws_secretsmanager_secret.documentdb.arn
  }
}

resource "aws_iam_policy" "secrets_documentdb" {
  name   = "${var.project}-secrets_documentdb"
  policy = data.template_file.secrets_documentdb.rendered
}
