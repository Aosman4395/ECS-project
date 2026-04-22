output "state_bucket" {
  value       = aws_s3_bucket.terraform_state.bucket
  description = "S3 bucket name for terraform state"
}

output "region" {
  value       = "eu-west-2"
  description = "AWS region"
}