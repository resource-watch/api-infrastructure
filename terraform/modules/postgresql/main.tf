########################
## Cluster
########################


resource "aws_rds_cluster" "aurora_cluster" {

  cluster_identifier              = "${var.project}-aurora-cluster"
  engine                          = "aurora-postgresql"
  engine_version                  = "11.7"
  database_name                   = var.rds_db_name
  master_username                 = var.rds_user_name
  master_password                 = random_password.postgresql_superuser.result
  backup_retention_period         = var.rds_backup_retention_period
  preferred_backup_window         = "14:00-15:00"
  preferred_maintenance_window    = "sat:16:00-sat:17:00"
  db_subnet_group_name            = aws_db_subnet_group.default.name
  final_snapshot_identifier       = lower("${var.project}-aurora-cluster")
  vpc_security_group_ids          = [aws_security_group.postgresql.id]
  availability_zones              = var.availability_zone_names
  copy_tags_to_snapshot           = true
  apply_immediately               = true
  port                            = var.rds_port
  storage_encrypted               = true
  enabled_cloudwatch_logs_exports = ["postgresql"]
  tags = merge(
    {
      Name = "${var.project}-Aurora-DB-Cluster"
    },
    var.tags
  )

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_rds_cluster_instance" "aurora_cluster_instance" {

  count                        = var.rds_instance_count
  identifier                   = "${var.project}-aurora-instance-${count.index}"
  cluster_identifier           = aws_rds_cluster.aurora_cluster.id
  instance_class               = var.rds_instance_class
  engine                       = "aurora-postgresql"
  db_subnet_group_name         = aws_db_subnet_group.default.name
  publicly_accessible          = false
  apply_immediately            = true
  copy_tags_to_snapshot        = true
  monitoring_interval          = 60
  monitoring_role_arn          = aws_iam_role.rds_enhanced_monitoring.arn
  promotion_tier               = 1
  performance_insights_enabled = true

  tags = merge(
    {
      Name = "${var.project}-Aurora-DB-Instance-${count.index}"
    },
    var.tags
  )

}

resource "random_password" "postgresql_superuser" {
  length  = 16
  special = false
}


#####################
# RDS Monitoring Role
#####################

resource "aws_iam_role" "rds_enhanced_monitoring" {
  name               = "${var.project}-rds_enhanced_monitoring-role"
  assume_role_policy = data.template_file.rds_enhanced_monitoring.rendered
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  role       = aws_iam_role.rds_enhanced_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

data "template_file" "rds_enhanced_monitoring" {

  template = file("${path.root}/policies/trust_service.json.tpl")
  vars = {
    service = "monitoring.rds"
  }
}

#####################
# DB Subnet Group
#####################

resource "aws_db_subnet_group" "default" {

  name       = "main"
  subnet_ids = var.private_subnet_ids

  tags = merge(
    {
      Name = "${var.project}-Aurora-DB-Subnet-Group"
    },
    var.tags
  )
}


###############
# Logging
###############


resource "aws_cloudwatch_log_group" "postgresql" {
  name              = "/aws/rds/cluster/${aws_rds_cluster.aurora_cluster.cluster_identifier}/postgresql"
  retention_in_days = var.log_retention_period

  tags = merge(
    {
      Name = "${var.project}-Aurora-DB-Logs"
    },
    var.tags
  )
}

##################
# Auto scaling
##################


# TODO: Uncomment this once apps are ready for multiDB support

//resource "aws_appautoscaling_target" "replicas" {
//  service_namespace  = "rds"
//  scalable_dimension = "rds:cluster:ReadReplicaCount"
//  resource_id        = "cluster:${aws_rds_cluster.aurora_cluster.id}"
//  min_capacity       = var.rds_instance_count
//  max_capacity       = 15
//}
//
//resource "aws_appautoscaling_policy" "replicas" {
//  name               = "cpu-auto-scaling"
//  service_namespace  = aws_appautoscaling_target.replicas.service_namespace
//  scalable_dimension = aws_appautoscaling_target.replicas.scalable_dimension
//  resource_id        = aws_appautoscaling_target.replicas.resource_id
//  policy_type        = "TargetTrackingScaling"
//
//  target_tracking_scaling_policy_configuration {
//    predefined_metric_specification {
//      predefined_metric_type = "RDSReaderAverageCPUUtilization"
//    }
//
//    target_value       = 75
//    scale_in_cooldown  = 300
//    scale_out_cooldown = 300
//  }
//}


#####################
# Security Groups
#####################


# Allow access to aurora to all resources which are in the same security group

resource "aws_security_group" "postgresql" {
  vpc_id                 = var.vpc_id
  description            = "Security Group for PostgreSQL cluster"
  name                   = "${var.project}-sgPostgreSQL"
  revoke_rules_on_delete = true
  tags = merge(
    {
      Name = "${var.project}-sgPostgreSQL"
    },
    var.tags
  )
}


resource "aws_security_group_rule" "postgresql_ingress" {
  type              = "ingress"
  from_port         = var.rds_port
  to_port           = var.rds_port
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr_block]
  security_group_id = aws_security_group.postgresql.id
}

####################
# Secret Manager
####################

resource "aws_secretsmanager_secret" "postgresql-writer" {
  description = "Connection string for Aurora PostgreSQL cluster"
  name        = "${var.project}-postgresql-writer-secret"
  tags        = var.tags
}

resource "aws_secretsmanager_secret_version" "postgresql-writer" {

  secret_id = aws_secretsmanager_secret.postgresql-writer.id
  secret_string = jsonencode({
    "username"             = var.rds_user_name,
    "engine"               = "postgresql",
    "dbname"               = var.rds_db_name,
    "host"                 = aws_rds_cluster.aurora_cluster.endpoint,
    "password"             = random_password.postgresql_superuser.result,
    "port"                 = var.rds_port,
    "dbInstanceIdentifier" = aws_rds_cluster.aurora_cluster.cluster_identifier
  })
}

data "template_file" "secrets_postgresql-writer" {
  template = file("${path.root}/policies/iam_policy_secrets_read.json.tpl")
  vars = {
    secret_arn = aws_secretsmanager_secret.postgresql-writer.arn
  }
}

resource "aws_iam_policy" "secrets_postgresql-writer" {
  name   = "${var.project}-secrets_postgresql-writer"
  policy = data.template_file.secrets_postgresql-writer.rendered
}
