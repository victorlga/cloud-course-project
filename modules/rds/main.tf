resource "aws_db_instance" "db" {
  allocated_storage       = var.allocated_storage
  storage_type            = var.storage_type
  engine                  = var.engine
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  name                    = var.name
  username                = var.username
  password                = var.password
  parameter_group_name    = var.parameter_group_name
  db_subnet_group_name    = aws_db_subnet_group.my_db_subnet_group.name
  vpc_security_group_ids  = [var.rds_sg_id]
  
  final_snapshot_identifier = "my-final-rds-snapshot-${formatdate("YYYYMMDDHHmmss", timestamp())}"

  backup_retention_period = var.backup_retention_period
  backup_window = var.backup_window
  maintenance_window = var.maintenance_window

  multi_az = var.multi_az
  
  tags = {
    Name = "My DB Instance"
  }

}

resource "aws_db_subnet_group" "my_db_subnet_group" {
  name       = "my-db-subnet-group"
  subnet_ids = [var.private_sub_1_id, var.private_sub_2_id]

  tags = {
    Name = "My DB Subnet Group"
  }
}