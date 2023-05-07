# --- alb/outputs.tf --- #

output "target_groups" {
  value = [aws_alb_target_group.alb_tg_api, aws_alb_target_group.alb_tg_ui]
}

output "target_group_ui" {
  value = aws_alb_target_group.alb_tg_ui.arn
}

output "target_group_api" {
  value = aws_alb_target_group.alb_tg_api.arn
}

output "alb" {
  value = aws_alb.alb
}
output "dns_name" {
  value = aws_alb.alb.dns_name
}
