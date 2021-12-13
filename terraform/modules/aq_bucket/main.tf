resource "aws_s3_bucket" "aq_bucket" {
  bucket = "wri-api-${var.environment}-aqueduct"

  # Tells AWS to encrypt the S3 bucket at rest by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule {
    id      = "expiration_period"
    enabled = true

    expiration {
      days = var.retention_period
    }
  }

  # Tells AWS to keep a version history of the state file
  versioning {
    enabled = true
  }

  tags = merge({ Resource = "Aqueduct" }, var.tags)
}

resource "aws_iam_user" "aq_s3_user" {
  name = "aq_s3_user"

  tags = merge({
    Resource = "Aqueduct", Description = "A IAM user that has access to the Aqueduct S3 bucket"
  }, var.tags)

}

resource "aws_iam_user_policy" "aq_s3_admin_policy" {
  name = "aq_s3_admin_policy"
  user = aws_iam_user.aq_s3_user.name

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : [
          "*"
        ],
        Effect : "Allow",
        Resource : aws_s3_bucket.aq_bucket.arn
      }
    ]
  })
}