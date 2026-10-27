terraform {
  required_version = ">= 1.5.0"
}

variable "ami" {
  description = "Simulates an attribute that forces replacement"
  type        = string
  default     = "ami-111"
}

variable "instance_type" {
  description = "Simulates an attribute that updates in place"
  type        = string
  default     = "t3.micro"
}

# terraform_data semantics:
#   input            -> change = UPDATE IN PLACE
#   triggers_replace -> change = REPLACE
resource "terraform_data" "web" {
  triggers_replace = var.ami
  input = {
    instance_type = var.instance_type
  }
}

resource "terraform_data" "dns" {
  input = "web.example.internal -> ${terraform_data.web.id}"
}

resource "terraform_data" "lb" {
  input = "lb -> ${terraform_data.web.id}"

  lifecycle {
    create_before_destroy = true
  }
}

output "web_id" {
  value = terraform_data.web.id
}
