output "hosted_zone_id" {
  description = "ID de la hosted zone de Route 53"
  value       = var.domain_name != "" ? aws_route53_zone.main[0].zone_id : null
}

output "name_servers" {
  description = "Name servers de la hosted zone (para configurar en el registrador del dominio)"
  value       = var.domain_name != "" ? aws_route53_zone.main[0].name_servers : []
}

output "domain_name" {
  description = "Nombre del dominio configurado"
  value       = var.domain_name
}

output "frontend_url" {
  description = "URL del frontend (con dominio si está configurado, sino URL de S3)"
  value       = var.domain_name != "" ? "http://${var.domain_name}" : var.s3_website_endpoint
}

output "api_url" {
  description = "URL de la API (con subdominio si está configurado, sino URL de API Gateway)"
  value       = var.domain_name != "" && var.api_gateway_domain != "" ? "https://api.${var.domain_name}" : var.api_gateway_domain
}


