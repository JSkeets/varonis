resource "aws_security_group" "lambda" {
  name        = "${var.service}-${var.environment}-${var.function_name}-lambda"
  description = "Security group for Lambda function ${var.function_name}"
  vpc_id      = var.vpc_id
  
  tags = {
    Name = "${var.service}-${var.environment}-${var.function_name}-lambda-sg"
  }
}

resource "aws_lambda_function" "this" {
  function_name = "${var.service}-${var.environment}-${var.function_name}"
  role          = aws_iam_role.lambda_exec.arn
  package_type  = "Image"

  image_uri    = "${var.ecr_repository_url}:${var.image_tag}"
  memory_size  = var.memory_size
  timeout      = var.timeout

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.lambda.id]
  }

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = var.dynamodb_table_name
    }
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

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the specified API Gateway.
  source_arn = "${var.api_gateway_execution_arn}/*/*"
}

resource "aws_iam_policy" "dynamodb_access" {
  count = var.enable_dynamodb_access ? 1 : 0
  
  name = "${var.service}-${var.environment}-${var.function_name}-dynamodb"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = [
          var.dynamodb_table_arn,
          "${var.dynamodb_table_arn}/index/*"
        ]
        Condition = {
          StringEquals = {
            "aws:RequestedRegion": var.region
          }
          Bool = {
            "aws:SecureTransport": "true"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "dynamodb_access" {
  count = var.enable_dynamodb_access ? 1 : 0
  
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.dynamodb_access[0].arn
}

resource "aws_iam_policy" "ssm_policy" {
  name = "${var.service}-${var.environment}-${var.function_name}-ssm"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]
        Resource = [
          "*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.ssm_policy.arn
}

resource "aws_iam_policy" "lambda_logging" {
  name = "${var.service}-${var.environment}-${var.function_name}-logging"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          "arn:aws:logs:${var.region}:*:log-group:/aws/lambda/${aws_lambda_function.this.function_name}:*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

