# terraform {
#   backend "s3" {
#     bucket         = "tfstate-ai-monitoring-poc"
#     key            = "poc/terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#     dynamodb_table = "tf-lock-ai-monitoring-poc"
#   }
# }