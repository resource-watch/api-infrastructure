resource "aws_s3_bucket" "aq_bucket" {
  bucket = "wri-api-${var.environment}-aqueduct"

  tags = merge({ Resource = "Aqueduct" }, var.tags)
}

resource "aws_s3_bucket_server_side_encryption_configuration" "aq_bucket_encryption" {
  bucket = aws_s3_bucket.aq_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "aq_bucket_versioning" {
  bucket = aws_s3_bucket.aq_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_cors_configuration" "aq_bucket_cors_configuration" {
  bucket = aws_s3_bucket.aq_bucket.id
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = [var.cors_allowed_origin]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "aq_bucket_lifecycle_configuration" {
  bucket = aws_s3_bucket.aq_bucket.id

  rule {
    id     = "expiration_period"
    status = "Enabled"

    filter {
      prefix = "food-supply-chain/"
    }

    expiration {
      days = var.retention_period
    }
  }
}

resource "aws_s3_object" "object" {
  bucket       = aws_s3_bucket.aq_bucket.id
  acl          = "private"
  key          = "food-supply-chain/"
  content_type = "application/x-directory"
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
        Effect : "Allow",
        Action : [
          "s3:GetBucketLocation",
          "s3:ListAllMyBuckets"
        ],
        Resource : "arn:aws:s3:::*"
      },
      {
        Action : [
          "s3:*"
        ],
        Effect : "Allow",
        Resource : [
          aws_s3_bucket.aq_bucket.arn,
          "${aws_s3_bucket.aq_bucket.arn}/*"
        ]
      }
    ]
  })
}
