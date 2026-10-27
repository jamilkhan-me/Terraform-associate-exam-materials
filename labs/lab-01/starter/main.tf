terraform {
required_version = ">= 1.5.0"
}

variable "project" {
  type = string
    default = "bootcamp"
}

locals {
greeting="Hello from ${var.project}"
}

resource "terraform_data" "hello" {
input = local.greeting
}

output "message" {
value = terraform_data.hello.output
}
