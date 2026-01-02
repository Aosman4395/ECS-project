# VPC outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

# ACM output
output "acm_domain_validation_options" {
  description = "DNS records required to validate the ACM certificate"
  value       = module.acm.domain_validation_options
}


