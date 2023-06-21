variable "name" {
  type        = string
  description = "Name of the canary"
}

variable "s3_artifact_location" {
  type        = string
  description = "Location in Amazon S3 where Synthetics stores artifacts from the test runs of this canary"
}

variable "execution_role_arn" {
  type        = string
  description = "ARN of the IAM role to be used to run the canary"
}

variable "hostname" {
  type        = string
  description = "Hostname of the endpoint to test"
}

variable "schedule_expression" {
  type        = string
  description = "Expression defining how often the canary runs"
}

variable "sns_topic_arn" {
  type        = string
  description = "ARN of the AWS SNS topic to use in case of alert"
}
