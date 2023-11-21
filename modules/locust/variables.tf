variable "ami" {
  description = "The AMI to be used for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "The type of instance (e.g., t2.micro)"
  type        = string
}

variable "ec2_sg_id" {
  description = "The ID of the VPC security group to be associated with the instance"
  type        = string
}

variable "public_sub_1_id" {
  description = "ID for the public subnet 1"
  type        = string
}

variable "lb_endpoint" {
  description = "The endpoint of the ALB"
  type        = string
}