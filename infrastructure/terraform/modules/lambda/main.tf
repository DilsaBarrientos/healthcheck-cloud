# Health Check Monitor
data "archive_file" "monitor" {
  type        = "zip"
  source_file = "${path.module}/../../../../lambda/healthcheck-monitor/lambda_function.py"
  output_path = "${path.module}/monitor.zip"
}

resource "aws_lambda_function" "monitor" {
  filename      = data.archive_file.monitor.output_path
  function_name = "${var.project_name}-monitor"
  role          = var.iam_role_arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  timeout       = 30

  environment {
    variables = {
      SERVICES_TABLE = var.dynamodb_tables.services
      CHECKS_TABLE   = var.dynamodb_tables.health_checks
      ALERTS_TABLE   = var.dynamodb_tables.alerts
      SNS_TOPIC_ARN  = var.sns_topic_arn
    }
  }
}

resource "aws_cloudwatch_event_rule" "schedule" {
  name                = "${var.project_name}-schedule"
  description         = "Trigger health checks every 5 minutes"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "monitor" {
  rule      = aws_cloudwatch_event_rule.schedule.name
  target_id = "HealthCheckMonitor"
  arn       = aws_lambda_function.monitor.arn
}

resource "aws_lambda_permission" "monitor" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.monitor.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule.arn
}

# S3 Processor
data "archive_file" "s3_processor" {
  type        = "zip"
  source_file = "${path.module}/../../../../lambda/healthcheck-s3-processor/lambda_function.py"
  output_path = "${path.module}/s3-processor.zip"
}

resource "aws_lambda_function" "s3_processor" {
  filename      = data.archive_file.s3_processor.output_path
  function_name = "${var.project_name}-s3-processor"
  role          = var.iam_role_arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  timeout       = 10

  environment {
    variables = {
      SERVICES_TABLE = var.dynamodb_tables.services
    }
  }
}

resource "aws_lambda_permission" "s3_processor" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.s3_bucket_name}"
}

resource "aws_s3_bucket_notification" "lambda_trigger" {
  bucket = var.s3_bucket_name

  depends_on = [
    aws_lambda_function.s3_processor,
    aws_lambda_permission.s3_processor
  ]

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_processor.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "config/"
  }
}

