# Create ECR Repo
resource "aws_ecr_repository" "app_ecr_repo" {
  name = "splitfest"
}

# Create ECS Cluster
resource "aws_ecs_cluster" "app_cluster" {
  name = "splitfest-cluster" # Name your cluster here
}

# Create Cloudwatch Log Group
resource "aws_cloudwatch_log_group" "app_log_group" {
  name = "splitfest-lg"

  tags = {
    Environment = "production"
    Application = "splitfest"
  }
}

# Create ECS Task Definition for launcing service containers
resource "aws_ecs_task_definition" "app_task" {
  family                   = "splitfest-task" # Name your task
  container_definitions    = <<DEFINITION
  [
    {
      "name": "splitfest-task",
      "image": "${aws_ecr_repository.app_ecr_repo.repository_url}",
      "essential": true,
      "environment": [
        {"name": "SHOP", "value": "${var.shop}"},
        {"name": "PORT", "value": "${var.port}"},
        {"name": "HOST", "value": "${var.host}"},
        {"name": "SHOPIFY_API_KEY", "value": "${var.shopify_api_key}"},
        {"name": "SHOPIFY_API_SECRET", "value": "${var.shopify_api_secret}"}
      ],
      "portMappings": [
        {
          "containerPort": ${var.port},
          "hostPort": ${var.port}
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "splitfest-logs",
          "awslogs-region": "us-east-2",
          "awslogs-create-group": "true",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "memory": 512,
      "cpu": 256
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"] # use Fargate as the launch type
  network_mode             = "awsvpc"    # add the AWS VPN network mode as this is required for Fargate
  memory                   = 512         # Specify the memory the container requires
  cpu                      = 256         # Specify the CPU the container requires
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn
}

data "aws_ecs_task_definition" "main" {
  task_definition = aws_ecs_task_definition.app_task.family
}


# Create IAM ECS Task Execution Role
resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}

# Create IAM Policy for ECS Task Execution Role
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Attach IAM Policy to ECS Task Execution Role
resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = "${aws_iam_role.ecsTaskExecutionRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Create ECS Service
resource "aws_ecs_service" "app_service" {
  name            = "splitfest-service"     # Name the service
  cluster         = "${aws_ecs_cluster.app_cluster.id}"   # Reference the created Cluster
  task_definition = "${aws_ecs_task_definition.app_task.arn}" # Reference the task that the service will spin up
  launch_type     = "FARGATE"
  desired_count   = 3 # Set up the number of containers to 3
  force_new_deployment = true # Force deployment on new revision
  load_balancer {
    target_group_arn = "${var.target_group_arn}" # Reference the target group
    container_name   = "${aws_ecs_task_definition.app_task.family}"
    container_port   = var.port # Specify the container port
  }

  network_configuration {
    subnets            = var.app_subnets
    assign_public_ip   = false     # Disable public IPs
    security_groups    = [var.app_sg] # Set up the security group
  }
}
