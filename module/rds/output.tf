output "rds_hostname" {
  description = "RDS instance hostname"
  value       = aws_db_instance.rds-mysql.address
  sensitive   = true
}

output "rds_port" {
  description = "RDS instance port"
  value       = aws_db_instance.rds-mysql.port
  sensitive   = true
}

output "rds_username" {
  description = "RDS instance root username"
  value       = aws_db_instance.rds-mysql.username
  sensitive   = true
}

output "rds_endpoint" {
  value = aws_db_instance.rds-mysql.endpoint
}