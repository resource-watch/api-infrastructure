data "kubernetes_secret" "elasticsearch_core" {
  metadata {
    name      = "elasticsearch"
    namespace = "core"
  }
}

resource "kubectl_manifest" "es_data_service" {
  yaml_body = file("${path.module}/elasticsearch/data/es-data.service.yaml")

  depends_on = [
    data.kubernetes_secret.elasticsearch_core
  ]
}

resource "kubectl_manifest" "es_data_statefulset" {
  yaml_body = templatefile("${path.module}/elasticsearch/data/es-data.statefulset.yaml.tmpl", {
    size : var.elasticsearch_disk_size
  })

  depends_on = [
    data.kubernetes_secret.elasticsearch_core
  ]
}

resource "kubectl_manifest" "es_ingest_deployment" {
  yaml_body = file("${path.module}/elasticsearch/ingest/es-ingest.deployment.yaml")

  depends_on = [
    data.kubernetes_secret.elasticsearch_core
  ]
}

resource "kubectl_manifest" "es_ingest_service" {
  yaml_body = file("${path.module}/elasticsearch/ingest/es-ingest.service.yaml")

  depends_on = [
    data.kubernetes_secret.elasticsearch_core
  ]
}

resource "kubectl_manifest" "es_master_deployment" {
  yaml_body = file("${path.module}/elasticsearch/master/es-master.deployment.yaml")

  depends_on = [
    data.kubernetes_secret.elasticsearch_core
  ]
}

resource "kubectl_manifest" "es_master_service" {
  yaml_body = file("${path.module}/elasticsearch/master/es-master.service.yaml")

  depends_on = [
    data.kubernetes_secret.elasticsearch_core
  ]
}


//
// NEW ES CLUSTER USING AWS
//

data "aws_subnet_ids" "private_subnets" {
  vpc_id = var.vpc.id

  tags = {
    tier = "private"
  }
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
    Statement : [{
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

resource "aws_elasticsearch_domain" "rw-api-elasticsearch" {
  domain_name           = "rw-api-elasticsearch"
  elasticsearch_version = "6.8"

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
    instance_type  = "m5.xlarge.elasticsearch"
    instance_count = 3

    dedicated_master_enabled = true
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

  lifecycle {
    ignore_changes = [
      vpc_options["subnet_ids"],
      elasticsearch_version,
    ]
  }
}