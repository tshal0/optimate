# splitfest terraform

## Goals

1. Provision the resources required to host both an API and UI in Docker containers.
2. Provision the resources required to host Docker images.
3. Provision the resources required to deploy new Docker images.

Resources provisioned:

1. Networking
   1. VPC
   2. Web Subnet
   3. Application Subnet
   4. Internet Gateway (IGW)
   5. Web Route Table
   6. Association: Web Subnet -> Web Route Table
   7. ALB Security Group
   8. App Security Group
   9. External Application Load Balancer (ALB)
   10. ALB Listener: HTTP
   11. ALB Listener: HTTPS (SSL)
2. DNS
   1. ACM Certificate Request
   2. AWS Route53 Zone: DNS
   3. AWS Route53 Records
      1. For each domain validation option in AWS ACM Certificates
   4. AWS ACM Certificate Validation: DNS
   5. AWS Route53 Record: WWW
      1. Type: A
      2. Alias
3. Service
   1. ECR Repository
      1. Stores images
   2. ECS Cluster
   3. Cloudwatch Log Group
   4. ECS Task Definition
      1. Defines how containers should be launched (services)
   5. IAM ECS Task Execution Role
      1. IAM Policy for ECS Task Execution Role
      2. Attach IAM Policy to ECS Task Execution Role
   6. ECS Service
      1. ECS Cluster
      2. Subnets: app (private)
      3. Security Groups: app (private)
      4. Task Definition
      5. Target Group ARN: external-alb-tg

Problem: Cant pull ECR
Solution:

1. VPC Endpoint for ECR
   1.

## Modules

```bash
ns-553.awsdns-05.net.
ns-1226.awsdns-25.org.
ns-1558.awsdns-02.co.uk.
ns-334.awsdns-41.com.
```

```bash
SOA ns-553.awsdns-05.net. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400
```
