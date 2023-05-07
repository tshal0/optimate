# # main.tf
# terraform {
#   required_providers {
#     aws = {
#       source = "hashicorp/aws"
#       version = "4.45.0"
#     }
#   }
# }
# provider "aws" {
#   region  = "us-east-2" #The region where the environment
#   #is going to be deployed # Use your own region here
#   access_key = var.aws_access_key # Enter AWS IAM
#   secret_key = var.aws_secret_key # Enter AWS IAM
# }
# resource "aws_ecr_repository" "app_ecr_repo" {
#   name = "splitfest-repo"
# }
# resource "aws_ecs_cluster" "my_cluster" {
#   name = "splitfest-cluster" # Name your cluster here
# }
# resource "aws_cloudwatch_log_group" "app_log_group" {
#   name = "splitfest-lg"

#   tags = {
#     Environment = "production"
#     Application = "splitfest"
#   }
# }

# resource "aws_ecs_task_definition" "app_task" {
#   family                   = "splitfest-first-task" # Name your task
#   container_definitions    = <<DEFINITION
#   [
#     {
#       "name": "splitfest-first-task",
#       "image": "${aws_ecr_repository.app_ecr_repo.repository_url}",
#       "essential": true,
#       "environment": [
#         {"name": "SHOP", "value": "${var.shop}"},
#         {"name": "PORT", "value": "${var.port}"},
#         {"name": "HOST", "value": "${var.host}"},
#         {"name": "SHOPIFY_API_KEY", "value": "${var.shopify_api_key}"},
#         {"name": "SHOPIFY_API_SECRET", "value": "${var.shopify_api_secret}"}
#       ],
#       "portMappings": [
#         {
#           "containerPort": ${var.port},
#           "hostPort": ${var.port}
#         }
#       ],
#       "logConfiguration": {
#         "logDriver": "awslogs",
#         "options": {
#           "awslogs-group": "splitfest-logs",
#           "awslogs-region": "us-east-2",
#           "awslogs-create-group": "true",
#           "awslogs-stream-prefix": "ecs"
#         }
#       },
#       "memory": 512,
#       "cpu": 256
#     }
#   ]
#   DEFINITION
#   requires_compatibilities = ["FARGATE"] # use Fargate as the launch type
#   network_mode             = "awsvpc"    # add the AWS VPN network mode as this is required for Fargate
#   memory                   = 512         # Specify the memory the container requires
#   cpu                      = 256         # Specify the CPU the container requires
#   execution_role_arn       = "${aws_iam_role.ecsTaskExecutionRole.arn}"
# }
# resource "aws_iam_role" "ecsTaskExecutionRole" {
#   name               = "ecsTaskExecutionRole"
#   assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
# }

# data "aws_iam_policy_document" "assume_role_policy" {
#   statement {
#     actions = ["sts:AssumeRole"]

#     principals {
#       type        = "Service"
#       identifiers = ["ecs-tasks.amazonaws.com"]
#     }
#   }
# }

# resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
#   role       = "${aws_iam_role.ecsTaskExecutionRole.name}"
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
# }

# # Provide a reference to your default VPC
# resource "aws_default_vpc" "default_vpc" {
# }

# # Provide references to your default subnets
# resource "aws_default_subnet" "default_subnet_a" {
#   # Use your own region here but reference to subnet 1a
#   availability_zone = "us-east-2a"
# }

# resource "aws_default_subnet" "default_subnet_b" {
#   # Use your own region here but reference to subnet 1b
#   availability_zone = "us-east-2b"
# }
# # Create a security group for the load balancer:
# resource "aws_security_group" "load_balancer_security_group" {
#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"] # Allow traffic in from all sources
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }
# resource "aws_alb" "application_load_balancer" {
#   name               = "splitfest-alb" #load balancer name
#   load_balancer_type = "application"
#   subnets = [ # Referencing the default subnets
#     "${aws_default_subnet.default_subnet_a.id}",
#     "${aws_default_subnet.default_subnet_b.id}"
#   ]
#   # security group
#   security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
# }
# resource "aws_lb_target_group" "target_group" {
#   name        = "target-group"
#   port        = 80
#   protocol    = "HTTP"
#   target_type = "ip"
#   vpc_id      = "${aws_default_vpc.default_vpc.id}" # default VPC
# }

# resource "aws_lb_listener" "listener" {
#   load_balancer_arn = "${aws_alb.application_load_balancer.arn}" #  load balancer
#   port              = "80"
#   protocol          = "HTTP"
#   default_action {
#     type             = "forward"
#     target_group_arn = "${aws_lb_target_group.target_group.arn}" # target group
#   }
# }
# resource "aws_ecs_service" "app_service" {
#   name            = "splitfest-service"     # Name the service
#   cluster         = "${aws_ecs_cluster.my_cluster.id}"   # Reference the created Cluster
#   task_definition = "${aws_ecs_task_definition.app_task.arn}" # Reference the task that the service will spin up
#   launch_type     = "FARGATE"
#   desired_count   = 3 # Set up the number of containers to 3
#   force_new_deployment = true
#   load_balancer {
#     target_group_arn = "${aws_lb_target_group.target_group.arn}" # Reference the target group
#     container_name   = "${aws_ecs_task_definition.app_task.family}"
#     container_port   = var.port # Specify the container port
#   }

#   network_configuration {
#     subnets          = ["${aws_default_subnet.default_subnet_a.id}", "${aws_default_subnet.default_subnet_b.id}"]
#     assign_public_ip = true     # Provide the containers with public IPs
#     security_groups  = ["${aws_security_group.service_security_group.id}"] # Set up the security group
#   }
# }
# resource "aws_security_group" "service_security_group" {
#   ingress {
#     from_port = 0
#     to_port   = 0
#     protocol  = "-1"
#     # Only allowing traffic in from the load balancer security group
#     security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }
# #Log the load balancer app URL
# output "app_url" {
#   value = aws_alb.application_load_balancer.dns_name
# }
