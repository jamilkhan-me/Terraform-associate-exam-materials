# "Network team" configuration. Owns the (simulated) VPC and publishes outputs.
terraform {
  required_version = ">= 1.5.0"
}

variable "cidr" {
  type    = string
  default = "10.20.0.0/16"
}

resource "terraform_data" "vpc" {
  input = {
    cidr = var.cidr
    name = "shared-vpc"
  }
}

output "vpc_id" {
  value = terraform_data.vpc.id
}

output "vpc_cidr" {
  value = var.cidr
}

output "private_subnets" {
  value = [for i in range(3) : cidrsubnet(var.cidr, 8, i)]
}
