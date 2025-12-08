variable "project_name" {
  type = string
}

variable "iam_role_arn" {
  type = string
}

variable "dynamodb_tables" {
  type = object({
    services      = string
    health_checks = string
    alerts        = string
  })
}

variable "sns_topic_arn" {
  type = string
}

variable "s3_bucket_name" {
  type = string
}


