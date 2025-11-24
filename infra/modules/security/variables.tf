variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "db_secret_arn" {
  description = "DB Secrets Manager ARN"
  type        = string
  default     = ""
}

variable "s3_bucket_arn" {
  description = "S3 Bucket ARN"
  type        = string
  default     = ""
}

variable "cloudwatch_log_group_arn" {
  description = "CloudWatch Log Group ARN"
  type        = string
  default     = ""
}

variable "tags" {
  description = "공통 태그"
  type        = map(string)
  default     = {}
}

