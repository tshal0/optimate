variable "aws_access_key" {
  type = string
  default = "AWS_ACCESS_KEY"
  sensitive = true
}
variable "aws_secret_key" {
  type = string
  default = "AWS_SECRET_KEY"
  sensitive = true
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
variable "region" {
  type = string
  default = "us-east-2"
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

