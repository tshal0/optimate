# --- ecs/variables.tf ---

variable "app_name" {
  type = string
}
variable "app_services" {
  type = list(string)
}
variable "app_sg" {
  type = string
}
variable "private_subnets" {
  type = list(any)
}
variable "public_subnets" {
  type = list(any)
}
variable "shopify_api_key" {
  type      = string
  default   = "SHOPIFY_API_KEY"
  sensitive = true
}
variable "shopify_api_secret" {
  type      = string
  default   = "SHOPIFY_API_SECRET"
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
variable "ecr_repositories" {
  type = map(string)
}
variable "ui_port" {
  type = number
}
variable "api_port" {
  type = number
}
variable "target_group_ui" {
  type = string
}
variable "target_group_api" {
  type = string
}

variable "rds" {
  type = any
}
variable "db_host" {
  type    = string
  default = "DB_HOST"
}
variable "db_port" {
  type    = number
  default = 3306
}
variable "db_user" {
  type = string
}
variable "db_pass" {
  type = string
}
variable "db_name" {
  type = string
}
