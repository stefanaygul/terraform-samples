resource "aws_lb" "application" {
  name               = var.name
  load_balancer_type = "application"
  subnets            = var.subnets

  security_groups = [aws_security_group.alb_sg.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.application.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

resource "aws_lb_target_group" "target_group" {
  name     = var.target_group_name
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_security_group" "alb_sg" {
  name        = var.security_group_name
  description = "ALB Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = var.allowed_cidr_blocks
  }
}

output "load_balancer_dns_name" {
  value = aws_lb.application.dns_name
}
