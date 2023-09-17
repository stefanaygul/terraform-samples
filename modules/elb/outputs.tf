output "load_balancer_dns_name" {
  value = aws_lb.application.dns_name
}

output "target_group_arn" {
  value = aws_lb_target_group.target_group.arn
}
