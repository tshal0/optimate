# --- networking/outputs.tf ---

output "vpc_id" {
  value = aws_vpc.app_vpc.id
}

output "web_sg" {
  value = aws_security_group.alb-sg.id
}

output "app_sg" {
  value = aws_security_group.app-sg.id
}

output "web_subnets" {
  value = aws_subnet.web-subnet[*].id
}

output "app_subnets" {
  value = aws_subnet.app-subnet[*].id
}

output "vpc_security_group_id" {
  value = aws_security_group.alb-sg.id
}

output "external-alb" {
  value = aws_alb.external-alb
}
output "target_group" {
  value = aws_lb_target_group.external-alb-tg
}

output "lb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_alb.external-alb.dns_name
}
