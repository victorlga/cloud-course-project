output "db_endpoint" {
  description = "The DNS endpoint of the database"
  value       = aws_db_instance.db.endpoint
}