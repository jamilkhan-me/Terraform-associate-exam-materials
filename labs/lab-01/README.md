# Lab 01 — First Configuration and the Core Workflow

## 1. Objective
Run the complete workflow (`init → fmt → validate → plan → apply → output/show → destroy`)
and observe what each command reads and writes.

## 2. Prerequisites
- Terraform ≥ 1.5 on your PATH (`terraform version`)
- No cloud credentials needed

## 3. Directory structure
```
lab-01/
├── README.md
├── SOLUTION.md
└── starter/
    └── main.tf      # intentionally badly formatted
```

## 4. Starter files
`starter/main.tf` — deliberately messy formatting:
```hcl
terraform {
required_version = ">= 1.5.0"
}

variable "project" {
  type = string
    default = "bootcamp"
}

locals {
greeting="Hello from ${var.project}"
}

resource "terraform_data" "hello" {
input = local.greeting
}

output "message" {
value = terraform_data.hello.output
}
```

## 5. Tasks
1. `cd starter` and run `terraform version`. Record the version in PROGRESS.md.
2. Run `terraform fmt -check`. Note the exit code (`echo $?`). Then `terraform fmt -diff`. Then `terraform fmt -check` again.
3. Run `terraform validate` **before** `init`. What happens?
4. Run `terraform init`. List the directory (`ls -la`). Which files/dirs appeared? Is there a `.terraform.lock.hcl`? Why/why not?
5. Run `terraform validate`.
6. Run `terraform plan`. Identify: action symbol, the summary line, which values are `(known after apply)`.
7. Run `terraform apply` and approve. Then run `terraform apply` again. What does the second run report?
8. Run `terraform output`, `terraform output -raw message`, and `terraform show`.
9. Open `terraform.tfstate` **read-only** (`cat`). Find `serial`, `lineage`, the resource's `mode`, `type`, `name`, `attributes.input`.
10. Run `terraform apply -var="project=exam"`. Is the change an update or a replacement? Check `serial` again.
11. Run `terraform plan -destroy`, then `terraform destroy`. Look at `terraform.tfstate` and `terraform.tfstate.backup`.

## 6. Expected observations
- `fmt -check` exits non-zero before formatting and 0 after.
- `validate` before `init` may fail asking you to run `terraform init` (the exact behaviour depends on whether any providers/modules need installing; with only the built-in provider it may succeed — note which you saw).
- After `init`: `.terraform/` may be created; a lock file is typically **not** created because the only provider is built-in.
- Plan: `+ create`, `Plan: 1 to add, 0 to change, 0 to destroy.`
- Second apply: `No changes. Your infrastructure matches the configuration.`
- Step 10: `~ update in-place` for `input` (and `output` becomes known after apply); serial increments.
- After destroy: state has an empty `resources` list; backup holds the previous version.

## 7. Hints
<details><summary>Hint 1</summary>Use <code>echo $?</code> directly after a command to see its exit code.</details>
<details><summary>Hint 2</summary>The lock file only records providers that are downloaded from a registry. Which provider does <code>terraform_data</code> come from?</details>

## 8. Solution
See [SOLUTION.md](SOLUTION.md).

## 9. Common errors
| Error | Fix |
|---|---|
| `terraform: command not found` | Install Terraform / fix PATH |
| `Unsupported Terraform Core version` | Your CLI is older than 1.5 |
| `Invalid resource type "terraform_data"` | CLI older than 1.4 |

## 10. Exam concepts reinforced
Core workflow (3a–3g), idempotency (1a), state contents (2d), update-in-place vs replace (4a), `terraform output`/`show` (7b).
