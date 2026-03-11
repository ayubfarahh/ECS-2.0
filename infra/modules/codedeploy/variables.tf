variable "code_deploy_role_arn" {
    type = string  
}

variable "ecs_cluster_name" {
  type = string
}

variable "ecs_service_name" {
  type = string
}

variable "target_group_name" {
  type = string
}

variable "green_target_group_name" {
  type = string
}

variable "https_listener_arn" {
  type = string
}

variable "test_listener_arn" {
  type = string
}