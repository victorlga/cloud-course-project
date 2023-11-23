output "load_balancer_dns" {
  value = "${module.ec2.lb_endpoint}/docs"
}

output "locust_dns" {
  description = ""
  value = "${module.locust.locust_endpoint}:8089"
}