output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "ec2_public_ip" {
  description = "EC2 Public IP"
  value       = module.ec2.public_ip
}

output "ec2_instance_id" {
  description = "EC2 Instance ID"
  value       = module.ec2.instance_id
}

output "api_gateway_url" {
  description = "API Gateway URL"
  value       = module.api_gateway.api_url
}

output "s3_bucket_name" {
  description = "S3 Bucket name for frontend"
  value       = module.s3.bucket_name
}

output "s3_website_url" {
  description = "S3 Website URL"
  value       = module.s3.website_url
}

output "lambda_functions" {
  description = "Lambda function names"
  value       = module.lambda.function_names
}

output "cloudwatch_dashboard_url" {
  description = "URL del dashboard de CloudWatch"
  value       = module.cloudwatch.dashboard_url
}

output "cloudwatch_dashboard_name" {
  description = "Nombre del dashboard de CloudWatch"
  value       = module.cloudwatch.dashboard_name
}

