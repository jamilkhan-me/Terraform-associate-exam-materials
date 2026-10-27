variable "name" {
  type = string
}

resource "terraform_data" "queue" {
  input = var.name
}

output "id" {
  value = terraform_data.queue.id
}
