# Infrastructure as Code (Terraform)

본 디렉토리에는 영수증 분석 API의 AWS 인프라를 정의하는 Terraform 코드가 포함되어 있습니다.

## 📋 구조

```
infra/
├── main.tf                      # 모듈 호출 및 조합
├── variables.tf                 # 입력 변수 정의
├── outputs.tf                   # 출력 값 정의
├── terraform.tfvars.example     # 변수 예제 파일
├── README.md                    # 본 문서
└── modules/                     # 재사용 가능한 모듈
    ├── network/                 # VPC, Subnets, NAT Gateway
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── README.md
    ├── security/                # Security Groups, IAM
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── README.md
    ├── compute/                 # ECS, ALB
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── README.md
    ├── database/                # RDS
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── README.md
    ├── storage/                 # S3
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── README.md
    └── monitoring/              # CloudWatch, SNS
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        └── README.md
```

## 🏗️ 모듈 구조

인프라는 재사용 가능한 모듈로 구성되어 있습니다:

1. **network**: VPC, Subnets, Internet Gateway, NAT Gateway
2. **security**: Security Groups, IAM Roles
3. **storage**: S3 Bucket
4. **monitoring**: CloudWatch Logs, SNS Topic
5. **database**: RDS Primary (Active/Standby - Multi-AZ)
6. **compute**: ECS Cluster, Service, ALB

각 모듈은 독립적으로 재사용 가능하며, 다른 프로젝트에서도 활용할 수 있습니다.

## 🏗️ 구성 요소

### 네트워크
- VPC (10.0.0.0/16)
- Public Subnets (2개 AZ)
- Private Application Subnets (2개 AZ)
- Private Database Subnets (2개 AZ)
- Internet Gateway
- NAT Gateway (2개)
- Route Tables

### 보안
- Security Groups (ALB, ECS, RDS)
- IAM Roles 및 Policies
- Secrets Manager (DB 자격 증명)

### 컴퓨팅
- ECS Cluster (Fargate)
- ECS Service
- ECS Task Definition
- Auto Scaling

### 데이터베이스
- RDS PostgreSQL Primary (Multi-AZ)
- RDS Standby (Multi-AZ로 자동 생성)
- DB Subnet Group

### 로드 밸런싱
- Application Load Balancer
- Target Group
- HTTPS Listener (HTTP → HTTPS 리다이렉트)

### 스토리지
- S3 Bucket (영수증 이미지)

### 모니터링
- CloudWatch Logs
- CloudWatch Alarms
- SNS Topic (알림)

## 🚀 사용 방법

### 사전 요구사항

1. **Terraform 설치** (>= 1.5.0)
   ```bash
   # macOS
   brew install terraform
   
   # Linux
   wget https://releases.hashicorp.com/terraform/1.5.0/terraform_1.5.0_linux_amd64.zip
   unzip terraform_1.5.0_linux_amd64.zip
   sudo mv terraform /usr/local/bin/
   ```

2. **AWS CLI 설정**
   ```bash
   aws configure
   ```

3. **변수 파일 생성**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # terraform.tfvars 파일을 편집하여 실제 값으로 수정
   ```

### 초기화 및 실행

```bash
# 1. Terraform 초기화
terraform init

# 2. 실행 계획 확인
terraform plan

# 3. 인프라 생성 (실제 환경에서는 실행하지 않음)
# terraform apply

# 4. 인프라 삭제 (필요 시)
# terraform destroy
```

## ⚙️ 주요 변수

| 변수 | 설명 | 기본값 |
|------|------|--------|
| `aws_region` | AWS 리전 | `ap-northeast-2` |
| `project_name` | 프로젝트 이름 | `receipt-api` |
| `ecs_desired_count` | ECS 태스크 수 | `2` |
| `ecs_min_count` | 최소 태스크 수 | `2` |
| `ecs_max_count` | 최대 태스크 수 | `10` |
| `rds_instance_class` | RDS 인스턴스 클래스 | `db.t3.medium` |
| `rds_multi_az` | Multi-AZ 활성화 | `true` |
| `rds_multi_az` | Multi-AZ 활성화 (Active/Standby) | `true` |

## 📤 출력 값

Terraform 실행 후 다음 출력 값을 확인할 수 있습니다:

- `api_url`: API 엔드포인트 URL
- `alb_dns_name`: ALB DNS 이름
- `rds_endpoint`: RDS Primary 엔드포인트
- `rds_endpoint`: RDS Primary (Active) 엔드포인트 (Standby는 Multi-AZ로 자동 관리)
- `s3_bucket_name`: S3 버킷 이름
- `ecs_cluster_name`: ECS 클러스터 이름

```bash
terraform output
```

## 🔒 보안 고려사항

### 중요: 프로덕션 환경 설정

1. **비밀 정보 관리**
   - `terraform.tfvars` 파일을 `.gitignore`에 추가
   - DB 비밀번호는 Secrets Manager에서 수동으로 설정
   - Terraform 상태 파일은 S3 백엔드에 저장 (암호화)

2. **상태 파일 백엔드 설정**
   ```hcl
   # backend.tf 파일 생성
   terraform {
     backend "s3" {
       bucket = "spandit-terraform-state"
       key    = "receipt-api/terraform.tfstate"
       region = "ap-northeast-2"
       encrypt = true
     }
   }
   ```

3. **삭제 보호 활성화**
   - RDS Primary: `deletion_protection = true`
   - RDS Standby: Multi-AZ로 자동 관리 (스냅샷은 Primary와 함께 관리)
   - ALB: `enable_deletion_protection = true`

4. **ACM 인증서 설정**
   - 실제 환경에서는 ACM 인증서를 생성하고 ALB에 연결
   - Route 53으로 도메인 관리

## 💰 비용 최적화

### 리소스 최적화 팁

1. **개발 환경**
   - RDS Multi-AZ 비활성화 (`rds_multi_az = false`)
   - ECS 태스크 수 최소화 (`ecs_desired_count = 1`)
   - RDS 인스턴스 클래스 축소 (`db.t3.small`)

2. **프로덕션 환경**
   - 예약 인스턴스 사용 (RDS Primary)
   - Multi-AZ Active/Standby 구조로 고가용성 보장
   - S3 Lifecycle Policy로 오래된 이미지 아카이빙
   - Standby는 Multi-AZ로 자동 생성 및 관리

## 🔄 업데이트 및 유지보수

### 인프라 변경 시

```bash
# 1. 변경사항 확인
terraform plan

# 2. 변경사항 적용
terraform apply

# 3. 특정 리소스만 업데이트
terraform apply -target=aws_ecs_service.main
```

### 모듈화 (향후 개선)

대규모 프로젝트의 경우 모듈로 분리하는 것을 권장합니다:

```
infra/
├── modules/
│   ├── network/
│   ├── compute/
│   ├── database/
│   └── monitoring/
├── environments/
│   ├── dev/
│   ├── staging/
│   └── prod/
└── main.tf
```

## 📚 참고 자료

- [Terraform AWS Provider 문서](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

---

**주의**: 본 Terraform 코드는 평가용으로 작성되었으며, 실제 프로덕션 환경에 적용하기 전에 보안 및 비용 최적화를 검토해야 합니다.

