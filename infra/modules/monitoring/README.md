# Monitoring Module

CloudWatch Logs와 SNS Topic을 생성하는 모듈입니다.

## 사용 예시

```hcl
module "monitoring" {
  source = "./modules/monitoring"

  project_name                 = "receipt-api"
  cloudwatch_log_retention_days = 7
  slack_webhook_url            = "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"  # 선택사항
  tags                          = {}
}
```

## 출력

- `cloudwatch_log_group_name`: CloudWatch Log Group 이름
- `cloudwatch_log_group_arn`: CloudWatch Log Group ARN
- `sns_topic_arn`: SNS 알림 토픽 ARN

