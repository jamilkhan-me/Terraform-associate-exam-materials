terraform {
  required_version = ">= 1.5.0"

  # Phase 1: no backend block -> default local backend (terraform.tfstate here)
  # Phase 2: uncomment the block below (Task 4)
  # backend "local" {
  #   path = "state/app.tfstate"
  # }
}

resource "terraform_data" "app" {
  input = "app-v1"
}

resource "terraform_data" "db" {
  input = "db-v1"
}

output "app_id" {
  value = terraform_data.app.id
}
