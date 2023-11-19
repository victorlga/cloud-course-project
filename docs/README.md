# Cloud Course Project

## Project Overview
This project automates the provisioning of a scalable and resilient public cloud infrastructure on AWS using Terraform. It is designed to deploy a simple Python-based RESTful API, supported by a robust backend infrastructure that includes an Application Load Balancer (ALB), Auto Scaling EC2 instances, and an RDS PostgreSQL database.

## Infrastructure Components

### Networking
- **VPC**: A custom Virtual Private Cloud (VPC) is set up with a CIDR block of `10.0.0.0/16`.
- **Subnets**: Includes both public (`10.0.1.0/24`, `10.0.2.0/24`) and private (`10.0.3.0/24`, `10.0.4.0/24`) subnets spread across two availability zones for high availability.

### Application Load Balancer (ALB)
- Configured to distribute incoming traffic across EC2 instances in private subnets, ensuring efficient load handling and fault tolerance.

### EC2 Instances and Auto Scaling
- EC2 instances are deployed within the private subnets, running a Python RESTful API.
- Auto Scaling is configured to automatically adjust the number of instances based on load with AWS CloudWatch Metric Alarms, ensuring efficient resource utilization.
- Application running on EC2 instances is monitored using AWS CloudWatch logs.

### RDS PostgreSQL Database
- A PostgreSQL database instance is provisioned in the private subnets, offering secure and scalable database services.
- Configured for multi-AZ deployments for high availability and automated backups for data durability.

### Security Groups
- Defined for ALB, EC2 instances, and RDS to ensure secure access control. 
- The ALB security group allows HTTP/HTTPS traffic, whereas the EC2 security group permits traffic from the ALB. The RDS security group allows database connections from EC2 instances.

### NAT Gateways and Route Tables
- NAT Gateways are set up in each public subnet to enable outbound internet access for resources in the private subnets.
- Route Tables are configured for both public and private subnets to control network routing.

## Deployment and Management
- All resources are defined and managed using Terraform, providing a reliable and repeatable process for infrastructure deployment.
- The infrastructure's configuration is modularized for better organization and easier maintenance.

## Future Enhancements
- Integration of load testing tools **(TBD)** to assess the application performance.

## Getting Started
To deploy this infrastructure, ensure you have Terraform installed and configured with AWS credentials. Follow the steps below:

1. Initialize Terraform: `terraform init`
2. Plan the deployment: `terraform plan`
3. Apply the configuration: `terraform apply`

Upon successful deployment, your AWS environment will be ready to host the Python RESTful API with all the supporting AWS services configured as per the above architecture.