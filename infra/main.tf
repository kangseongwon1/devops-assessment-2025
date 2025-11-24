terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # 상태 파일 저장 위치 (실제 환경에서는 S3 백엔드 사용 권장)
  # backend "s3" {
  #   bucket = "spandit-terraform-state"
  #   key    = "receipt-api/terraform.tfstate"
  #   region = "ap-northeast-2"
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.common_tags
  }
}

# ============================================================================
# 데이터 소스
# ============================================================================

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

# ============================================================================
# 모듈: Network
# ============================================================================

module "network" {
  source = "./modules/network"

  project_name              = var.project_name
  vpc_cidr                  = var.vpc_cidr
  availability_zones         = var.availability_zones
  public_subnet_cidrs        = var.public_subnet_cidrs
  private_app_subnet_cidrs   = var.private_app_subnet_cidrs
  private_db_subnet_cidrs    = var.private_db_subnet_cidrs
  tags                       = var.common_tags
}

# ============================================================================
# 모듈: Storage (S3)
# ============================================================================

module "storage" {
  source = "./modules/storage"

  project_name = var.project_name
  account_id   = data.aws_caller_identity.current.account_id
  tags         = var.common_tags
}


# ============================================================================
# 모듈: Monitoring (CloudWatch Logs, SNS, Alarms)
# ============================================================================
# 주의: monitoring 모듈은 compute와 database 이후에 호출되어야 함
# (Alarms 생성에 필요한 정보가 필요)
# 하지만 Security 모듈에서 cloudwatch_log_group_arn이 필요하므로,
# monitoring 모듈을 먼저 호출하고, alarms는 나중에 별도로 생성

# 첫 번째 호출: 기본 리소스만 생성 (Security 모듈에서 필요)
module "monitoring_base" {
  source = "./modules/monitoring"

  project_name                 = var.project_name
  cloudwatch_log_retention_days = var.cloudwatch_log_retention_days
  slack_webhook_url            = var.slack_webhook_url
  tags                          = var.common_tags
}

# ============================================================================
# 모듈: Security (Security Groups, IAM)
# ============================================================================

module "security" {
  source = "./modules/security"

  project_name              = var.project_name
  vpc_id                    = module.network.vpc_id
  db_secret_arn             = aws_secretsmanager_secret.db_credentials.arn
  s3_bucket_arn             = module.storage.s3_bucket_arn
  cloudwatch_log_group_arn  = module.monitoring_base.cloudwatch_log_group_arn
  tags                      = var.common_tags
}

# ============================================================================
# Secrets Manager (DB 자격 증명)
# ============================================================================

resource "aws_secretsmanager_secret" "db_credentials" {
  name        = var.db_secret_name
  description = "Database credentials for receipt-api"

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-db-secret"
    }
  )
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = "receipts_user"
    password = "CHANGE_ME_IN_PRODUCTION"  # 실제 환경에서는 안전하게 설정
    engine   = "postgres"
    port     = 5432
    dbname   = "receipts_db"
  })
}

# ============================================================================
# 모듈: Database (RDS)
# ============================================================================

module "database" {
  source = "./modules/database"

  project_name                  = var.project_name
  private_db_subnet_ids         = module.network.private_db_subnet_ids
  rds_security_group_id         = module.security.rds_security_group_id
  rds_instance_class            = var.rds_instance_class
  rds_allocated_storage         = var.rds_allocated_storage
  rds_max_allocated_storage     = var.rds_max_allocated_storage
  rds_engine_version            = var.rds_engine_version
  rds_backup_retention_period   = var.rds_backup_retention_period
  rds_multi_az                  = var.rds_multi_az  # Active/Standby 구조 (Multi-AZ)
  db_password                   = "CHANGE_ME_IN_PRODUCTION"  # 실제 환경에서는 Secrets Manager 사용
  tags                          = var.common_tags
}

# Secrets Manager에 RDS 엔드포인트 업데이트
resource "aws_secretsmanager_secret_version" "db_credentials_with_host" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = "receipts_user"
    password = "CHANGE_ME_IN_PRODUCTION"
    engine   = "postgres"
    host     = module.database.rds_address
    port     = 5432
    dbname   = "receipts_db"
  })

  depends_on = [module.database]
}

# ============================================================================
# 모듈: Compute (ECS, ALB)
# ============================================================================

module "compute" {
  source = "./modules/compute"

  project_name                = var.project_name
  aws_region                  = var.aws_region
  vpc_id                      = module.network.vpc_id
  public_subnet_ids           = module.network.public_subnet_ids
  private_app_subnet_ids      = module.network.private_app_subnet_ids
  alb_security_group_id       = module.security.alb_security_group_id
  ecs_task_security_group_id  = module.security.ecs_task_security_group_id
  ecs_task_execution_role_arn = module.security.ecs_task_execution_role_arn
  ecs_task_role_arn           = module.security.ecs_task_role_arn
  cloudwatch_log_group_name   = module.monitoring_base.cloudwatch_log_group_name
  db_secret_arn               = aws_secretsmanager_secret.db_credentials.arn
  ecs_cluster_name            = var.ecs_cluster_name
  ecs_service_name            = var.ecs_service_name
  ecs_task_cpu                = var.ecs_task_cpu
  ecs_task_memory             = var.ecs_task_memory
  ecs_desired_count           = var.ecs_desired_count
  ecs_min_count               = var.ecs_min_count
  ecs_max_count               = var.ecs_max_count
  ecs_cpu_scale_threshold     = var.ecs_cpu_scale_threshold
  docker_image                = var.docker_image
  tags                        = var.common_tags
}

# ============================================================================
# 모듈: Monitoring Alarms (주요 지표 알람 생성)
# ============================================================================
# 주의: Alarms는 compute와 database 모듈 이후에 생성되어야 함
# monitoring 모듈을 다시 호출하여 alarms 생성 (같은 SNS Topic 사용)

module "monitoring_alarms" {
  source = "./modules/monitoring"

  project_name                 = var.project_name
  cloudwatch_log_retention_days = var.cloudwatch_log_retention_days
  slack_webhook_url            = var.slack_webhook_url
  alb_arn_suffix                = split("/", module.compute.alb_arn)[1]
  ecs_cluster_name              = module.compute.ecs_cluster_name
  ecs_service_name              = module.compute.ecs_service_name
  rds_instance_id               = "${var.project_name}-db"
  tags                          = var.common_tags

  depends_on = [
    module.compute,
    module.database
  ]
}
