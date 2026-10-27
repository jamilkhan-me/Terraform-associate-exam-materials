terraform {
  required_version = ">= 1.7.0" # removed blocks need 1.7+
}

resource "terraform_data" "web" {
  input = "web-server"
}

resource "terraform_data" "worker" {
  count = 2
  input = "worker-${count.index}"
}

resource "terraform_data" "bucket" {
  for_each = toset(["logs", "assets"])
  input    = "bucket-${each.key}"
}

resource "terraform_data" "legacy" {
  input = "legacy-thing"
}

module "orders" {
  source = "./modules/queue"
  name   = "orders"
}
