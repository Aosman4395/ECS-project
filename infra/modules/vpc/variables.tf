variable "vpc_name" {
  description = "The VPC for ECS"
  type        = string
  default     = "ecs_vpc"
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
  default     = ["us-east-1a", "us-east-1b"]
}

