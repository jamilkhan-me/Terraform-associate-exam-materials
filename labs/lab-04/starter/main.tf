terraform {
  required_version = ">= 1.5.0"
}

variable "app_version" {
  type    = string
  default = "1.0.0"

  validation {
    condition     = can(regex("^\\d+\\.\\d+\\.\\d+$", var.app_version))
    error_message = "app_version must look like 1.2.3."
  }
}

variable "owner_tag" {
  type    = string
  default = "platform-team"
}

# --- Implicit dependency chain --------------------------------------------
resource "terraform_data" "network" {
  input = "vpc-simulated"
}

resource "terraform_data" "database" {
  input = "db-in-${terraform_data.network.output}" # reference => implicit dependency
}

# --- Explicit dependency + provisioners -------------------------------------
resource "terraform_data" "migration" {
  # Nothing in the arguments references the database, but the migration must run after it.
  depends_on = [terraform_data.database]

  input = "schema-v1"

  provisioner "local-exec" {
    command = "echo \"$(date +%T) created migration ${self.id}\" >> provisioner.log"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "echo \"$(date +%T) destroyed migration ${self.id}\" >> provisioner.log"
  }
}

# --- Lifecycle: replace_triggered_by + create_before_destroy + conditions ---
resource "terraform_data" "app_version" {
  input = var.app_version
}

resource "terraform_data" "server" {
  input = "server-for-${var.app_version}"

  lifecycle {
    create_before_destroy = true
    replace_triggered_by  = [terraform_data.app_version]

    precondition {
      condition     = !startswith(var.app_version, "0.")
      error_message = "Pre-1.0 versions may not be deployed."
    }

    postcondition {
      condition     = self.output != null
      error_message = "Server output must be set after apply."
    }
  }
}

# --- Lifecycle: ignore_changes ------------------------------------------------
resource "terraform_data" "tagged" {
  input = {
    owner = var.owner_tag
  }

  lifecycle {
    ignore_changes = [input]
  }
}

# --- Lifecycle: prevent_destroy (edit in Task 7) ------------------------------
resource "terraform_data" "protected" {
  input = "precious-data"

  lifecycle {
    prevent_destroy = false
  }
}

# --- check block: warns, never blocks -----------------------------------------
check "version_is_not_prerelease" {
  assert {
    condition     = !endswith(var.app_version, ".0.0")
    error_message = "Heads-up: app_version is a new major (x.0.0) — example warning only."
  }
}
