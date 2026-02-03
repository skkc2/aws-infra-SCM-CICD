variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "backend_s3_bucket" {
  type    = string
  default = "aws-terraform-backend"
}

variable "backend_dynamodb_table" {
  type    = string
  default = "terraform-locks"
}

variable "project_name" {
  type    = string
  default = "aws-infra-scm-cicd"
}

variable "ghe_domain" { type = string }
variable "jenkins_domain" { type = string }
variable "hosted_zone_id" { type = string }

variable "allowed_ipv4_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}
variable "allowed_ipv6_cidrs" {
  type    = list(string)
  default = []
}

variable "acm_cert_arn_ghe" { type = string }
variable "acm_cert_arn_jenkins" { type = string }

variable "ghe_license_s3_bucket" { type = string }
variable "ghe_license_s3_key" { type = string }

variable "kms_create" {
  type    = bool
  default = true
}

variable "kms_key_alias" {
  type    = string
  default = ""
}
