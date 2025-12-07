variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "healthcheck-cloud"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "ec2_key_name" {
  description = "EC2 Key Pair name"
  type        = string
}

variable "alert_email" {
  description = "Email for SNS alerts"
  type        = string
}

