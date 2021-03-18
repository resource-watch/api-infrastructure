data "aws_subnet_ids" "private_subnets" {
  vpc_id = var.vpc.id

  tags = {
    tier = "private"
  }
}

resource "aws_iam_service_linked_role" "es-service-role" {
  aws_service_name = "es.amazonaws.com"
}

resource "aws_security_group" "elasticsearch-sg" {
  name        = "elasticsearch-sg"
  description = "AWS SG for Elasticsearch"
  vpc_id      = var.vpc.id

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = [
      var.vpc.cidr_block,
    ]
  }
}

resource "aws_iam_policy" "amazon_es_snapshot_policy" {
  name = "AmazonESSnapshotAccessPolicy"
  path = "/"

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : [
          "s3:ListBucket"
        ],
        Effect : "Allow",
        Resource : [
          "arn:aws:s3:::${var.backups_bucket}"
        ]
      },
      {
        Action : [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Effect : "Allow",
        Resource : [
          "arn:aws:s3:::${var.backups_bucket}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "amazon_es_snapshot_role" {
  name = "AmazonESSnapshotRole"

  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Principal : {
          "Service" : "es.amazonaws.com"
        },
        Action : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "amazon_es_snapshot_role_policy_attachment" {
  role       = aws_iam_role.amazon_es_snapshot_role.name
  policy_arn = aws_iam_policy.amazon_es_snapshot_policy.arn
}

resource "aws_cloudwatch_log_group" "es_index_log_group" {
  name = "/aws/aes/domains/rw-api-elasticsearch/index-logs"
}
resource "aws_cloudwatch_log_group" "es_application_log_group" {
  name = "/aws/aes/domains/rw-api-elasticsearch/application-logs"
}

resource "aws_cloudwatch_log_resource_policy" "es_logs_resource_policy" {
  policy_name = "es_logs_resource_policy"

  policy_document = <<CONFIG
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "es.amazonaws.com"
      },
      "Action": [
        "logs:PutLogEvents",
        "logs:PutLogEventsBatch",
        "logs:CreateLogStream"
      ],
      "Resource": "arn:aws:logs:*"
    }
  ]
}
CONFIG
}

resource "aws_elasticsearch_domain" "rw-api-elasticsearch" {
  domain_name           = "rw-api-elasticsearch"
  elasticsearch_version = "7.7"

  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = true

    master_user_options {
      master_user_name     = "master"
      master_user_password = "Master1$3"
    }
  }

  node_to_node_encryption {
    enabled = true
  }

  encrypt_at_rest {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  cluster_config {
    instance_type  = "m5.2xlarge.elasticsearch"
    instance_count = var.elasticsearch_data_nodes_count

    dedicated_master_enabled = var.elasticsearch_use_dedicated_master_nodes
    dedicated_master_count   = 3
    dedicated_master_type    = "m5.large.elasticsearch"

    zone_awareness_enabled = true
    zone_awareness_config {
      availability_zone_count = 3
    }
  }

  ebs_options {
    ebs_enabled = true
    volume_size = var.elasticsearch_disk_size_gb
  }

  vpc_options {
    subnet_ids = [
      sort(data.aws_subnet_ids.private_subnets.ids)[3],
      sort(data.aws_subnet_ids.private_subnets.ids)[4],
      sort(data.aws_subnet_ids.private_subnets.ids)[2]
    ]

    security_group_ids = [
    aws_security_group.elasticsearch-sg.id]
  }

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  snapshot_options {
    automated_snapshot_start_hour = 23
  }


  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.es_application_log_group.arn
    enabled                  = true
    log_type                 = "ES_APPLICATION_LOGS"
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.es_index_log_group.arn
    enabled                  = true
    log_type                 = "INDEX_SLOW_LOGS"
  }


  lifecycle {
    ignore_changes = [
      vpc_options
    ]
  }
}