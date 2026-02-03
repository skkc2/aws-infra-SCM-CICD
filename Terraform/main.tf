locals {
  common_tags = {
    Project = var.project_name
    Env     = "prod"
  }
}

# KMS (optional)
module "kms" {
  source     = "../../modules/kms"
  create_key = var.kms_create
  key_alias  = var.kms_key_alias
  tags       = local.common_tags
}

module "vpc" {
  source = "../../modules/vpc"
  name   = "${var.project_name}-vpc"
  region = var.aws_region
  tags   = local.common_tags
}

module "security" {
  source = "../../modules/security"
  vpc_id = module.vpc.vpc_id
  tags   = local.common_tags
}

module "alb" {
  source            = "../../modules/alb"
  name_prefix       = var.project_name
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_certs = {
    ghe     = var.acm_cert_arn_ghe
    jenkins = var.acm_cert_arn_jenkins
  }
  allowed_ipv4_cidrs = var.allowed_ipv4_cidrs
  allowed_ipv6_cidrs = var.allowed_ipv6_cidrs
  tags               = local.common_tags
}

# Base EC2 resources / launch templates
module "ec2" {
  source           = "../../modules/ec2"
  name_prefix      = var.project_name
  vpc_id           = module.vpc.vpc_id
  subnet_ids       = module.vpc.private_subnet_ids
  security_groups  = module.security.instance_security_group_ids
  instance_ami_map = { eu-west-1 = "ami-0abcdef1234567890" } # replace or make a variable
  tags             = local.common_tags
}

# GHE (single instance cluster / placeholder)
module "ghe" {
  source = "../../modules/ghe"
  name   = var.project_name
  vpc_id = module.vpc.vpc_id
  subnets = module.vpc.private_subnet_ids
  security_group_ids = [module.security.instance_security_group_id]
  license_s3_bucket = var.ghe_license_s3_bucket
  license_s3_key    = var.ghe_license_s3_key
  tags              = local.common_tags
}

# Jenkins master + EFS
module "jenkins" {
  source = "../../modules/jenkins"
  name   = var.project_name
  vpc_id = module.vpc.vpc_id
  subnets = module.vpc.private_subnet_ids
  public_subnet_ids = module.vpc.public_subnet_ids
  security_group_ids = [module.security.instance_security_group_id]
  alb_target_group_arn = module.alb.jenkins_tg_arn
  tags = local.common_tags
}

# Autoscaling (Jenkins agents)
module "autoscaling" {
  source = "../../modules/autoscaling"
  name_prefix = var.project_name
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
  security_group_ids = [module.security.instance_security_group_id]
  tags = local.common_tags
}

# WAF
module "waf" {
  source = "../../modules/waf"
  name   = var.project_name
  allowed_ipv4_cidrs = var.allowed_ipv4_cidrs
  allowed_ipv6_cidrs = var.allowed_ipv6_cidrs
  lb_arn = module.alb.alb_arn
  tags = local.common_tags
}

# Monitoring
module "monitoring" {
  source = "../../modules/monitoring"
  name   = var.project_name
  alarm_email = "ops@replace-me.example.com"
  sns_topic_name = "${var.project_name}-alerts"
  tags = local.common_tags
}

# Backups (DLM)
module "backups" {
  source = "../../modules/backups"
  name   = var.project_name
  tags = local.common_tags
}
