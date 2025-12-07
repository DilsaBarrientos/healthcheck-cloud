output "api_url" {
  value = "${aws_api_gateway_stage.prod.invoke_url}/api"
}

output "rest_api_id" {
  value = aws_api_gateway_rest_api.api.id
}

