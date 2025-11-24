# Storage Module

S3 버킷을 생성하는 모듈입니다.

## 사용 예시

```hcl
module "storage" {
  source = "./modules/storage"

  project_name = "receipt-api"
  account_id   = data.aws_caller_identity.current.account_id
  tags         = {}
}
```

## 출력

- `s3_bucket_name`: S3 버킷 이름
- `s3_bucket_arn`: S3 버킷 ARN

