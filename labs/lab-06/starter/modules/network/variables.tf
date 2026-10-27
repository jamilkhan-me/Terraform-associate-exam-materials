variable "name" {
  description = "Network name"
  type        = string
}

variable "cidr_block" {
  description = "VPC CIDR"
  type        = string
}

variable "az_count" {
  description = "Number of AZs (one private subnet per AZ)"
  type        = number
  default     = 2

  validation {
    condition     = var.az_count >= 1 && var.az_count <= 4
    error_message = "az_count must be between 1 and 4."
  }
}

variable "tags" {
  type    = map(string)
  default = {}
}
