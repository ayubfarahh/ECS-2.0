output "target_group_name" {
  value = aws_lb_target_group.alb_target_group.name
}

output "green_target_group_name" {
  value = aws_lb_target_group.green_target_group.name
}

output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}

output "alb_zone_id" {
  value = aws_lb.alb.zone_id
}

output "alb_arn" {
  value = aws_lb.alb.arn
}

output "https_listener_arn" {
  value = aws_lb_listener.https.arn
}

output "test_listener_arn" {
  value = aws_lb_listener.test.arn
}

output "target_group_arn" {
  value = aws_lb_target_group.alb_target_group.arn
}