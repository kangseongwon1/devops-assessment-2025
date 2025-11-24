output "cloudwatch_log_group_name" {
  description = "CloudWatch Log Group 이름"
  value       = var.alb_arn_suffix != "" ? data.aws_cloudwatch_log_group.ecs_existing[0].name : (length(aws_cloudwatch_log_group.ecs) > 0 ? aws_cloudwatch_log_group.ecs[0].name : "")
}

output "cloudwatch_log_group_arn" {
  description = "CloudWatch Log Group ARN"
  value       = var.alb_arn_suffix != "" ? data.aws_cloudwatch_log_group.ecs_existing[0].arn : (length(aws_cloudwatch_log_group.ecs) > 0 ? aws_cloudwatch_log_group.ecs[0].arn : "")
}

output "sns_topic_arn" {
  description = "SNS 알림 토픽 ARN"
  value       = var.alb_arn_suffix != "" ? data.aws_sns_topic.alerts_existing[0].arn : (length(aws_sns_topic.alerts) > 0 ? aws_sns_topic.alerts[0].arn : "")
}

