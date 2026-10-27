# Lab 11 — CLI Workspaces and Environment Separation

## 1. Objective
Use CLI workspaces to keep multiple states for one configuration, observe the on-disk layout,
use `terraform.workspace` in expressions, and evaluate the limits of workspaces for
environment separation.

## 2. Prerequisites
Terraform ≥ 1.5 (`workspace select -or-create` needs 1.4+). Day 6 lesson.

## 3. Directory structure
```
lab-11/starter/main.tf
```

## 4. Starter files
See `starter/main.tf`.

## 5. Tasks
1. `terraform init`, `terraform workspace show`, `terraform workspace list`.
2. `terraform apply`. Outputs? Where is the state file?
3. `terraform workspace new dev` → apply. Outputs? `ls -R terraform.tfstate.d`.
4. `terraform workspace new prod` → **predict** how many servers and what size → apply.
5. `terraform workspace new qa` → predict size (no `qa` key in the map) → plan only.
6. `terraform workspace select dev` → `terraform state list`. Do you see prod's resources?
7. Try `terraform workspace delete dev` while `dev` is selected. Then select `default` and delete `dev` (it has resources) — read the error. What does `-force` do, and why is it dangerous?
8. Try `terraform workspace delete default`.
9. `TF_WORKSPACE=prod terraform output`. What does the env var do?
10. **Think:** your team wants dev and prod in **different AWS accounts** with different people allowed to apply. List three reasons workspaces are a weak fit, and sketch the directory-based layout you'd use instead.
11. Clean up: destroy in every workspace (`select` each, `destroy`), then delete non-default workspaces.

## 6. Expected observations
- default state: `terraform.tfstate`; others: `terraform.tfstate.d/<ws>/terraform.tfstate`.
- prod: 3 servers `m5.large`; dev: 1 `t3.micro`; default: 1 `t3.nano`; qa: 1 `t3.small` (lookup default).
- Each workspace sees only its own state.
- Deleting the current workspace is refused; deleting a non-empty workspace is refused without `-force`; `default` can never be deleted.

## 7. Hints
<details><summary>Hint 1</summary><code>lookup(map, key, default)</code> returns the default for missing keys.</details>

## 8. Solution
[SOLUTION.md](SOLUTION.md)

## 9. Common errors
| Error | Cause |
|---|---|
| `Workspace "dev" is your active workspace` | Can't delete the selected workspace |
| `Workspace is not empty` | Has resources; destroy first or `-force` |
| `can't delete default state` | default is permanent |

## 10. Exam concepts reinforced
CLI workspaces, `terraform.workspace`, state isolation per workspace (6a), workspaces vs separate configs (5/8 comparisons), CLI vs HCP Terraform workspaces (8c).
