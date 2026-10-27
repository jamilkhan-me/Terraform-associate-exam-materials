terraform {
  required_version = ">= 1.5.0"
}

variable "env" {
  type    = string
  default = "dev"
}

locals {
  common_tags = {
    Env       = var.env
    ManagedBy = "terraform"
  }
}

module "network" {
  source     = "./modules/network"
  name       = "${var.env}-vpc"
  cidr_block = "10.40.0.0/16"
  az_count   = 2
  tags       = local.common_tags
}

module "buckets" {
  source   = "./modules/bucket"
  for_each = toset(["logs", "assets"])

  name   = each.key
  env    = var.env
  vpc_id = module.network.vpc_id
}

output "vpc_id" {
  value = module.network.vpc_id
}

output "subnet_cidrs" {
  value = module.network.subnet_cidrs
}

output "bucket_names" {
  value = [for b in module.buckets : b.name]
}
