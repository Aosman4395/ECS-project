output "certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = aws_acm_certificate.this.arn
}

output "domain_validation_options" {
  description = "DNS records for ACM validation"
  value       = aws_acm_certificate.this.domain_validation_options
}
