output "ecs_tasks_execution_role_arn" {
  value = aws_iam_role.ecs_tasks_execution_role.arn
}

output "task_role_arn" {
  value = aws_iam_role.task_role.arn
  
}

output "code_deploy_role_arn" {
  value = aws_iam_role.code_deploy_role.arn
}