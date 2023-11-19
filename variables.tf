variable "db_password" {
  description = "DB password"
  type        = string
  default     = "database_password"
}

variable "db_name" {
  description = "The name of the database"
  type        = string
  default     = "database_name"
}

variable "db_username" {
  description = "The username for the database"
  type        = string
  default     = "database_user"
}