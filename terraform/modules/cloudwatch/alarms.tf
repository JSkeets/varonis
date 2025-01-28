resource "aws_cloudwatch_metric_alarm" "api_errors" {
  alarm_name          = "${var.service}-${var.environment}-api-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "5XXError"
  namespace          = "AWS/ApiGateway"
  period             = "300"
  statistic          = "Sum"
  threshold          = "5"
  alarm_description  = "This metric monitors API Gateway 5XX errors"
  alarm_actions      = var.alarm_actions

  dimensions = {
    ApiName = "${var.service}-${var.environment}"
    Stage   = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${var.service}-${var.environment}-lambda-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "Errors"
  namespace          = "AWS/Lambda"
  period             = "300"
  statistic          = "Sum"
  threshold          = "3"
  alarm_description  = "This metric monitors Lambda function errors"
  alarm_actions      = var.alarm_actions

  dimensions = {
    FunctionName = "${var.service}-${var.environment}"
  }
} 