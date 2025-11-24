variable "aws_region" {
  description = "AWS 리전"
  type        = string
  default     = "ap-northeast-2"
}

variable "project_name" {
  description = "프로젝트 이름"
  type        = string
  default     = "receipt-api"
}

variable "environment" {
  description = "환경 (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "vpc_cidr" {
  description = "VPC CIDR 블록"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "사용할 가용 영역"
  type        = list(string)
  default     = ["ap-northeast-2a", "ap-northeast-2c"]
}

variable "public_subnet_cidrs" {
  description = "Public Subnet CIDR 블록"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_app_subnet_cidrs" {
  description = "Private Application Subnet CIDR 블록"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "private_db_subnet_cidrs" {
  description = "Private Database Subnet CIDR 블록"
  type        = list(string)
  default     = ["10.0.21.0/24", "10.0.22.0/24"]
}

# ECS 설정
variable "ecs_cluster_name" {
  description = "ECS 클러스터 이름"
  type        = string
  default     = "receipt-api-cluster"
}

variable "ecs_service_name" {
  description = "ECS 서비스 이름"
  type        = string
  default     = "receipt-api-service"
}

variable "ecs_task_cpu" {
  description = "ECS Task CPU (Fargate)"
  type        = number
  default     = 512  # 0.5 vCPU
}

variable "ecs_task_memory" {
  description = "ECS Task Memory (Fargate)"
  type        = number
  default     = 1024  # 1GB
}

variable "ecs_desired_count" {
  description = "ECS 서비스 원하는 태스크 수"
  type        = number
  default     = 2
}

variable "ecs_min_count" {
  description = "Auto-scaling 최소 태스크 수"
  type        = number
  default     = 2
}

variable "ecs_max_count" {
  description = "Auto-scaling 최대 태스크 수"
  type        = number
  default     = 10
}

variable "ecs_cpu_scale_threshold" {
  description = "CPU 사용률 스케일 아웃 임계값 (%)"
  type        = number
  default     = 70
}

variable "ecs_cpu_scale_in_threshold" {
  description = "CPU 사용률 스케일 인 임계값 (%)"
  type        = number
  default     = 30
}

variable "docker_image" {
  description = "Docker 이미지 URL"
  type        = string
  default     = "ghcr.io/spandit/receipt-api:latest"
}

# RDS 설정
variable "rds_instance_class" {
  description = "RDS 인스턴스 클래스"
  type        = string
  default     = "db.t3.medium"
}

variable "rds_allocated_storage" {
  description = "RDS 할당된 스토리지 (GB)"
  type        = number
  default     = 100
}

variable "rds_max_allocated_storage" {
  description = "RDS 최대 자동 확장 스토리지 (GB)"
  type        = number
  default     = 200
}

variable "rds_engine_version" {
  description = "PostgreSQL 엔진 버전"
  type        = string
  default     = "15.4"
}

variable "rds_backup_retention_period" {
  description = "RDS 백업 보관 기간 (일)"
  type        = number
  default     = 7
}

variable "rds_multi_az" {
  description = "RDS Multi-AZ 활성화"
  type        = bool
  default     = true
}

# Active/Standby 구조: Multi-AZ로 자동 구현
# Read Replica 관련 변수는 제거됨

# Secrets Manager 설정
variable "db_secret_name" {
  description = "DB 비밀 정보를 저장할 Secrets Manager 이름"
  type        = string
  default     = "receipt-api/db-credentials"
}

# CloudWatch 설정
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

# 태그
variable "common_tags" {
  description = "공통 태그"
  type        = map(string)
  default = {
    Project     = "receipt-api"
    Environment = "prod"
    ManagedBy   = "Terraform"
  }
}

