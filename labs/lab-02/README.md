# Lab 02 — Variables, Locals, Outputs, Validation, Precedence

## 1. Objective
Predict, then verify, which value a variable receives from competing sources; use locals,
complex types, `optional()`, validation, and sensitive outputs.

## 2. Prerequisites
Lab 01 complete. Terraform ≥ 1.5 (`optional()` defaults need ≥ 1.3).

## 3. Directory structure
```
lab-02/starter/
├── main.tf            # locals + two terraform_data resources
├── variables.tf       # 6 variables incl. validation, optional(), sensitive
├── outputs.tf
├── terraform.tfvars   # instance_count = 2, owner = "jamil"
├── a.auto.tfvars      # instance_count = 3, extra_tags
├── b.auto.tfvars      # instance_count = 4
└── prod.tfvars        # env = "prod", instance_count = 6  (NOT auto-loaded)
```

## 4. Starter files
All files are in `starter/` — read every one before starting.

## 5. Tasks — write your **prediction first**, then run
Use `terraform init` once, then `terraform plan` (no need to apply until task 8).

| # | Command | Predict `instance_count` | Predict `env` |
|---|---|---|---|
| 1 | `terraform plan` | | |
| 2 | `TF_VAR_instance_count=9 terraform plan` | | |
| 3 | `terraform plan -var-file=prod.tfvars` | | |
| 4 | `terraform plan -var-file=prod.tfvars -var instance_count=7` | | |
| 5 | `terraform plan -var instance_count=7 -var-file=prod.tfvars` | | |
| 6 | `terraform plan -var env=qa` | (what happens?) | |

7. Predict the values of `public_servers` and `total_disk`. Verify with `terraform console`
   (`local.public_servers`, `local.total_disk`). Type `exit` to leave.
8. `terraform apply -auto-approve`. Run `terraform output`. How is `db_password` displayed?
   Now run `terraform output db_password` and `terraform output -json`. What do you see?
9. `grep change-me terraform.tfstate`. What does this prove?
10. Remove `sensitive = true` from the `db_password` output and run `terraform plan`. Read the error. Restore it.
11. Rename `owner` to have no value anywhere (comment it out in `terraform.tfvars`) and run `terraform plan -input=false`. Then run without `-input=false`.
12. In `terraform console`, evaluate: `var.servers["web"].disk_gb`, `merge({a=1},{a=2})`, `lookup(var.extra_tags, "Missing", "none")`, `type(var.servers)`.

## 6. Expected observations
See SOLUTION.md for the full table. Key points: auto.tfvars beat terraform.tfvars; CLI flags
beat everything and are applied left to right; `prod.tfvars` is ignored unless named;
validation fails at plan; sensitive outputs show `<sensitive>` in the list but are visible
when requested by name or JSON, and are plaintext in state.

## 7. Hints
<details><summary>Hint 1</summary>Auto-loaded files: <code>terraform.tfvars</code>, <code>terraform.tfvars.json</code>, <code>*.auto.tfvars</code>, <code>*.auto.tfvars.json</code>. Auto files are processed in lexical filename order.</details>
<details><summary>Hint 2</summary>For multiple -var / -var-file flags, the one that appears <b>last</b> on the command line wins.</details>

## 8. Solution
[SOLUTION.md](SOLUTION.md)

## 9. Common errors
| Error | Cause |
|---|---|
| `No value for required variable "owner"` | Task 11 with `-input=false` |
| `Invalid value for variable` | Validation (task 6) |
| `Output refers to sensitive values` | Task 10 |
| `Unsupported attribute` in console | Typo in attribute name |

## 10. Exam concepts reinforced
Variable precedence (4c), complex types & `optional` (4d), expressions/functions (4e), validation (4g), sensitive data (4h).
