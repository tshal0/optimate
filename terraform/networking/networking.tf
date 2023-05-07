# Create a VPC
resource "aws_vpc" "app_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "Splitfest VPC"
  }
}


# Create Web Public Subnet
resource "aws_subnet" "web-subnet" {
  count                   = length(var.public_cidrs)
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = var.public_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "Web-Subnet-${count.index + 1}"
  }
}


# Create Application Public Subnet
resource "aws_subnet" "app-subnet" {
  count                   = length(var.private_cidrs)
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = var.private_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "Application-Subnet-${count.index + 1}"
  }
}


# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "Splitfest IGW"
  }
}

# Create Web Route Table
resource "aws_route_table" "web-rt" {
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "WebRT"
  }
}
# Create AWS Route
resource "aws_route" "public" {
  route_table_id         = aws_route_table.web-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# NAT Gateway,route non-local traffic
# Create a NAT gateway with an Elastic IP for each private subnet to get internet connectivity
resource "aws_eip" "gw" {
  count      = var.az_count
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "gw" {
  count         = var.az_count
  subnet_id     = element(aws_subnet.web-subnet.*.id, count.index)
  allocation_id = element(aws_eip.gw.*.id, count.index)
}

# Create a new route table for the private subnets, make it route non-local traffic through the NAT gateway to the internet
resource "aws_route_table" "private" {
  count  = var.az_count
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.gw.*.id, count.index)
  }
}

# Explicitly associate the newly created route tables to the private subnets (so they don't default to the main route table)
resource "aws_route_table_association" "private" {
  count          = var.az_count
  subnet_id      = element(aws_subnet.app-subnet.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.app_vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private[0].id]
}


resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.app_vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.app-sg.id]
  subnet_ids          = aws_subnet.app-subnet.*.id

}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.app_vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.app-sg.id]
  subnet_ids          = aws_subnet.app-subnet.*.id
}
resource "aws_vpc_endpoint" "ecs_agent" {
  vpc_id              = aws_vpc.app_vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.ecs-agent"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.app-sg.id]
  subnet_ids          = aws_subnet.app-subnet.*.id


}
resource "aws_vpc_endpoint" "ecs-telemetry" {
  vpc_id              = aws_vpc.app_vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.ecs-telemetry"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.app-sg.id]
  subnet_ids          = aws_subnet.app-subnet.*.id

}









# Create Web subnet association with Web route table
resource "aws_route_table_association" "public_assoc" {
  count          = length(var.public_cidrs)
  subnet_id      = aws_subnet.web-subnet.*.id[count.index]
  route_table_id = aws_route_table.web-rt.id
}

############# SECURITY GROUPS #############
# Create Web Security Group
resource "aws_security_group" "alb-sg" {
  name        = "ALB-SG"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.app_vpc.id

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  tags = {
    Name = "ALB-SG"
  }
}

# Create Application Security Group
resource "aws_security_group" "app-sg" {
  name        = "APP-SG"
  description = "Allow inbound traffic from ALB"
  vpc_id      = aws_vpc.app_vpc.id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.alb-sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "APP-SG"
  }
}

############# LOAD BALANCER #############
# Create internet facing ALB
resource "aws_alb" "external-alb" {
  name               = "splitfest-alb" #load balancer name
  load_balancer_type = "application"
  internal           = false
  subnets            = aws_subnet.web-subnet[*].id
  # security group
  security_groups = [aws_security_group.alb-sg.id]
}

############# LOAD BALANCER TARGET GROUP #############
resource "aws_lb_target_group" "external-alb-tg" {
  name_prefix = "ALB-TG"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.app_vpc.id
  target_type = "ip"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  lifecycle {
    create_before_destroy = true
  }
}

############# LOAD BALANCER LISTENERS #############
resource "aws_lb_listener" "external-elb1" {
  load_balancer_arn = aws_alb.external-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"

    }
  }
}

resource "aws_lb_listener" "external-alb2" {
  load_balancer_arn = aws_alb.external-alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.external-alb-tg.arn
  }
}


