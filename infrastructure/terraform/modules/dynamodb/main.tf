resource "aws_dynamodb_table" "services" {
  name         = "Services"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "serviceId"

  attribute {
    name = "serviceId"
    type = "S"
  }

  tags = {
    Name = "${var.project_name}-services"
  }
}

resource "aws_dynamodb_table" "health_checks" {
  name         = "HealthChecks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "serviceId"
  range_key    = "timestamp"

  attribute {
    name = "serviceId"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "N"
  }

  tags = {
    Name = "${var.project_name}-health-checks"
  }
}

resource "aws_dynamodb_table" "alerts" {
  name         = "Alerts"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "alertId"
  range_key    = "serviceId"

  attribute {
    name = "alertId"
    type = "S"
  }

  attribute {
    name = "serviceId"
    type = "S"
  }

  tags = {
    Name = "${var.project_name}-alerts"
  }
}


