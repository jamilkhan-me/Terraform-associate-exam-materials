terraform {
  required_version = ">= 1.5.0"
}

locals {
  name_prefix = "${var.env}-app"
  common_tags = merge(
    {
      Env   = var.env
      Owner = var.owner
    },
    var.extra_tags
  )
  public_servers = [for name, s in var.servers : name if s.public]
  total_disk     = sum([for s in values(var.servers) : s.disk_gb])
}

resource "terraform_data" "config" {
  input = {
    prefix         = local.name_prefix
    instance_count = var.instance_count
    tags           = local.common_tags
  }
}

resource "terraform_data" "db" {
  input = var.db_password
}
