# Dependency errors (2)
resource "terraform_data" "sg_a" {
  input = "allows ${terraform_data.sg_b.id}"
}

resource "terraform_data" "sg_b" {
  input = "allows ${terraform_data.sg_a.id}"
}

resource "terraform_data" "app" {
  input      = "app"
  depends_on = [terraform_data.sg_a.id]
}
