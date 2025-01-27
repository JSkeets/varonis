# API Gateway Log Group
resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/${var.service}-${var.environment}"
  retention_in_days = var.retention_in_days

  tags = {
    Environment = var.environment
    Service     = var.service
  }
}

# DynamoDB Log Group
resource "aws_cloudwatch_log_group" "dynamodb" {
  name              = "/aws/dynamodb/${var.service}-${var.environment}"
  retention_in_days = var.retention_in_days

  tags = {
    Environment = var.environment
    Service     = var.service
  }
}

# Lambda Log Group (if not already created by Lambda)
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.service}-${var.environment}"
  retention_in_days = var.retention_in_days

  tags = {
    Environment = var.environment
    Service     = var.service
  }
}

# VPC Flow Logs
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc/${var.service}-${var.environment}-flow-logs"
  retention_in_days = var.retention_in_days

  tags = {
    Environment = var.environment
    Service     = var.service
  }
}

# SNS Topic for alarms
resource "aws_sns_topic" "alarms" {
  count = var.enable_alarms ? 1 : 0
  name  = "${var.service}-${var.environment}-alarms"
}

resource "aws_sns_topic_subscription" "alarm_email" {
  count     = var.enable_alarms ? length(var.alarm_email_endpoints) : 0
  topic_arn = aws_sns_topic.alarms[0].arn
  protocol  = "email"
  endpoint  = var.alarm_email_endpoints[count.index]
}

# Update existing alarms to use the SNS topic
resource "aws_cloudwatch_metric_alarm" "api_errors" {
  count               = var.enable_alarms ? 1 : 0
  alarm_name          = "${var.service}-${var.environment}-api-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "5XXError"
  namespace          = "AWS/ApiGateway"
  period             = "300"
  statistic          = "Sum"
  threshold          = var.api_error_threshold
  alarm_description  = "This metric monitors API Gateway 5XX errors"
  alarm_actions      = [aws_sns_topic.alarms[0].arn]

  dimensions = {
    ApiName = "${var.service}-${var.environment}"
    Stage   = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  count               = var.enable_alarms ? 1 : 0
  alarm_name          = "${var.service}-${var.environment}-lambda-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Errors"
  namespace          = "AWS/Lambda"
  period             = "300"
  statistic          = "Sum"
  threshold          = var.lambda_error_threshold
  alarm_description  = "This metric monitors Lambda function errors"
  alarm_actions      = [aws_sns_topic.alarms[0].arn]

  dimensions = {
    FunctionName = "${var.service}-${var.environment}"
  }
}