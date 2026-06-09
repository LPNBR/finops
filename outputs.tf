output "vpc_id" {
  value = module.network.vpc_id
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "ec2_instance_id" {
  value = module.ec2.instance_id
}

output "rds_endpoint" {
  value = module.rds.db_endpoint
}

output "sns_topic_arn" {
  value = module.sns.topic_arn
}

output "lambda_function_name" {
  value = module.lambda_agent.lambda_function_name
}