terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC y Networking
module "vpc" {
  source = "./modules/vpc"
  
  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
}

# DynamoDB
module "dynamodb" {
  source = "./modules/dynamodb"
  
  project_name = var.project_name
}

# IAM Roles
module "iam" {
  source = "./modules/iam"
  
  project_name = var.project_name
  dynamodb_tables = module.dynamodb.table_names
}

# EC2
module "ec2" {
  source = "./modules/ec2"
  
  project_name    = var.project_name
  vpc_id          = module.vpc.vpc_id
  subnet_id       = module.vpc.public_subnet_id
  security_group_id = module.vpc.security_group_id
  iam_instance_profile = module.iam.ec2_instance_profile
  key_name        = var.ec2_key_name
}

# S3
module "s3" {
  source = "./modules/s3"
  
  project_name = var.project_name
}

# API Gateway
module "api_gateway" {
  source = "./modules/api_gateway"
  
  project_name = var.project_name
  ec2_endpoint = "http://${module.ec2.public_ip}:5000"
}

# Lambda
module "lambda" {
  source = "./modules/lambda"
  
  project_name    = var.project_name
  iam_role_arn    = module.iam.lambda_role_arn
  dynamodb_tables = module.dynamodb.table_names
  sns_topic_arn   = module.sns.topic_arn
  s3_bucket_name  = module.s3.bucket_name
}

# SNS
module "sns" {
  source = "./modules/sns"
  
  project_name = var.project_name
  email        = var.alert_email
}

# Ejecutar Ansible automáticamente después de crear la infraestructura
resource "null_resource" "ansible_deploy" {
  depends_on = [
    module.ec2,
    module.api_gateway,
    module.s3,
    module.dynamodb
  ]

  # Esperar a que EC2 esté listo
  provisioner "local-exec" {
    command = "sleep 30"
  }

  # Exportar outputs de Terraform
  provisioner "local-exec" {
    command = "terraform output -json > terraform-outputs.json"
    working_dir = path.module
  }

  # Ejecutar Ansible para desplegar backend
  provisioner "local-exec" {
    command     = "ansible-playbook playbooks/backend.yml"
    working_dir = "${path.module}/../ansible"
    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
    }
  }

  # Ejecutar Ansible para desplegar frontend
  provisioner "local-exec" {
    command     = "ansible-playbook playbooks/frontend.yml"
    working_dir = "${path.module}/../ansible"
  }

  triggers = {
    ec2_instance_id = module.ec2.instance_id
    api_gateway_id  = module.api_gateway.rest_api_id
    s3_bucket_name  = module.s3.bucket_name
    timestamp       = timestamp()
  }
}

