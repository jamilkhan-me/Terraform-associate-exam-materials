terraform {
  required_version = ">= 1.5.0"
}

locals {
  sizes = {
    default = "t3.nano"
    dev     = "t3.micro"
    prod    = "m5.large"
  }
  size = lookup(local.sizes, terraform.workspace, "t3.small")
}

resource "terraform_data" "server" {
  count = terraform.workspace == "prod" ? 3 : 1
  input = {
    name = "web-${terraform.workspace}-${count.index}"
    size = local.size
  }
}

output "workspace" {
  value = terraform.workspace
}

output "servers" {
  value = [for s in terraform_data.server : s.input.name]
}
