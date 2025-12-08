# Hosted Zone para el dominio
resource "aws_route53_zone" "main" {
  count = var.domain_name != "" ? 1 : 0
  
  name = var.domain_name

  tags = {
    Name        = "${var.project_name}-route53-zone"
    Environment = "production"
  }
}

# Zone IDs para S3 Website por región
# us-east-1: Z3AQBSTGFYJSTF
# us-west-2: Z3BJ6K6RIION7M
# eu-west-1: Z1BKCTXD74EZPE
# etc.

# Registro A para el frontend (S3 Website)
# S3 Website endpoints usan un zone_id específico por región
resource "aws_route53_record" "frontend" {
  count = var.domain_name != "" ? 1 : 0
  
  zone_id = aws_route53_zone.main[0].zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.s3_website_endpoint
    zone_id                = "Z3AQBSTGFYJSTF" # Zone ID para S3 website en us-east-1
    evaluate_target_health = false
  }
}

# Registro A para el subdominio API (API Gateway)
# Nota: API Gateway REST API usa un formato diferente para ALIAS
# Para simplificar, usamos un registro CNAME que apunta al dominio de API Gateway
resource "aws_route53_record" "api" {
  count = var.domain_name != "" && var.api_gateway_domain != "" ? 1 : 0
  
  zone_id = aws_route53_zone.main[0].zone_id
  name    = "api.${var.domain_name}"
  type    = "CNAME"
  ttl     = 300
  records = [replace(var.api_gateway_domain, "https://", "")]
}

# Data source para obtener información de la región actual
data "aws_region" "current" {}

