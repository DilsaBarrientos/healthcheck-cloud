output "table_names" {
  value = {
    services     = aws_dynamodb_table.services.name
    health_checks = aws_dynamodb_table.health_checks.name
    alerts       = aws_dynamodb_table.alerts.name
  }
}


