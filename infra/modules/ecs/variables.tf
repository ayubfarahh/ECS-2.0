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