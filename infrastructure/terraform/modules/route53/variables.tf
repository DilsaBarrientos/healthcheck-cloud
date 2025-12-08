variable "project_name" {
  type        = string
  description = "Nombre del proyecto"
}

variable "domain_name" {
  type        = string
  description = "Nombre del dominio (ej: healthcheck-cloud.com). Si está vacío, no se crea Route 53"
  default     = ""
}

variable "s3_website_endpoint" {
  type        = string
  description = "Endpoint del S3 website (ej: healthcheck-cloud-frontend-xxx.s3-website-us-east-1.amazonaws.com)"
}

variable "api_gateway_domain" {
  type        = string
  description = "Dominio del API Gateway (ej: xxx.execute-api.us-east-1.amazonaws.com)"
  default     = ""
}


