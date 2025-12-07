output "ec2_role_arn" {
  value = aws_iam_role.ec2.arn
}

output "ec2_instance_profile" {
  value = aws_iam_instance_profile.ec2.name
}

output "lambda_role_arn" {
  value = aws_iam_role.lambda.arn
}

