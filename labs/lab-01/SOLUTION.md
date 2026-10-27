# Lab 01 — Solution and Explanation

## Formatted `main.tf` (after `terraform fmt`)
```hcl
terraform {
  required_version = ">= 1.5.0"
}

variable "project" {
  type    = string
  default = "bootcamp"
}

locals {
  greeting = "Hello from ${var.project}"
}

resource "terraform_data" "hello" {
  input = local.greeting
}

output "message" {
  value = terraform_data.hello.output
}
```
`fmt` fixed indentation and aligned `=` signs. Nothing semantic changed.

## Step-by-step explanation
| Step | What happened and why |
|---|---|
| 2 | `fmt -check` returns non-zero when files need formatting — this is how CI enforces style. `-diff` shows the changes; plain `fmt` writes them. |
| 3 | `validate` needs provider schemas. With only the built-in provider, Terraform may validate successfully without init; with any registry provider it would demand `terraform init`. The exam-safe rule: **run init before validate**. |
| 4 | `init` configures the default local backend and checks providers. No registry providers → no lock file entries (a lock file may be absent). |
| 6 | `+` create. `id` and `output` are computed attributes → `(known after apply)`. `input` is known because it's from config. |
| 7 | Second apply → "No changes": idempotency. |
| 8 | `terraform output` reads outputs from **state**. `-raw` prints without quotes (strings only). `show` prints the whole state human-readably. |
| 9 | `serial` counts writes; `lineage` identifies this state's history; `mode: managed`. Never edit this file by hand. |
| 10 | `-var` overrides the default (CLI wins). `input` change → **update in place** for `terraform_data` (only `triggers_replace` forces replacement). Serial increments. |
| 11 | `plan -destroy` previews; `destroy` = `apply -destroy`. Local backend writes `terraform.tfstate.backup` with the previous snapshot. |

## Key takeaways
- `fmt` = style, `validate` = static correctness, `plan` = diff, `apply` = change + state write.
- Outputs come from state.
- Whether a change is in-place or replacement is defined by the resource type's schema.
