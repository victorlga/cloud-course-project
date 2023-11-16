variable "ami" {
  description = "The AMI to be used for the EC2 instance"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "instance_type" {
  description = "The type of instance (e.g., t2.micro)"
  type        = string
}

variable "public_sub_1_id" {
  description = "CIDR block for the public subnet 1"
  type        = string
}

variable "public_sub_2_id" {
  description = "CIDR block for the public subnet 1"
  type        = string
}

variable "private_sub_1_id" {
  description = "CIDR block for the private subnet 1"
  type        = string
}

variable "private_sub_2_id" {
  description = "CIDR block for the private subnet 2"
  type        = string
}

variable "ec2_sg_id" {
  description = "The ID of the VPC security group to be associated with the instance"
  type        = string
}

variable "alb_sg_id" {
  description = "The ID of the VPC security group to be associated with the ALB"
  type        = string
}

variable "db_address" {
  description = "The address of the database"
  type        = string
}