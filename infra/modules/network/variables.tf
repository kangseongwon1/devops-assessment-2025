variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR 블록"
  type        = string
}

variable "availability_zones" {
  description = "사용할 가용 영역"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "Public Subnet CIDR 블록"
  type        = list(string)
}

variable "private_app_subnet_cidrs" {
  description = "Private Application Subnet CIDR 블록"
  type        = list(string)
}

variable "private_db_subnet_cidrs" {
  description = "Private Database Subnet CIDR 블록"
  type        = list(string)
}

variable "tags" {
  description = "공통 태그"
  type        = map(string)
  default     = {}
}

