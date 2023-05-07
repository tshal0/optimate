module "networking" {
  source             = "./networking"
  vpc_cidr           = "10.0.0.0/16"
  public_cidrs       = ["10.0.1.0/24", "10.0.2.0/24"]
  private_cidrs      = ["10.0.11.0/24", "10.0.12.0/24"]
  availability_zones = ["us-east-2a", "us-east-2b"]
  az_count           = 2
  aws_region         = "us-east-2"
  certificate_arn    = module.dns.certificate_arn
}

module "service" {
  source                = "./service"
  target_group_arn      = module.networking.target_group.arn
  app_subnets           = module.networking.app_subnets
  web_subnets           = module.networking.web_subnets
  app_sg                = module.networking.app_sg
  shopify_api_key       = var.shopify_api_key
  shopify_api_secret    = var.shopify_api_secret
  port                  = var.port
  shop                  = var.shop
  host                  = var.host
  api_url               = var.api_url
}

module "dns" {
  source           = "./dns"
  domain_name      = "*.splitfest.io"
  environment_name = "Dev"
  zone_name        = "splitfest.io"
  record_name      = "splitfest.io"
  alias_name       = module.networking.external-alb.dns_name
  alias_zone_id    = module.networking.external-alb.zone_id
}


#Log the load balancer app URL
output "certificate_arn" {
  value = module.dns.certificate_arn
}
output "splitfest-alb" {
  value = module.networking.lb_dns_name
}
output "ecr_repo_url" {
  value = module.service.app_ecr_repo.repository_url
}
