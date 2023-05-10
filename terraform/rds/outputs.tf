

output "db" {
  value = aws_db_instance.db
}
output "rds_domain" {
  value = aws_db_instance.db.address
}
output "rds_port" {
  value = aws_db_instance.db.port
}
