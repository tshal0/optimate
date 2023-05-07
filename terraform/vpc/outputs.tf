# --- vpc/outputs.tf ---

output "vpc_id" {
  value = aws_vpc.app_vpc.id
}

output "alb_sg" {
  value = aws_security_group.alb_sg.id
}

output "app_sg" {
  value = aws_security_group.app_sg.id
}

output "public_subnets" {
  value = aws_subnet.public[*].id
}

output "private_subnets" {
  value = aws_subnet.private[*].id
}

output "vpc_security_group_id" {
  value = aws_security_group.alb_sg.id
}
