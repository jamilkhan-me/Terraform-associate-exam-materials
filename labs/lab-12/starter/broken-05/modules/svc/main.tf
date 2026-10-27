variable "name" {
  type = string
}

variable "port" {
  type = number
}

resource "terraform_data" "svc" {
  input = "${var.name}:${var.port}"
}

output "endpoint" {
  value = terraform_data.svc.output
}
