output "db_address" {
  description = "The address of the database"
  value       = aws_db_instance.db.address
}