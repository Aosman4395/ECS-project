#VPC variables
variable "vpc_name" {
  description = "The VPC for ECS"
  type        = string
  default     = "ecs_vpc"
}

variable "s3_name" {
  description = "The S3 bucket name for Terraform state"
  type        = string
  default     = "ahamed-ecs-tf-state-2026"
}

variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "eu-west-2"
}

variable "vpc_cidr" {
  description = "Value of cidr"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["eu-west-2a", "eu-west-2b"]
}

#ALB variables

variable "alb_name" {
  description = "Name of the Application Load Balancer"
  type        = string
  default     = "ecs-alb"
}


#ECS variables
variable "container_name" {
  description = "Name of the container"
  type        = string
  default     = "my-app-container"
}


variable "image_tag" {
  description = "Docker image tag (commit SHA)"
  type        = string
}


variable "container_port" {
  description = "Port on which the container listens"
  type        = number
  default     = 8081
}
variable "log_group_name" {
  description = "Name of the CloudWatch log group"
  type        = string
  default     = "/ecs/my-app-log-group"
}

variable "ecr_repository_url" {
  description = "ECR repository URL for the application image"
  type        = string
  default     = "123456789012.dkr.ecr.eu-west-2.amazonaws.com/my-app-repo"
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate for the ALB"
  type        = string
  default     = "arn:aws:acm:eu-west-2:409987738946:certificate/1f925ef1-cad7-42b1-bb70-988594b760ae"
}