# Application Load Balancer Module
resource "aws_lb" "main" {
  name               = var.lb_name
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = var.security_groups
  subnets            = var.subnets

  enable_deletion_protection = var.enable_deletion_protection

  tags = merge(
    {
      Name = var.lb_name
    },
    var.tags
  )
}

resource "aws_lb_target_group" "main" {
  name     = "${var.lb_name}-tg"
  port     = var.target_port
  protocol = var.target_protocol
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = var.health_check_path
    port                = "traffic-port"
    protocol            = var.target_protocol
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = var.tags
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = var.listener_port
  protocol          = var.listener_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

output "lb_arn" {
  description = "The ARN of the load balancer"
  value       = aws_lb.main.arn
}

output "lb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "target_group_arn" {
  description = "The ARN of the target group"
  value       = aws_lb_target_group.main.arn
}