output "name_prefix" {
  value = local.name_prefix
}

output "instance_count" {
  value = var.instance_count
}

output "common_tags" {
  value = local.common_tags
}

output "public_servers" {
  value = local.public_servers
}

output "total_disk" {
  value = local.total_disk
}

output "db_password" {
  value     = terraform_data.db.output
  sensitive = true
}
