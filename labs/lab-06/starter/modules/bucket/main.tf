terraform {
  required_version = ">= 1.5.0"
}

variable "name" {
  type = string
}

variable "env" {
  type = string
}

variable "vpc_id" {
  type    = string
  default = null
}

locals {
  full_name = "${var.env}-${var.name}"
}

resource "terraform_data" "bucket" {
  input = {
    name   = local.full_name
    vpc_id = var.vpc_id
  }
}

output "name" {
  value = local.full_name
}
