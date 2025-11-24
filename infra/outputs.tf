# Network Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.network.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR 블록"
  value       = module.network.vpc_cidr
}

output "public_subnet_ids" {
  description = "Public Subnet IDs"
  value       = module.network.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "Private Application Subnet IDs"
  value       = module.network.private_app_subnet_ids
}

output "private_db_subnet_ids" {
  description = "Private Database Subnet IDs"
  value       = module.network.private_db_subnet_ids
}

# Compute Outputs
output "alb_dns_name" {
  description = "Application Load Balancer DNS 이름"
  value       = module.compute.alb_dns_name
}

output "alb_arn" {
  description = "Application Load Balancer ARN"
  value       = module.compute.alb_arn
}

output "target_group_arn" {
  description = "Target Group ARN"
  value       = module.compute.target_group_arn
}

output "ecs_cluster_name" {
  description = "ECS 클러스터 이름"
  value       = module.compute.ecs_cluster_name
}

output "ecs_cluster_arn" {
  description = "ECS 클러스터 ARN"
  value       = module.compute.ecs_cluster_arn
}

output "ecs_service_name" {
  description = "ECS 서비스 이름"
  value       = module.compute.ecs_service_name
}

output "ecs_task_definition_arn" {
  description = "ECS Task Definition ARN"
  value       = module.compute.ecs_task_definition_arn
}

# Database Outputs
output "rds_endpoint" {
  description = "RDS 인스턴스 엔드포인트"
  value       = module.database.rds_endpoint
}

output "rds_address" {
  description = "RDS 인스턴스 주소"
  value       = module.database.rds_address
}

output "rds_port" {
  description = "RDS 인스턴스 포트"
  value       = module.database.rds_port
}

# Active/Standby 구조: Standby는 Multi-AZ로 자동 생성되며
# Primary 엔드포인트만 사용 (failover 시 자동으로 Standby로 전환)

# Storage Outputs
output "s3_bucket_name" {
  description = "S3 버킷 이름 (영수증 이미지)"
  value       = module.storage.s3_bucket_name
}

output "s3_bucket_arn" {
  description = "S3 버킷 ARN"
  value       = module.storage.s3_bucket_arn
}

# Monitoring Outputs
output "cloudwatch_log_group_name" {
  description = "CloudWatch Log Group 이름"
  value       = module.monitoring.cloudwatch_log_group_name
}

output "sns_topic_arn" {
  description = "SNS 알림 토픽 ARN"
  value       = module.monitoring_base.sns_topic_arn != "" ? module.monitoring_base.sns_topic_arn : module.monitoring_alarms.sns_topic_arn
}

# Secrets Outputs
output "db_secret_arn" {
  description = "DB 비밀 정보 Secrets Manager ARN"
  value       = aws_secretsmanager_secret.db_credentials.arn
  sensitive   = true
}

# API URL
output "api_url" {
  description = "API 엔드포인트 URL"
  value       = module.compute.api_url
}
