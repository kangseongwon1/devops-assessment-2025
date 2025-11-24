output "rds_endpoint" {
  description = "RDS 인스턴스 엔드포인트"
  value       = aws_db_instance.main.endpoint
}

output "rds_address" {
  description = "RDS 인스턴스 주소"
  value       = aws_db_instance.main.address
}

output "rds_port" {
  description = "RDS 인스턴스 포트"
  value       = aws_db_instance.main.port
}

# Active/Standby 구조: Standby는 Multi-AZ로 자동 생성되며
# Primary 엔드포인트만 사용 (failover 시 자동으로 Standby로 전환)

output "db_subnet_group_name" {
  description = "DB Subnet Group 이름"
  value       = aws_db_subnet_group.main.name
}

