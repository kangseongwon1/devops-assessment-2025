# Compute Module

ECS Cluster, Service, Task Definition, Application Load Balancer를 생성하는 모듈입니다.

## 사용 예시

```hcl
module "compute" {
  source = "./modules/compute"

  project_name                = "receipt-api"
  vpc_id                      = module.network.vpc_id
  public_subnet_ids           = module.network.public_subnet_ids
  private_app_subnet_ids      = module.network.private_app_subnet_ids
  alb_security_group_id       = module.security.alb_security_group_id
  ecs_task_security_group_id  = module.security.ecs_task_security_group_id
  ecs_task_execution_role_arn = module.security.ecs_task_execution_role_arn
  ecs_task_role_arn           = module.security.ecs_task_role_arn
  cloudwatch_log_group_name   = module.monitoring.cloudwatch_log_group_name
  db_secret_arn               = aws_secretsmanager_secret.db.arn
  docker_image                = "ghcr.io/spandit/receipt-api:latest"
  tags                        = {}
}
```

## 출력

- `alb_dns_name`: ALB DNS 이름
- `ecs_cluster_name`: ECS 클러스터 이름
- `api_url`: API 엔드포인트 URL

