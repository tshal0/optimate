# --- alb/variables.tf ---

variable "app_name" {
  type = string
}

variable "internal" {
  type = bool
}

variable "vpc_id" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "security_groups" {
  type = list(string)
}

variable "listeners" {
  type = map(object({
    listener_port     = number
    listener_protocol = string
  }))
}

variable "alb_tg_ui_port" {
  type = string
}
variable "alb_tg_ui_protocol" {
  type = string
}
variable "alb_tg_api_port" {
  type = string
}
variable "alb_tg_api_protocol" {
  type = string
}
variable "certificate" {
  type = string
}
