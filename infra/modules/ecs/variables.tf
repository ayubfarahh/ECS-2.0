variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}

variable "log_group_name" {
  description = "The CloudWatch log group name"
  type        = string
}


variable "ecr_image_url" {
  description = "Full ECR image URL"
  type        = string
}

variable "ecs_execution_role_arn" {
  description = "The ECS execution role ARN"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "task_role_arn" {
  description = "The task role ARN"
  type        = string
}