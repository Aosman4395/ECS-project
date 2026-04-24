variable "aws_region" {
  type    = string
  default = "eu-west-2"
}

variable "ecr_name" {
  description = "The ECR repository name"
  type        = string
  default     = "memos"
}

variable "s3_name" {
  description = "The S3 bucket name for Terraform state"
  type        = string
  default     = "ahamed-ecs-tf-state-2026"
}

variable "domain_name" {
  description = "Primary domain name for the certificate"
  type        = string
  default     = "tm.ahmedo.co.uk"
}