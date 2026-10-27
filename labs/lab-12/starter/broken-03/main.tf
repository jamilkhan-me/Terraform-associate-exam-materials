# Type errors (3)
variable "ports" {
  type    = list(number)
  default = [80, 443, "ssh"]
}

variable "names" {
  type    = list(string)
  default = ["a", "b"]
}

variable "enabled" {
  type    = bool
  default = true
}

resource "terraform_data" "svc" {
  for_each = var.names
  input    = each.key
}

resource "terraform_data" "toggle" {
  input = var.enabled ? "on" : ["off"]
}
