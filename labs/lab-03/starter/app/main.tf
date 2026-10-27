# "App team" configuration. Reads the network team's outputs; does NOT manage the network.
terraform {
  required_version = ">= 1.5.0"
}

data "terraform_remote_state" "network" {
  backend = "local"
  config = {
    path = "${path.module}/../network/terraform.tfstate"
  }
}

resource "terraform_data" "service" {
  input = {
    vpc_id  = data.terraform_remote_state.network.outputs.vpc_id
    subnets = data.terraform_remote_state.network.outputs.private_subnets
  }
}

output "service_subnet_count" {
  value = length(data.terraform_remote_state.network.outputs.private_subnets)
}
