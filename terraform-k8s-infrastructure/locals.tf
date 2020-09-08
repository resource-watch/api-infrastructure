locals {
  bucket_suffix   = var.environment == "production" ? "" : "-${var.environment}"
  tf_state_bucket = "wri-api-terraform${local.bucket_suffix}"
  project         = "core"
  tags = {
    Project     = var.project,
    Environment = var.environment,
    BuiltBy     = "Terraform"
  }
}