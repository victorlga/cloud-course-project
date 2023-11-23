output "locust_endpoint" {
  value = aws_instance.ec2_locust.public_dns
}