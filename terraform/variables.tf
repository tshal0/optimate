variable "aws_access_key" {
  type      = string
  sensitive = true
}
variable "aws_secret_key" {
  type      = string
  sensitive = true
}

variable "region" {
  type    = string
  default = "us-east-2"
}
variable "env" {
  type    = string
  default = "dev"
}
variable "app_name" {
  type = string
}
variable "app_services" {
  type = list(string)
}

########################################################################################################################
# VPC
variable "cidr" {
  type = string
}
variable "availability_zones" {
  type = list(string)
}
variable "public_subnets" {
  type = list(string)
}
variable "private_subnets" {
  type = list(string)
}



variable "shopify_api_key" {
  type      = string
  sensitive = true
}
variable "shopify_api_secret" {
  type      = string
  sensitive = true
}
variable "shop" {
  type = string
}
variable "host" {
  type = string
}
variable "api_url" {
  type = string
}
########################################################################################################################
# ALB
variable "public_alb_config" {
  type = object({
    name = string
    listeners = map(object({
      listener_port     = number
      listener_protocol = string
    }))
    ingress_rules = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    }))
    egress_rules = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    }))
  })
  description = "Public ALB configuration"
}

########################################################################################################################
# ECS
variable "service_configs" {
  type = map(object({
    name           = string
    is_public      = bool
    container_port = number
    host_port      = number
    cpu            = number
    memory         = number
    desired_count  = number

    alb_target_group = object({
      port              = number
      protocol          = string
      path_pattern      = list(string)
      health_check_path = string
      priority          = number
    })
  }))
  description = "Service configuration"
}
########################################################################################################################

# RDS

variable "db_user" {
  type      = string
  sensitive = true
}
variable "db_pass" {
  type      = string
  sensitive = true
}
variable "db_name" {
  type      = string
  sensitive = true
}
