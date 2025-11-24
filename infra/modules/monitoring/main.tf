# CloudWatch Log Group
# 주의: monitoring 모듈이 두 번 호출될 수 있으므로,
# 첫 번째 호출에서는 생성하고, 두 번째 호출에서는 data source로 참조
data "aws_cloudwatch_log_group" "ecs_existing" {
  count = var.alb_arn_suffix != "" ? 1 : 0
  name  = "/ecs/${var.project_name}"
}

resource "aws_cloudwatch_log_group" "ecs" {
  count = var.alb_arn_suffix == "" ? 1 : 0
  name              = "/ecs/${var.project_name}"
  retention_in_days = var.cloudwatch_log_retention_days

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-ecs-logs"
    }
  )
}

# CloudWatch Log Group 이름/ARN (조건부)
locals {
  cloudwatch_log_group_name = var.alb_arn_suffix != "" ? data.aws_cloudwatch_log_group.ecs_existing[0].name : aws_cloudwatch_log_group.ecs[0].name
  cloudwatch_log_group_arn  = var.alb_arn_suffix != "" ? data.aws_cloudwatch_log_group.ecs_existing[0].arn : aws_cloudwatch_log_group.ecs[0].arn
}

# Lambda Log Group
# 주의: Lambda는 첫 번째 호출에서만 생성되므로, Log Group도 첫 번째 호출에서만 생성
resource "aws_cloudwatch_log_group" "lambda" {
  count = var.slack_webhook_url != "" && var.alb_arn_suffix == "" ? 1 : 0
  name  = "/aws/lambda/${var.project_name}-slack-notifier"
  retention_in_days = var.cloudwatch_log_retention_days

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-lambda-logs"
    }
  )
}

# SNS Topic
# 주의: monitoring 모듈이 두 번 호출될 수 있으므로,
# 첫 번째 호출에서는 생성하고, 두 번째 호출에서는 data source로 참조
data "aws_sns_topic" "alerts_existing" {
  count = var.alb_arn_suffix != "" ? 1 : 0
  name  = "${var.project_name}-alerts"
}

resource "aws_sns_topic" "alerts" {
  count = var.alb_arn_suffix == "" ? 1 : 0
  name  = "${var.project_name}-alerts"

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-alerts"
    }
  )
}

# SNS Topic ARN (조건부)
locals {
  sns_topic_arn = var.alb_arn_suffix != "" ? data.aws_sns_topic.alerts_existing[0].arn : aws_sns_topic.alerts[0].arn
}


# Lambda 함수 (SNS → Slack)
# 주의: Lambda는 첫 번째 호출에서만 생성 (alb_arn_suffix == "" 일 때)
data "archive_file" "lambda_zip" {
  count = var.slack_webhook_url != "" && var.alb_arn_suffix == "" ? 1 : 0
  type        = "zip"
  source_file = "${path.module}/lambda/slack_notifier.py"
  output_path = "${path.module}/lambda/slack_notifier.zip"
}

resource "aws_lambda_function" "slack_notifier" {
  count = var.slack_webhook_url != "" && var.alb_arn_suffix == "" ? 1 : 0
  
  filename         = data.archive_file.lambda_zip[0].output_path
  function_name    = "${var.project_name}-slack-notifier"
  role            = aws_iam_role.lambda[0].arn
  handler         = "slack_notifier.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip[0].output_base64sha256
  runtime         = "python3.11"
  timeout         = 30

  environment {
    variables = {
      SLACK_WEBHOOK_URL = var.slack_webhook_url
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs[0],
    aws_cloudwatch_log_group.lambda[0]
  ]

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-slack-notifier"
    }
  )
}

# Lambda IAM Role
resource "aws_iam_role" "lambda" {
  count = var.slack_webhook_url != "" && var.alb_arn_suffix == "" ? 1 : 0
  
  name = "${var.project_name}-lambda-slack-notifier-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-lambda-slack-notifier-role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  count = var.slack_webhook_url != "" && var.alb_arn_suffix == "" ? 1 : 0
  
  role       = aws_iam_role.lambda[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda 함수 참조 (두 번째 호출에서 사용)
data "aws_lambda_function" "slack_notifier_existing" {
  count = var.slack_webhook_url != "" && var.alb_arn_suffix != "" ? 1 : 0
  function_name = "${var.project_name}-slack-notifier"
}

# SNS → Lambda 구독
resource "aws_sns_topic_subscription" "lambda" {
  count = var.slack_webhook_url != "" && var.alb_arn_suffix == "" ? 1 : 0
  
  topic_arn = local.sns_topic_arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.slack_notifier[0].arn
}

# Lambda 권한 (SNS가 Lambda를 호출할 수 있도록)
resource "aws_lambda_permission" "sns" {
  count = var.slack_webhook_url != "" && var.alb_arn_suffix == "" ? 1 : 0
  
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.slack_notifier[0].function_name
  principal     = "sns.amazonaws.com"
  source_arn    = local.sns_topic_arn
}

# Error Rate Alarm (5% 이상 시 알림)
# Error Rate = (5XX Count / Total Request Count) * 100
resource "aws_cloudwatch_metric_alarm" "error_rate" {
  count = var.alb_arn_suffix != "" ? 1 : 0

  alarm_name          = "${var.project_name}-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  threshold           = 5  # 5분 동안 5개 이상의 5XX 에러 (약 5% 에러율)
  alarm_description   = "Error rate > 5% (5XX errors)"
  alarm_actions       = [local.sns_topic_arn]

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-error-rate-alarm"
    }
  )
}

# CPU Utilization Alarm (ECS) - 주요 지표
resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  count = var.ecs_cluster_name != "" && var.ecs_service_name != "" ? 1 : 0

  alarm_name          = "${var.project_name}-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "CPU utilization > 80%"
  alarm_actions       = [local.sns_topic_arn]

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-cpu-utilization-alarm"
    }
  )
}

# Memory Utilization Alarm (ECS) - 주요 지표
resource "aws_cloudwatch_metric_alarm" "memory_utilization" {
  count = var.ecs_cluster_name != "" && var.ecs_service_name != "" ? 1 : 0

  alarm_name          = "${var.project_name}-memory-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Memory utilization > 80%"
  alarm_actions       = [local.sns_topic_arn]

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-memory-utilization-alarm"
    }
  )
}

# Request Latency Alarm (P95) - 주요 지표
resource "aws_cloudwatch_metric_alarm" "request_latency" {
  count = var.alb_arn_suffix != "" ? 1 : 0

  alarm_name          = "${var.project_name}-request-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "p95"  # 95th percentile
  threshold           = 1000  # 1000ms = 1초
  alarm_description   = "Request latency (P95) > 1000ms"
  alarm_actions       = [local.sns_topic_arn]

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-request-latency-alarm"
    }
  )
}

# Database Connection Alarm
resource "aws_cloudwatch_metric_alarm" "db_connections" {
  count = var.rds_instance_id != "" ? 1 : 0

  alarm_name          = "${var.project_name}-db-connections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This metric monitors database connections"
  alarm_actions       = [local.sns_topic_arn]

  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-db-connections-alarm"
    }
  )
}

# Active/Standby 구조: Read Replica 관련 알람 제거
# Standby는 Multi-AZ로 자동 관리되므로 별도 알람 불필요

