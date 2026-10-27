# Reference errors (4)
variable "env" {
  default = "dev"
}

locals {
  prefix = "${var.environment}-app"
}

data "terraform_remote_state" "net" {
  backend = "local"
  config = {
    path = "../net/terraform.tfstate"
  }
}

resource "terraform_data" "app" {
  input = {
    name   = locals.prefix
    vpc_id = terraform_remote_state.net.outputs.vpc_id
  }
}

output "app_out" {
  value = terraform_data.app.result
}
