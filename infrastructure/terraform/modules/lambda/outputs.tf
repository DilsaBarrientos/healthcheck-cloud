output "function_names" {
  value = {
    monitor     = aws_lambda_function.monitor.function_name
    s3_processor = aws_lambda_function.s3_processor.function_name
  }
}


