# Dashboard de CloudWatch
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      # Widget 1: Métricas de API Gateway
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ApiGateway", "Count", { "stat" = "Sum", "label" = "Requests" }],
            ["...", "4XXError", { "stat" = "Sum", "label" = "4XX Errors" }],
            ["...", "5XXError", { "stat" = "Sum", "label" = "5XX Errors" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          title   = "API Gateway - Requests y Errores"
          period  = 300
        }
      },
      # Widget 2: Latencia de API Gateway
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ApiGateway", "Latency", { "stat" = "Average", "label" = "Latency Promedio" }],
            ["...", "Latency", { "stat" = "p95", "label" = "Latency p95" }],
            ["...", "Latency", { "stat" = "p99", "label" = "Latency p99" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          title   = "API Gateway - Latencia"
          period  = 300
        }
      },
      # Widget 3: Métricas de Lambda
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            for name in values(var.lambda_function_names) : [
              "AWS/Lambda",
              "Invocations",
              "FunctionName",
              name,
              { "stat" = "Sum", "label" = "${name} Invocations" }
            ]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          title   = "Lambda - Invocaciones"
          period  = 300
        }
      },
      # Widget 4: Errores de Lambda
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            for name in values(var.lambda_function_names) : [
              "AWS/Lambda",
              "Errors",
              "FunctionName",
              name,
              { "stat" = "Sum", "label" = "${name} Errors" }
            ]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          title   = "Lambda - Errores"
          period  = 300
        }
      },
      # Widget 5: CPU de EC2
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "InstanceId", var.ec2_instance_id, { "stat" = "Average", "label" = "CPU Utilization" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          title   = "EC2 - CPU Utilization"
          period  = 300
        }
      },
      # Widget 6: Network de EC2
      {
        type   = "metric"
        x      = 12
        y      = 12
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/EC2", "NetworkIn", "InstanceId", var.ec2_instance_id, { "stat" = "Sum", "label" = "Network In" }],
            ["...", "NetworkOut", "InstanceId", var.ec2_instance_id, { "stat" = "Sum", "label" = "Network Out" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          title   = "EC2 - Network"
          period  = 300
        }
      },
      # Widget 7: DynamoDB Read/Write
      {
        type   = "metric"
        x      = 0
        y      = 18
        width  = 12
        height = 6

        properties = {
          metrics = concat(
            [for table_name in values(var.dynamodb_table_names) : [
              "AWS/DynamoDB",
              "ConsumedReadCapacityUnits",
              "TableName",
              table_name,
              { "stat" = "Sum", "label" = "${table_name} Read" }
            ]],
            [for table_name in values(var.dynamodb_table_names) : [
              "...",
              "ConsumedWriteCapacityUnits",
              "TableName",
              table_name,
              { "stat" = "Sum", "label" = "${table_name} Write" }
            ]]
          )
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          title   = "DynamoDB - Consumed Capacity"
          period  = 300
        }
      }
    ]
  })
}

# Alarma: Errores de Lambda Monitor
resource "aws_cloudwatch_metric_alarm" "lambda_monitor_errors" {
  count = contains(keys(var.lambda_function_names), "monitor") ? 1 : 0

  alarm_name          = "${var.project_name}-lambda-monitor-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "Alerta cuando hay más de 5 errores en la función Lambda monitor"
  alarm_actions       = [var.sns_topic_arn]

  dimensions = {
    FunctionName = var.lambda_function_names["monitor"]
  }

  tags = {
    Name        = "${var.project_name}-lambda-monitor-errors"
    Environment = "production"
  }
}

# Alarma: CPU de EC2 alta
resource "aws_cloudwatch_metric_alarm" "ec2_high_cpu" {
  alarm_name          = "${var.project_name}-ec2-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alerta cuando el CPU de EC2 supera el 80%"
  alarm_actions       = [var.sns_topic_arn]

  dimensions = {
    InstanceId = var.ec2_instance_id
  }

  tags = {
    Name        = "${var.project_name}-ec2-high-cpu"
    Environment = "production"
  }
}

# Alarma: Errores 5XX en API Gateway
resource "aws_cloudwatch_metric_alarm" "api_gateway_5xx_errors" {
  alarm_name          = "${var.project_name}-api-gateway-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "5XXError"
  namespace           = "AWS/ApiGateway"
  period              = 300
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "Alerta cuando hay más de 10 errores 5XX en API Gateway"
  alarm_actions       = [var.sns_topic_arn]

  dimensions = {
    ApiName = "${var.project_name}-api"
    Stage   = "prod"
  }

  tags = {
    Name        = "${var.project_name}-api-gateway-5xx-errors"
    Environment = "production"
  }
}

