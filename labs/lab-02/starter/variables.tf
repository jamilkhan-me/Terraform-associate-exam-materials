variable "env" {
  description = "Deployment environment"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.env)
    error_message = "env must be one of: dev, staging, prod."
  }
}

variable "instance_count" {
  type    = number
  default = 1
}

variable "owner" {
  type = string
  # no default: required
}

variable "extra_tags" {
  type    = map(string)
  default = {}
}

variable "servers" {
  type = map(object({
    size    = string
    disk_gb = optional(number, 20)
    public  = optional(bool, false)
  }))
  default = {
    web = { size = "small", public = true }
    api = { size = "medium", disk_gb = 50 }
  }
}

variable "db_password" {
  type      = string
  sensitive = true
  default   = "change-me-in-real-life"
}
