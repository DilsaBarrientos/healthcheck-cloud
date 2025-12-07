resource "aws_api_gateway_rest_api" "api" {
  name        = "${var.project_name}-api"
  description = "HealthCheck Cloud API"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "api" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "api"
}

resource "aws_api_gateway_resource" "services" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.api.id
  path_part   = "services"
}

resource "aws_api_gateway_method" "services" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.services.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "services" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.services.id
  http_method = aws_api_gateway_method.services.http_method

  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"
  uri                     = "${var.ec2_endpoint}/api/services"
}

resource "aws_api_gateway_deployment" "api" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  depends_on = [
    aws_api_gateway_integration.services
  ]

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.services.id,
      aws_api_gateway_method.services.id,
      aws_api_gateway_integration.services.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.api.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "prod"
}

