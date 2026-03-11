module "vpc" {
  source    = "./modules/vpc"
  ecs_sg_id = module.ecs.ecs_sg_id
}

module "ecs" {
  source                 = "./modules/ecs"
  vpc_id                 = module.vpc.vpc_id
  log_group_name         = module.cloudwatch.log_group_name
  ecr_image_url          = var.ecr_image_url
  ecs_execution_role_arn = module.iam.ecs_tasks_execution_role_arn
  private_subnet_ids     = module.vpc.private_subnet_ids
  task_role_arn          = module.iam.task_role_arn
  dynamodb_table_name    = module.dynamodb.dynamodb_table_name
  target_group_arn       = module.alb.target_group_arn
}

module "iam" {
  source              = "./modules/iam"
  dynamodb_table_name = module.dynamodb.dynamodb_table_name
}

module "cloudwatch" {
  source = "./modules/cloudwatch"
}

module "dynamodb" {
  source = "./modules/dynamodb"
}

module "alb" {
  source            = "./modules/alb"
  public_subnet_ids = module.vpc.public_subnet_ids
  vpc_id            = module.vpc.vpc_id
  certificate_arn   = module.acm.certificate_arn
}

module "route53" {
  source       = "./modules/route53"
  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id  = module.alb.alb_zone_id
}

module "acm" {
  source = "./modules/acm"
}

module "waf" {
  source  = "./modules/waf"
  alb_arn = module.alb.alb_arn
}

module "codedeploy" {
  source = "./modules/codedeploy"
  code_deploy_role_arn = module.iam.code_deploy_role_arn
  ecs_cluster_name = module.ecs.ecs_cluster_name
  ecs_service_name = module.ecs.ecs_service_name
  target_group_name = module.alb.target_group_name
  https_listener_arn = module.alb.https_listener_arn
  test_listener_arn = module.alb.test_listener_arn
  green_target_group_name = module.alb.green_target_group_name
}