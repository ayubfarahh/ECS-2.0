module "vpc" {
  source = "./modules/vpc"
}

module "ecs" {
  source         = "./modules/ecs"
  vpc_id         = module.vpc.vpc_id
  log_group_name = module.cloudwatch.log_group_name
}