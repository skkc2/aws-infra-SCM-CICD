terraform {
  required_version = ">= 1.4.0"

  backend "s3" {
    bucket         = var.backend_s3_bucket
    key            = "prod/terraform.tfstate"
    region         = var.aws_region
    dynamodb_table = var.backend_dynamodb_table
    encrypt        = true
  }
}
