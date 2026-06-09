module "network" {
  source = "../../modules/network"

  name_prefix              = local.name_prefix
  vpc_cidr                 = var.vpc_cidr
  public_subnet_cidrs      = var.public_subnet_cidrs
  private_app_subnet_cidrs = var.private_app_subnet_cidrs
  private_db_subnet_cidrs  = var.private_db_subnet_cidrs
}

module "security" {
  source = "../../modules/security"

  name_prefix         = local.name_prefix
  vpc_id              = module.network.vpc_id
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
}

module "s3" {
  source = "../../modules/s3"

  name_prefix = local.name_prefix
}

module "dynamodb" {
  source = "../../modules/dynamodb"

  name_prefix = local.name_prefix
}

module "sns" {
  source = "../../modules/sns"

  name_prefix = local.name_prefix
  alert_email = var.alert_email
}

module "iam" {
  source = "../../modules/iam"

  name_prefix         = local.name_prefix
  sns_topic_arn       = module.sns.topic_arn
  incident_bucket_arn = module.s3.incident_bucket_arn
  incidents_table_arn = module.dynamodb.incidents_table_arn
}

module "ec2" {
  source = "../../modules/ec2"

  name_prefix        = local.name_prefix
  subnet_id          = module.network.public_subnet_ids[0]
  security_group_ids = [module.security.ec2_sg_id]
  instance_profile   = module.iam.ec2_instance_profile_name
}

module "alb" {
  source = "../../modules/alb"

  name_prefix        = local.name_prefix
  vpc_id             = module.network.vpc_id
  subnet_ids         = module.network.public_subnet_ids
  security_group_id  = module.security.alb_sg_id
  target_instance_id = module.ec2.instance_id
}

module "rds" {
  source = "../../modules/rds"

  name_prefix       = local.name_prefix
  subnet_ids        = module.network.private_db_subnet_ids
  security_group_id = module.security.rds_sg_id
  db_username       = var.db_username
  db_password       = var.db_password
}

module "cloudwatch" {
  source = "../../modules/cloudwatch"

  name_prefix           = local.name_prefix
  ec2_instance_id       = module.ec2.instance_id
  alb_target_group_arn  = module.alb.target_group_arn
  alb_load_balancer_arn = module.alb.load_balancer_arn
  rds_instance_id       = module.rds.db_instance_id
  alb_arn_suffix        = module.alb.alb_arn_suffix
}

module "lambda_agent" {
  source = "../../modules/lambda_agent"

  name_prefix              = local.name_prefix
  lambda_role_arn          = module.iam.lambda_role_arn
  sns_topic_arn            = module.sns.topic_arn
  incident_bucket_name     = module.s3.incident_bucket_name
  incidents_table_name     = module.dynamodb.incidents_table_name
  cloudwatch_log_group_arn = module.cloudwatch.agent_log_group_arn
}

module "eventbridge" {
  source = "../../modules/eventbridge"

  name_prefix          = local.name_prefix
  lambda_function_arn  = module.lambda_agent.lambda_function_arn
  lambda_function_name = module.lambda_agent.lambda_function_name
}