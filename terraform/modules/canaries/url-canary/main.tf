locals {
  js_content = templatefile("${path.module}/canary-lambda.js.tpl", {
    hostname : var.hostname,
  })
}
data "archive_file" "canary_archive_file" {
  type        = "zip"
  output_path = "${path.module}/tmp/${var.name}.zip"

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
  zip_file             = "${path.module}/tmp/${var.name}.zip"
  runtime_version      = "syn-nodejs-puppeteer-3.8"

  schedule {
    expression = var.schedule_expression
  }

  depends_on = [data.archive_file.canary_archive_file]
}
