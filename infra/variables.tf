#VPC variables
variable "vpc_name" {
    description = "The VPC for ECS"
    type        = string
    default     = "ecs_vpc"
}

variable "vpc_cidr" {
  description = "Value of cidr"
  type = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = [   
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}
  
variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
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
  default     = 5230
}
variable "log_group_name" {
  description = "Name of the CloudWatch log group"
  type        = string
  default     = "/ecs/my-app-log-group"
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

