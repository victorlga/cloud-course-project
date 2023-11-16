variable "rds_sg_id" {
  description = "VPC ID"
  type        = string
}

#variable engine {
#  description = "Engine"
#  type        = string
#}
#
#variable engine_version {
#  description = "Engine version"
#  type        = string
#}
#
#variable instance_class {
#  description = "Instance class"
#  type        = string
#}
#
#variable backup_window {
#  description = "Backup window"
#  type        = string
#}
#
#variable maintenance_window {
#  description = "Maintenance window"
#  type        = string
#}
#
#variable backup_retention_period {
#  description = "Backup retention period"
#  type        = number
#}
#
#variable allocated_storage {
#  description = "Allocated storage"
#  type        = number
#}
#
#variable multi_az {
#  description = "Multi AZ"
#  type        = bool
#}
#
variable "private_sub_1_id" {
  description = "The ID of the private subnet 1 where the instance will be launched"
  type        = string
}

variable "private_sub_2_id" {
  description = "The ID of the private subnet 2 where the instance will be launched"
  type        = string
}

#variable "password" {
#  description = "The password for the database"
#  type        = string
#}
#
#variable "username" {
#  description = "The username for the database"
#  type        = string
#}