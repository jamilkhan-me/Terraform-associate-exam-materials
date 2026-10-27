# Lab 12 — Solution

## broken-01 (syntax)
| # | Error | Fix |
|---|---|---|
| 1 | `"hello'` — mismatched quotes → `Invalid multi-line string` / unterminated string | `"hello"` |
| 2 | `resource "b"` missing closing `}` → `Unclosed configuration block` | add `}` |
| 3 | `lifecycle = { … }` → `Unsupported argument; An argument named "lifecycle" is not expected here. Did you mean to define a block of type "lifecycle"?` | `lifecycle { … }` (block, no `=`) |

## broken-02 (references)
| # | Error | Fix |
|---|---|---|
| 1 | `var.environment` → `Reference to undeclared input variable` | `var.env` |
| 2 | `locals.prefix` → `Reference to undeclared resource` (Terraform reads `locals` as a resource type) | `local.prefix` |
| 3 | `terraform_remote_state.net…` without `data.` → `Reference to undeclared resource` | `data.terraform_remote_state.net.outputs.vpc_id` |
| 4 | `terraform_data.app.result` → `Unsupported attribute` | `.output` (or `.id`) |
Plus at plan time: the remote state file `../net/terraform.tfstate` must exist.

## broken-03 (types)
| # | Error | Fix |
|---|---|---|
| 1 | `"ssh"` can't convert to number → `Invalid default value for variable` | use `22` |
| 2 | `for_each = var.names` (list) → `Invalid for_each argument` | `toset(var.names)` |
| 3 | `var.enabled ? "on" : ["off"]` → `Inconsistent conditional result types` (string vs list cannot be unified). Note: `"on" : 0` would be **accepted** — Terraform converts both to a common type (string) | `"on" : "off"` |

## broken-04 (dependencies)
| # | Error | Fix |
|---|---|---|
| 1 | `sg_a` ↔ `sg_b` → `Error: Cycle: terraform_data.sg_b, terraform_data.sg_a` | Break the loop (in AWS: separate `aws_security_group_rule`/`aws_vpc_security_group_ingress_rule` resources referencing both groups) |
| 2 | `depends_on = [terraform_data.sg_a.id]` → `Invalid depends_on reference … References in depends_on must be to a whole object` | `[terraform_data.sg_a]` |

## broken-05 (modules)
| # | Error | Phase | Fix |
|---|---|---|---|
| 1 | `source = "modules/svc"` → treated as registry address → init fails | init | `"./modules/svc"` |
| 2 | `version` with a local source → `Invalid argument "version"`-style error (version only for registry modules) | init | remove `version` |
| 3 | `module "api"` missing `port` → `Missing required argument` | validate | add `port = 8080` |
| 4 | `module "web"` passes `protocol` → `Unsupported argument` | validate | remove, or add `variable "protocol"` to the child |
| 5 (bonus) | `module.api.url` → `Unsupported attribute` | validate | `module.api.endpoint` |
(The header says 4; the output error is a bonus fifth.)

## broken-06 (mixed)
| # | Error | Phase | Fix |
|---|---|---|---|
| 1 | `path = var.state_file` in backend → `Variables may not be used here` | init | literal path or `-backend-config` |
| 2 | `count` and `for_each` both set → `Invalid combination of "count" and "for_each"` | validate | choose one |
| 3 | `prevent_destroy = var.protect` → `Variables may not be used here` (lifecycle needs literals) | validate | `prevent_destroy = true` |
| 4 | `output "secret_echo"` exposes sensitive var → `Output refers to sensitive values` | plan | add `sensitive = true` (or don't output it) |

## Scoring
- ≥ 18 of 21 errors spotted by eye → excellent exam readiness for HCL interpretation.
- 12–17 → revisit Day 2 sections C1, C6 and Day 8 C2.
- < 12 → redo this lab tomorrow without looking at the solution.
