variable "alb_sg_name" {
  description = "Security group for Application Load Balancer"
  type        = string
  default     = "alb-security-group"

}

variable "vpc_id" {
  description = "VPC ID where ECS resources are created"
  type        = string
}
