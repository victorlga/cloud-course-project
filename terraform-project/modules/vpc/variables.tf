variable "vpc_cidr" {
  description = "CIDR block for the entire VPC"
  type        = string
}

variable "public_sub_1_cidr" {
  description = "CIDR block for the public subnet 1"
  type        = string
}

variable "public_sub_2_cidr" {
  description = "CIDR block for the public subnet 2"
  type        = string
}

variable "private_sub_1_cidr" {
  description = "CIDR block for the private subnet 1"
  type        = string
}

variable "private_sub_2_cidr" {
  description = "CIDR block for the private subnet 2"
  type        = string
}

variable "availability_zone_1" {
  description = "Availability zone 1"
  type        = string
}

variable "availability_zone_2" {
  description = "Availability zone 2"
  type        = string
}