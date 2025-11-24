variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}

variable "aws_region" {
  description = "AWS 리전"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public Subnet IDs"
  type        = list(string)
}

variable "private_app_subnet_ids" {
  description = "Private Application Subnet IDs"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "ALB Security Group ID"
  type        = string
}

variable "ecs_task_security_group_id" {
  description = "ECS Task Security Group ID"
  type        = string
}

variable "ecs_task_execution_role_arn" {
  description = "ECS Task Execution Role ARN"
  type        = string
}

variable "ecs_task_role_arn" {
  description = "ECS Task Role ARN"
  type        = string
}

variable "cloudwatch_log_group_name" {
  description = "CloudWatch Log Group Name"
  type        = string
}

variable "db_secret_arn" {
  description = "DB Secrets Manager ARN"
  type        = string
}

variable "ecs_cluster_name" {
  description = "ECS 클러스터 이름"
  type        = string
}

variable "ecs_service_name" {
  description = "ECS 서비스 이름"
  type        = string
}

variable "ecs_task_cpu" {
  description = "ECS Task CPU"
  type        = number
}

variable "ecs_task_memory" {
  description = "ECS Task Memory"
  type        = number
}

variable "ecs_desired_count" {
  description = "ECS 서비스 원하는 태스크 수"
  type        = number
}

variable "ecs_min_count" {
  description = "Auto-scaling 최소 태스크 수"
  type        = number
}

variable "ecs_max_count" {
  description = "Auto-scaling 최대 태스크 수"
  type        = number
}

variable "ecs_cpu_scale_threshold" {
  description = "CPU 사용률 스케일 아웃 임계값 (%)"
  type        = number
}

variable "docker_image" {
  description = "Docker 이미지 URL"
  type        = string
}

variable "container_port" {
  description = "컨테이너 포트"
  type        = number
  default     = 8000
}

variable "health_check_path" {
  description = "헬스체크 경로"
  type        = string
  default     = "/health"
}

variable "enable_deletion_protection" {
  description = "ALB 삭제 보호 활성화"
  type        = bool
  default     = false
}

variable "tags" {
  description = "공통 태그"
  type        = map(string)
  default     = {}
}

