terraform {
  required_version = ">= 1.5.0"
}

resource "terraform_data" "vpc" {
  input = {
    name = var.name
    cidr = var.cidr_block
    tags = var.tags
  }
}

resource "terraform_data" "subnet" {
  count = var.az_count
  input = {
    vpc    = terraform_data.vpc.id
    cidr   = cidrsubnet(var.cidr_block, 8, count.index)
    az_idx = count.index
  }
}
