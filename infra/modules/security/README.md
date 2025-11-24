# Security Module

Security Groups와 IAM Roles를 생성하는 모듈입니다.

## 사용 예시

```hcl
module "security" {
  source = "./modules/security"

  project_name              = "receipt-api"
  vpc_id                    = module.network.vpc_id
  db_secret_arn             = aws_secretsmanager_secret.db.arn
  s3_bucket_arn             = module.storage.s3_bucket_arn
  cloudwatch_log_group_arn  = module.monitoring.cloudwatch_log_group_arn
  tags                      = {}
}
```

## 출력

- `alb_security_group_id`: ALB Security Group ID
- `ecs_task_security_group_id`: ECS Task Security Group ID
- `rds_security_group_id`: RDS Security Group ID
- `ecs_task_execution_role_arn`: ECS Task Execution Role ARN
- `ecs_task_role_arn`: ECS Task Role ARN

