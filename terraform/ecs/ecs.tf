# --- ecs/ecs.tf --- #

# Create ECS Cluster
resource "aws_ecs_cluster" "app_cluster" {
  name = "${var.app_name}-cluster" # Name your cluster here
}

# Create Cloudwatch Log Group
# resource "aws_cloudwatch_log_group" "app_cw_log_group" {
#   name = "${var.app_name}-lg"

#   tags = {
#     Environment = "production"
#     Application = "${var.app_name}"
#   }
# }

resource "aws_cloudwatch_log_group" "ecs_cw_log_group_ui" {
  name = lower("${var.app_name}-ui-logs")

  tags = {
    Environment = "production"
    Application = "${var.app_name}"
  }
}
resource "aws_cloudwatch_log_group" "ecs_cw_log_group_api" {
  name = lower("${var.app_name}-api-logs")

  tags = {
    Environment = "production"
    Application = "${var.app_name}"
  }
}

# Create ECS Task Definition for launcing service containers
resource "aws_ecs_task_definition" "app_task_ui" {
  family                   = lower("${var.app_name}-ui-task") # Name your task
  container_definitions    = <<DEFINITION
  [
    {
      "name": "${lower("${var.app_name}-ui-task")}",
      "image": "${var.ecr_repositories["${var.app_name}-ui"]}",
      "essential": true,
      "environment": [
        {"name": "SHOP", "value": "${var.shop}"},
        {"name": "PORT", "value": "8080"},
        {"name": "HOST", "value": "${var.host}"},
        {"name": "SHOPIFY_API_KEY", "value": "${var.shopify_api_key}"},
        {"name": "SHOPIFY_API_SECRET", "value": "${var.shopify_api_secret}"}
      ],
      "portMappings": [
        {
          "containerPort": ${var.ui_port},
          "hostPort": ${var.ui_port}
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${var.app_name}-ui-logs",
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
resource "aws_ecs_task_definition" "app_task_api" {
  family                   = lower("${var.app_name}-api-task") # Name your task
  container_definitions    = <<DEFINITION
  [
    {
      "name": "${lower("${var.app_name}-api-task")}",
      "image": "${var.ecr_repositories["${var.app_name}-api"]}",
      "essential": true,
      "environment": [
        {"name": "SHOP", "value": "${var.shop}"},
        {"name": "PORT", "value": "${var.api_port}"},
        {"name": "HOST", "value": "${var.host}"},
        {"name": "SHOPIFY_API_KEY", "value": "${var.shopify_api_key}"},
        {"name": "SHOPIFY_API_SECRET", "value": "${var.shopify_api_secret}"}
      ],
      "portMappings": [
        {
          "containerPort": ${var.api_port},
          "hostPort": ${var.api_port}
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${var.app_name}-api-logs",
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


# Create IAM ECS Task Execution Role
resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
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
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Create ECS Service
resource "aws_ecs_service" "app_service_ui" {
  name                 = "${var.app_name}-ui-service"            # Name the service
  cluster              = aws_ecs_cluster.app_cluster.id          # Reference the created Cluster
  task_definition      = aws_ecs_task_definition.app_task_ui.arn # Reference the task that the service will spin up
  launch_type          = "FARGATE"
  desired_count        = 3    # Set up the number of containers to 3
  force_new_deployment = true # Force deployment on new revision
  load_balancer {
    target_group_arn = var.target_group_ui # Reference the target group
    container_name   = aws_ecs_task_definition.app_task_ui.family
    container_port   = var.ui_port # Specify the container port
  }

  network_configuration {
    subnets          = var.private_subnets
    assign_public_ip = false        # Disable public IPs
    security_groups  = [var.app_sg] # Set up the security group
  }
}
resource "aws_ecs_service" "app_service_api" {
  name                 = "${var.app_name}-api-service"            # Name the service
  cluster              = aws_ecs_cluster.app_cluster.id           # Reference the created Cluster
  task_definition      = aws_ecs_task_definition.app_task_api.arn # Reference the task that the service will spin up
  launch_type          = "FARGATE"
  desired_count        = 3    # Set up the number of containers to 3
  force_new_deployment = true # Force deployment on new revision
  load_balancer {
    target_group_arn = var.target_group_api # Reference the target group
    container_name   = aws_ecs_task_definition.app_task_api.family
    container_port   = var.api_port # Specify the container port
  }

  network_configuration {
    subnets          = var.private_subnets
    assign_public_ip = false        # Disable public IPs
    security_groups  = [var.app_sg] # Set up the security group
  }
}
