output "ec2_profile_name" {
  description = "The name of the IAM instance profile for EC2 instances"
  value = aws_iam_instance_profile.ec2_profile.name
}

# output "rds_role_arn" {
#     description = "The ARN of the IAM role for RDS instances"
#     value = aws_iam_role.rds_role.arn
# }