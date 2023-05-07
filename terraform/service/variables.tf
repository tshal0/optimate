# --- services/variables.tf ---

variable "target_group_arn" {
  type = string
}
variable "app_subnets" {
  type = list(any)
}
variable "web_subnets" {
  type = list(any)
}
variable "app_sg" {
  type = string
}
variable "shopify_api_key" {
  type = string
  default = "SHOPIFY_API_KEY"
  sensitive = true
}
variable "shopify_api_secret" {
  type = string
  default = "SHOPIFY_API_SECRET"
  sensitive = true
}
variable "port" {
  type = string
  default = "8080"
}
variable "shop" {
  type = string
  default = "prototypik-dev.myshopify.com"
}
variable "host" {
  type = string
  default = "https://www.splitfest.io"
}
variable "api_url" {
  type = string
  default = "https://www.splitfest.io/api"
}

