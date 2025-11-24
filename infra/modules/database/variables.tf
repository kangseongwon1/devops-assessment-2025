variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}

variable "private_db_subnet_ids" {
  description = "Private Database Subnet IDs"
  type        = list(string)
}

variable "rds_security_group_id" {
  description = "RDS Security Group ID"
  type        = string
}

variable "rds_instance_class" {
  description = "RDS 인스턴스 클래스"
  type        = string
}

variable "rds_allocated_storage" {
  description = "RDS 할당된 스토리지 (GB)"
  type        = number
}

variable "rds_max_allocated_storage" {
  description = "RDS 최대 자동 확장 스토리지 (GB)"
  type        = number
}

variable "rds_engine_version" {
  description = "PostgreSQL 엔진 버전"
  type        = string
}

variable "rds_backup_retention_period" {
  description = "RDS 백업 보관 기간 (일)"
  type        = number
}

variable "rds_multi_az" {
  description = "RDS Multi-AZ 활성화"
  type        = bool
}

# Active/Standby 구조: Multi-AZ로 자동 구현
# Read Replica 관련 변수는 제거됨

variable "db_name" {
  description = "데이터베이스 이름"
  type        = string
  default     = "receipts_db"
}

variable "db_username" {
  description = "데이터베이스 사용자 이름"
  type        = string
  default     = "receipts_user"
}

variable "db_password" {
  description = "데이터베이스 비밀번호 (실제 환경에서는 Secrets Manager 사용)"
  type        = string
  sensitive   = true
  default     = "CHANGE_ME_IN_PRODUCTION"
}

variable "deletion_protection" {
  description = "RDS 삭제 보호 활성화"
  type        = bool
  default     = false
}

variable "tags" {
  description = "공통 태그"
  type        = map(string)
  default     = {}
}

