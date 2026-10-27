# Mixed errors (4)
variable "state_file" {
  default = "state/app.tfstate"
}

variable "protect" {
  type    = bool
  default = true
}

variable "secret" {
  type      = string
  sensitive = true
  default   = "s3cr3t"
}

terraform {
  backend "local" {
    path = var.state_file
  }
}

resource "terraform_data" "db" {
  count    = 2
  for_each = toset(["a", "b"])
  input    = "db"

  lifecycle {
    prevent_destroy = var.protect
  }
}

output "secret_echo" {
  value = var.secret
}
