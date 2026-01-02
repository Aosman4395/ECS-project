resource "aws_lb" "ecs_alb" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.alb_security_group_ids
  subnets            = var.public_subnet_ids

  tags = {
    Name = var.alb_name
  }
  
}

resource "aws_lb_target_group" "ecs_tg" {
    name     = "${var.alb_name}-tg"
    target_type = "ip"
    port     = 5230
    protocol = "HTTP"
    vpc_id   = var.vpc_id
    
    health_check {
        path                = "/"
        protocol            = "HTTP"
        matcher             = "200-399"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
    }
    
    tags = {
        Name = "${var.alb_name}-tg"
    }
  
}

resource "aws_lb_listener" "ecs_http" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}


data "aws_acm_certificate" "issued" {
  domain      = "tm.ahmedo.co.uk"
  statuses    = ["ISSUED"]
  most_recent = true
}

resource "aws_lb_listener" "ecs_https" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.issued.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_tg.arn
  }
}

