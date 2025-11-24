# Database Module

RDS PostgreSQL Active/Standby 구조를 생성하는 모듈입니다.
Multi-AZ 설정으로 Primary (Active)와 Standby가 자동으로 생성되며,
Primary 장애 시 자동으로 Standby가 승격되어 failover 처리됩니다.

## 사용 예시

```hcl
module "database" {
  source = "./modules/database"

  project_name                  = "receipt-api"
  private_db_subnet_ids         = module.network.private_db_subnet_ids
  rds_security_group_id         = module.security.rds_security_group_id
  rds_instance_class            = "db.t3.medium"
  rds_multi_az                  = true  # Active/Standby 구조
  tags                          = {}
}
```

## 출력

- `rds_endpoint`: RDS Primary (Active) 엔드포인트
- `rds_address`: RDS Primary (Active) 주소
- `rds_port`: RDS 포트

