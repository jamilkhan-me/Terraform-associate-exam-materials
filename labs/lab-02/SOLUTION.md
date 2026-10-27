# Lab 02 — Solution

## Precedence table
| # | Command | instance_count | env | Why |
|---|---|---|---|---|
| 1 | `plan` | **4** | dev | terraform.tfvars (2) < a.auto (3) < b.auto (4) — lexical order, b last |
| 2 | `TF_VAR_instance_count=9 plan` | **4** | dev | env vars are *below* tfvars files |
| 3 | `-var-file=prod.tfvars` | **6** | prod | CLI file beats auto files |
| 4 | `-var-file=prod.tfvars -var instance_count=7` | **7** | prod | last CLI flag wins |
| 5 | `-var instance_count=7 -var-file=prod.tfvars` | **6** | prod | last CLI flag wins (the file) |
| 6 | `-var env=qa` | — | — | `Invalid value for variable … env must be one of: dev, staging, prod.` Plan stops |

## Task 7
- `public_servers` = `["web"]` — only `web` sets `public = true`; `api` gets the optional default `false`.
- `total_disk` = `70` — web gets default `disk_gb = 20`, api has 50.

## Task 8
```
$ terraform output
common_tags = { "CostCentre" = "cc-42", "Env" = "dev", "Owner" = "jamil" }
db_password = <sensitive>
instance_count = 4
name_prefix = "dev-app"
public_servers = ["web"]
total_disk = 70
$ terraform output db_password
"change-me-in-real-life"
```
`-json` also includes the value (with `"sensitive": true`). Sensitivity is a display guard.

## Task 9
The password appears in `terraform.tfstate` in plaintext → state must be protected.

## Task 10
`Error: Output refers to sensitive values … To reduce the risk of accidentally exporting
sensitive data … set sensitive = true`.

## Task 11
With `-input=false`: `Error: No value for required variable "owner"`. Without it: Terraform
prompts interactively `var.owner  Enter a value:`.

## Task 12
| Expression | Result |
|---|---|
| `var.servers["web"].disk_gb` | `20` |
| `merge({a=1},{a=2})` | `{ "a" = 2 }` |
| `lookup(var.extra_tags, "Missing", "none")` | `"none"` (with a.auto.tfvars loaded, `extra_tags` has only CostCentre) |
| `type(var.servers)` | `map(object({disk_gb: number, public: bool, size: string}))` (formatting may vary by version) |

## Takeaways
- D-E-T-J-A-C precedence. Non-auto `.tfvars` require `-var-file`.
- Locals compute; outputs expose; neither can be set from outside.
- `optional(type, default)` fills missing object attributes.
- Sensitive ≠ secret storage.
