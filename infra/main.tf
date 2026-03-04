module "vpc" {
  source = "./modules/vpc"
}

module "ecs" {
  source                 = "./modules/ecs"
  vpc_id                 = module.vpc.vpc_id
  log_group_name         = module.cloudwatch.log_group_name
  ecr_image_url          = var.ecr_image_url
  ecs_execution_role_arn = module.iam.ecs_tasks_execution_role_arn
  private_subnet_ids     = module.vpc.private_subnet_ids
  task_role_arn         = module.iam.task_role_arn
}

module "iam" {
  source = "./modules/iam"
}

module "cloudwatch" {
  source = "./modules/cloudwatch"
}