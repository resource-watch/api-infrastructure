locals {
  js_content = templatefile("${path.module}/${var.template_relative_path}", {
    hostname : var.hostname,
    path : var.path,
    verb : var.verb,
    hostname_secret_id : var.hostname_secret_id,
    token_secret_id : var.token_secret_id,
  })
}

data "archive_file" "canary_archive_file" {
  type        = "zip"
  output_path = "${path.module}/tmp/${sha256(local.js_content)}.zip"

  source {
    content  = local.js_content
    filename = "nodejs/node_modules/index.js"
  }
}

resource "aws_synthetics_canary" "canary" {
  name                 = var.name
  artifact_s3_location = var.s3_artifact_location
  execution_role_arn   = var.execution_role_arn
  handler              = "index.handler"
  zip_file             = "${path.module}/tmp/${sha256(local.js_content)}.zip"
  runtime_version      = "syn-nodejs-puppeteer-3.1"
  start_canary         = true


  schedule {
    expression = var.schedule_expression
  }

  depends_on = [data.archive_file.canary_archive_file, local.js_content]
}