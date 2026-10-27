# Syntax errors (3)
resource "terraform_data" "a" {
  input = "hello'
}

resource "terraform_data" "b" {
  input = {
    name = "b"
  }

resource "terraform_data" "c" {
  input = "c"
  lifecycle = {
    create_before_destroy = true
  }
}
