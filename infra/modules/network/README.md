# Network Module

VPC, Subnets, Internet Gateway, NAT Gateway, Route Tables를 생성하는 모듈입니다.

## 사용 예시

```hcl
module "network" {
  source = "./modules/network"

  project_name              = "receipt-api"
  vpc_cidr                  = "10.0.0.0/16"
  availability_zones         = ["ap-northeast-2a", "ap-northeast-2c"]
  public_subnet_cidrs        = ["10.0.1.0/24", "10.0.2.0/24"]
  private_app_subnet_cidrs   = ["10.0.11.0/24", "10.0.12.0/24"]
  private_db_subnet_cidrs    = ["10.0.21.0/24", "10.0.22.0/24"]
  tags                       = {}
}
```

## 출력

- `vpc_id`: VPC ID
- `public_subnet_ids`: Public Subnet IDs
- `private_app_subnet_ids`: Private Application Subnet IDs
- `private_db_subnet_ids`: Private Database Subnet IDs

