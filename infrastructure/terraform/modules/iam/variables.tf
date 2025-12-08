variable "project_name" {
  type = string
}

variable "dynamodb_tables" {
  type = object({
    services      = string
    health_checks = string
    alerts        = string
  })
}


