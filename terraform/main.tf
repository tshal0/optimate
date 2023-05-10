# --- main.tf --- #

locals {
  public_alb_target_groups = { for service, config in var.service_configs : service => config.alb_target_group if config.is_public }
}

module "vpc" {
  source             = "./vpc"
  app_name           = var.app_name
  vpc_cidr           = "10.0.0.0/16"
  public_cidrs       = ["10.0.1.0/24", "10.0.2.0/24"]
  private_cidrs      = ["10.0.11.0/24", "10.0.12.0/24"]
  availability_zones = ["us-east-2a", "us-east-2b"]
  az_count           = 2
  aws_region         = "us-east-2"
}

module "alb" {
  source          = "./alb"
  app_name        = var.app_name
  internal        = false
  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.public_subnets
  security_groups = [module.vpc.alb_sg]
  listeners       = var.public_alb_config.listeners
  certificate     = module.dns.certificate

  alb_tg_ui_port      = "8080"
  alb_tg_ui_protocol  = "HTTP"
  alb_tg_api_port     = "8081"
  alb_tg_api_protocol = "HTTP"
}
module "ecr" {
  source       = "./ecr"
  app_name     = var.app_name
  app_services = var.app_services
}

module "rds" {
  source          = "./rds"
  app_name        = var.app_name
  app_sg          = module.vpc.app_sg
  rds_sg          = module.vpc.rds_sg
  private_subnets = module.vpc.private_subnets
  public_subnets  = module.vpc.public_subnets
  db_user         = var.db_user
  db_pass         = var.db_pass
  db_name         = var.db_name
}

module "ecs" {
  source             = "./ecs"
  app_name           = var.app_name
  app_services       = var.app_services
  private_subnets    = module.vpc.private_subnets
  public_subnets     = module.vpc.public_subnets
  app_sg             = module.vpc.app_sg
  shopify_api_key    = var.shopify_api_key
  shopify_api_secret = var.shopify_api_secret
  shop               = var.shop
  host               = var.host
  api_url            = var.api_url
  ecr_repositories   = module.ecr.ecr_repositories
  ui_port            = 8080
  api_port           = 8081
  target_group_api   = module.alb.target_group_api
  target_group_ui    = module.alb.target_group_ui

  rds     = module.rds.db
  db_host = module.rds.rds_domain
  db_port = module.rds.rds_port
  db_user = var.db_user
  db_pass = var.db_pass
  db_name = var.db_name
}


module "dns" {
  source           = "./dns"
  domain_name      = "*.splitfest.io"
  environment_name = "Dev"
  zone_name        = "splitfest.io"
  record_name      = "splitfest.io"
  alias_name       = module.alb.alb.dns_name
  alias_zone_id    = module.alb.alb.zone_id
}


#Log the load balancer app URL
output "certificate" {
  value = module.dns.certificate
}
output "alb_dns_name" {
  value = module.alb.dns_name
}
output "rds_endpoint" {
  value = module.rds.rds_domain
}
