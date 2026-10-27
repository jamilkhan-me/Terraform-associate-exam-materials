terraform {
  required_version = ">= 1.5.0"
}

variable "envs" {
  type    = list(string)
  default = ["dev", "test", "prod"]
}

variable "users" {
  type = map(object({
    team  = string
    admin = optional(bool, false)
  }))
  default = {
    alice = { team = "platform", admin = true }
    bob   = { team = "app" }
    carol = { team = "platform" }
  }
}

variable "create_bastion" {
  type    = bool
  default = false
}

# Part A — count (index-based)
resource "terraform_data" "by_count" {
  count = length(var.envs)
  input = var.envs[count.index]
}

# Part B — for_each over a set (key-based)
resource "terraform_data" "by_each" {
  for_each = toset(var.envs)
  input    = each.key
}

# Part C — for_each over a map of objects
resource "terraform_data" "user" {
  for_each = var.users
  input = {
    name  = each.key
    team  = each.value.team
    admin = each.value.admin
  }
}

# Part D — optional resource with count
resource "terraform_data" "bastion" {
  count = var.create_bastion ? 1 : 0
  input = "bastion"
}

locals {
  admins         = [for name, u in var.users : name if u.admin]
  users_by_team  = { for name, u in var.users : u.team => name... }
  upper_envs     = [for e in var.envs : upper(e)]
  count_ids      = terraform_data.by_count[*].id
  each_ids       = { for k, r in terraform_data.by_each : k => r.id }
  bastion_id     = one(terraform_data.bastion[*].id)
}

output "admins"        { value = local.admins }
output "users_by_team" { value = local.users_by_team }
output "upper_envs"    { value = local.upper_envs }
output "count_ids"     { value = local.count_ids }
output "each_ids"      { value = local.each_ids }
output "bastion_id"    { value = local.bastion_id }
