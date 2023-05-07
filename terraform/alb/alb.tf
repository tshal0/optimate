# --- alb/alb.tf --- #

############# LOAD BALANCER #############
# Create internet facing ALB
resource "aws_alb" "alb" {
  name               = "${var.app_name}-alb" #load balancer name
  load_balancer_type = "application"
  internal           = var.internal
  subnets            = var.subnets         # external/public subnets
  security_groups    = var.security_groups # security groups
}

############# LOAD BALANCER TARGET GROUP #############
resource "aws_alb_target_group" "alb_tg_ui" {
  name        = "${var.app_name}-alb-tg-ui"
  port        = var.alb_tg_ui_port
  protocol    = var.alb_tg_ui_protocol
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    path     = "/"
    protocol = "HTTP"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_alb_target_group" "alb_tg_api" {
  name        = "${var.app_name}-alb-tg-api"
  port        = var.alb_tg_api_port
  protocol    = var.alb_tg_api_protocol
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    path     = "/api/health"
    protocol = "HTTP"
  }
  lifecycle {
    create_before_destroy = true
  }
}

############# LOAD BALANCER LISTENERS #############
resource "aws_alb_listener" "http_to_https" {
  load_balancer_arn = aws_alb.alb.arn
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

resource "aws_alb_listener" "https_to_ui" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.alb_tg_ui.arn
  }
}

# Create listener rules
resource "aws_alb_listener_rule" "https_to_api_rule" {
  listener_arn = aws_alb_listener.https_to_ui.arn
  priority     = 1
  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.alb_tg_api.arn
  }
  condition {
    path_pattern {
      values = ["/api*"]
    }
  }
}
resource "aws_alb_listener_rule" "https_to_ui_rule" {
  listener_arn = aws_alb_listener.https_to_ui.arn
  priority     = 2
  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.alb_tg_ui.arn
  }
  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}
