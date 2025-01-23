resource "aws_security_group" "lambda" {
  name        = "${var.service}-${var.environment}-${var.function_name}-lambda"
  description = "Security group for Lambda function ${var.function_name}"
  vpc_id      = data.aws_vpc.selected.id
  
  tags = {
    Name = "${var.service}-${var.environment}-${var.function_name}-lambda-sg"
  }
}

resource "aws_lambda_function" "this" {
  function_name = "${var.service}-${var.environment}-${var.function_name}"
  role          = aws_iam_role.lambda_exec.arn
  package_type  = "Image"

  image_uri   = "${var.ecr_repository_url}:${var.image_tag}"
  memory_size = var.memory_size
  timeout     = var.timeout

  vpc_config {
    subnet_ids         = data.aws_subnets.private.ids
    security_group_ids = [aws_security_group.lambda.id]
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "${var.service}-${var.environment}-${var.function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_vpc" {
  name = "${var.service}-${var.environment}-${var.function_name}-vpc"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ]
        Resource = [
          "*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_vpc.arn
}

