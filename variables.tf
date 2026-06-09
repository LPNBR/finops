variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "ai-monitoring"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "poc"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public subnets"
  type        = list(string)
  default     = ["10.20.1.0/24", "10.20.2.0/24"]
}

variable "private_app_subnet_cidrs" {
  description = "Private app subnets"
  type        = list(string)
  default     = ["10.20.11.0/24", "10.20.12.0/24"]
}

variable "private_db_subnet_cidrs" {
  description = "Private db subnets"
  type        = list(string)
  default     = ["10.20.21.0/24", "10.20.22.0/24"]
}

variable "alert_email" {
  description = "Email for SNS alerts"
  type        = string
}

variable "db_username" {
  description = "RDS username"
  type        = string
  default     = "appadmin"
}

variable "db_password" {
  description = "RDS password"
  type        = string
  sensitive   = true
}
variable "incident_bucket_name" {
  description = "Nome do bucket S3 para histórico de incidentes"
  type        = string
}
variable "incidents_table_name" {
  description = "Nome da tabela DynamoDB de incidentes"
  type        = string
}
