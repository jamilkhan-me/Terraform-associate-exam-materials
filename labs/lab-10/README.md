# Lab 10 — Backends, Partial Configuration, and State Migration

## 1. Objective
Migrate state between backend locations **offline** using the `local` backend with different
paths — the exact same `init -migrate-state` / `-reconfigure` mechanics you'd use moving from
local to S3 or HCP Terraform. Experience the "no variables in backend" rule and partial
configuration.

## 2. Prerequisites
Terraform ≥ 1.5. Day 5 lesson.

## 3. Directory structure
```
lab-10/starter/
├── main.tf            # backend block commented out initially
└── dev.backend.hcl    # partial backend config file
```

## 4. Starter files
See `starter/`.

## 5. Tasks
1. `terraform init && terraform apply`. Confirm `terraform.tfstate` exists. Note the `app_id`.
2. `terraform state pull | head -20` — note `serial` and `lineage`.
3. **Predict** what will happen if you uncomment the backend block and run `terraform plan` without `init`.
4. Uncomment the `backend "local"` block. Run `terraform plan`. Read the error.
5. Run `terraform init`. Read the prompt carefully. Which flags does it suggest? Run `terraform init -migrate-state` and answer **yes** to copying.
6. Verify: `ls state/`, `terraform state list`, `terraform plan` (expect No changes), compare `lineage` with step 2. Is the old `terraform.tfstate` still there? Is it still used?
7. Now try to parameterise the path: change it to `path = var.state_path` (declare the variable). Run `terraform init`. Read the error. Revert.
8. **Partial configuration:** change the block to `backend "local" {}` (empty) and run `terraform init -migrate-state -backend-config=dev.backend.hcl`. Verify state moved to `state/dev.tfstate`.
9. **The dangerous flag:** change `dev.backend.hcl` to `path = "state/empty.tfstate"` and run `terraform init -reconfigure -backend-config=dev.backend.hcl`. Then `terraform plan`. What does Terraform want to do, and why? **Do not apply.** Point it back at `state/dev.tfstate` with `-reconfigure` and confirm "No changes".
10. Migrate back to the default local backend (remove the backend block entirely) with `terraform init -migrate-state`. Verify.
11. `terraform destroy`; clean up `state/`.

## 6. Expected observations
- Step 4: `Backend initialization required, please run "terraform init"` (or "Backend configuration changed").
- Step 5: Terraform detects existing state and asks to copy it to the new backend.
- Step 6: same lineage (same state history), plan No changes. The old file remains but is no longer used — delete only after verifying.
- Step 7: `Variables may not be used here.`
- Step 9: Terraform proposes to **create everything** — the new location is empty, and `-reconfigure` didn't copy anything. Applying would duplicate real resources (in real clouds) or create name conflicts.

## 7. Hints
<details><summary>Hint 1</summary><code>-migrate-state</code> copies; <code>-reconfigure</code> just points at the new location.</details>
<details><summary>Hint 2</summary>Backend blocks are evaluated before variables exist, so they must be literals — or supplied with <code>-backend-config</code>.</details>

## 8. Solution
[SOLUTION.md](SOLUTION.md)

## 9. Common errors
| Error | Cause |
|---|---|
| `Backend initialization required` | backend block changed without `init` |
| `Variables may not be used here` | variable in backend block |
| `Error: Invalid backend configuration argument` | wrong key in `-backend-config` |

## 10. Exam concepts reinforced
Local backend (6a), backend block & partial configuration (6c), migration (`init -migrate-state`, `-reconfigure`), lineage, locking concepts (6b).
