#VPC Module

module "vpc" {
    
    source = "./modules/vpc"

    vpc_name = var.vpc_name
    vpc_cidr = var.vpc_cidr
    public_subnet_cidrs = var.public_subnet_cidrs
    availability_zones = var.availability_zones
}

#Security Group Module

module "sgs" {
  source = "./modules/sgs"

  vpc_id      = module.vpc.vpc_id
  alb_sg_name = "alb-sg"
}


#ALB Module

module "alb" {
  source = "./modules/alb"

  alb_name               = var.alb_name
  public_subnet_ids      = module.vpc.public_subnet_ids
  alb_security_group_ids = [module.sgs.alb_sg_id]
  vpc_id                 = module.vpc.vpc_id

}

#IAM Module

module "iam" {
  source = "./modules/iam"
}

#ECR Module

module "ecr" {
  source = "./modules/ecr"

  repository_name = "memos"
}

#acm Module

module "acm" {
  source = "./modules/acm"
  domain_name = "tm.ahmedo.co.uk"
}


#ECS Module

module "ecs" {
  source = "./modules/ecs"

  # Networking
  vpc_id                = module.vpc.vpc_id
  subnet_ids            = module.vpc.public_subnet_ids
  alb_security_group_id = module.sgs.alb_sg_id

  # Load balancer
  target_group_arn = module.alb.target_group_arn

  # Container
  container_name  = var.container_name
  container_image = "${module.ecr.repository_url}:${var.image_tag}"
  container_port  = var.container_port

  # IAM
  execution_role_arn = module.iam.execution_role_arn
  task_role_arn      = module.iam.task_role_arn

  # Logging
  log_group_name = var.log_group_name
  aws_region     = var.aws_region
}
