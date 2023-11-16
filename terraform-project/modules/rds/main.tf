resource "aws_db_instance" "db" {
  allocated_storage       = 20
  storage_type            = "gp2"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t2.micro"
  name                    = "mysql_db"
  username                = "username"
  password                = "super_secret_password"
  parameter_group_name    = "default.mysql8.0"
  db_subnet_group_name    = aws_db_subnet_group.my_db_subnet_group.name
  vpc_security_group_ids  = [var.rds_sg_id]
  
  final_snapshot_identifier = "my-final-rds-snapshot-${formatdate("YYYYMMDDHHmmss", timestamp())}"

  backup_retention_period = 7
  backup_window = "03:00-04:00"
  maintenance_window = "Sun:04:00-Sun:05:00"

  multi_az = true
}

resource "aws_db_subnet_group" "my_db_subnet_group" {
  name       = "my-db-subnet-group"
  subnet_ids = [var.private_sub_1_id, var.private_sub_2_id]

  tags = {
    Name = "My DB Subnet Group"
  }
}

resource "null_resource" "db_setup" {
  depends_on = [aws_db_instance.db]

  provisioner "local-exec" {
    command = "mysql -h ${aws_db_instance.db.address} -u username -psuper_secret_password -e 'SOURCE script.sql'"
  }
}

##resource "aws_db_instance" "db" {
##  engine                      = var.engine
##  engine_version              = var.engine_version
##  instance_class              = var.instance_class
##  vpc_security_group_ids      = [var.mysql_sg_id]
##  allocated_storage           = var.allocated_storage
##  multi_az                    = var.multi_az
##  backup_retention_period     = var.backup_retention_period
##  backup_window               = var.backup_window
##  maintenance_window          = var.maintenance_window
##  db_subnet_group_name        = aws_db_subnet_group.my_db_subnet_group.name
##  username                    = var.username 
##  password                    = var.password
##  final_snapshot_identifier   = "db-final-snapshot-${formatdate("YYYYMMDDHHmmss", timestamp())}"
##  
##  #provisioner "local-exec" {
##  #  command = "mysql -u ${var.username} -p${var.password} -h ${self.address} -e 'CREATE DATABASE trembolona;'"
##  #}
##}