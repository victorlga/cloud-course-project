output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.project_vpc.id
}

output "private_sub_1_id" {
  description = "The ID of the private subnet 1"
  value       = aws_subnet.private_subnet_1.id
}

output "public_sub_1_id" {
  description = "The ID of the public subnet 1"
  value       = aws_subnet.public_subnet_1.id
}

output "private_sub_2_id" {
  description = "The ID of the private subnet 2"
  value       = aws_subnet.private_subnet_2.id
}

output "public_sub_2_id" {
  description = "The ID of the public subnet 2"
  value       = aws_subnet.public_subnet_2.id
}