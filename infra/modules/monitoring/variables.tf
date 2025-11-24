variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}

variable "cloudwatch_log_retention_days" {
  description = "CloudWatch Logs 보관 기간 (일)"
  type        = number
  default     = 7
}

variable "slack_webhook_url" {
  description = "Slack Webhook URL (선택사항, 비워두면 Slack 알림 비활성화)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "alb_arn_suffix" {
  description = "ALB ARN Suffix (알람용)"
  type        = string
  default     = ""
}

variable "ecs_cluster_name" {
  description = "ECS 클러스터 이름"
  type        = string
  default     = ""
}

variable "ecs_service_name" {
  description = "ECS 서비스 이름"
  type        = string
  default     = ""
}

variable "rds_instance_id" {
  description = "RDS 인스턴스 ID"
  type        = string
  default     = ""
}

# Active/Standby 구조: Read Replica 관련 변수 제거

variable "tags" {
  description = "공통 태그"
  type        = map(string)
  default     = {}
}

