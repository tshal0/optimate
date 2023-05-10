variable "app_name" {
  type = string
}
variable "app_sg" {
  type = string
}
variable "rds_sg" {
  type = string
}

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

variable "private_subnets" {
  type = list(any)
}
variable "public_subnets" {
  type = list(any)
}
