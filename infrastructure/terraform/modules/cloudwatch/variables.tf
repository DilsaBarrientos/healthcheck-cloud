variable "project_name" {
  type        = string
  description = "Nombre del proyecto"
}

variable "api_gateway_id" {
  type        = string
  description = "ID del API Gateway"
}

variable "lambda_function_names" {
  type        = map(string)
  description = "Mapa de nombres de funciones Lambda"
  default     = {}
}

variable "ec2_instance_id" {
  type        = string
  description = "ID de la instancia EC2"
}

variable "dynamodb_table_names" {
  type        = map(string)
  description = "Mapa de nombres de tablas DynamoDB"
  default     = {}
}

variable "sns_topic_arn" {
  type        = string
  description = "ARN del tópico SNS para alertas"
}


