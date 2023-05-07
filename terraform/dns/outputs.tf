# --- dns/outputs.tf ---

output "certificate" {
  value = aws_acm_certificate_validation.dns.certificate_arn
}
