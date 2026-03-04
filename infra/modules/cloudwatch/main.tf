resource "aws_cloudwatch_log_group" "log_group" {
  name = "/ecs/url-shortener"
  retention_in_days = 30
  
}