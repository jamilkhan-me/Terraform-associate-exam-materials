# Lab 08 — State Inspection and Safe State Operations

## 1. Objective
Inspect state, then perform every common state operation **safely** — with a backup first and
a `plan` afterwards — and compare CLI commands (`state mv/rm/push`) with their declarative
equivalents (`moved`, `removed`).

> ⚠ Practise only here. In real projects: back up state, prefer `moved`/`removed`/`import`
> blocks (reviewed in a plan), and never `state push -force` without a very good reason.

## 2. Prerequisites
Terraform **≥ 1.7** (for `removed`). Days 5 lesson read.

## 3. Directory structure
```
lab-08/starter/
├── main.tf
└── modules/queue/main.tf
```

## 4. Starter files
See `starter/`.

## 5. Tasks
### Part 1 — inspect
1. `terraform init && terraform apply`.
2. `terraform state list`. Then `terraform state list module.orders` and `terraform state list 'terraform_data.bucket'`.
3. `terraform state show 'terraform_data.bucket["logs"]'` (note the quoting) and `terraform state show module.orders.terraform_data.queue`.
4. `terraform show` vs `terraform state show` — describe the difference in one sentence.
5. `terraform state pull > pre-change.tfstate`. Open it: find `serial` and `lineage`.

### Part 2 — rename with the CLI
6. Rename the block `terraform_data.web` → `terraform_data.frontend` in `main.tf`. **Predict** the plan. Run `terraform plan`.
7. Fix it with the CLI: `terraform state mv terraform_data.web terraform_data.frontend`. Plan again. Check `ls` for a backup file.

### Part 3 — rename with `moved`
8. Rename `terraform_data.worker` → `terraform_data.job` in config and add the right `moved` block (one block can move the whole resource including all its instances). Plan, apply. Then delete the `moved` block and plan again.

### Part 4 — forget (CLI) and the danger that follows
9. `terraform state rm terraform_data.legacy`. Plan. **What does Terraform want to do and why?**
10. Recover from the backup: try `terraform state push pre-change.tfstate`. Read the error. (Hint: serial and the renames you made.) Discuss: why would `-force` be dangerous here? **Don't** force it — instead, remove the `legacy` block from config and plan to confirm "No changes" for it. The "real" legacy object is now unmanaged.

### Part 5 — forget (declarative)
11. Replace `module "orders"` with:
    ```hcl
    removed {
      from = module.orders
      lifecycle {
        destroy = false
      }
    }
    ```
    Plan. What does the plan say? Apply. `terraform state list`.

### Part 6 — reflect
12. Fill in this table from your observations:

| Operation | Changes real infra? | Changes state? | Visible in plan before it happens? |
|---|---|---|---|
| `state mv` | | | |
| `moved` block | | | |
| `state rm` | | | |
| `removed` block | | | |
| `state push` | | | |

13. `terraform destroy` and clean up.

## 6. Expected observations
- Step 6: plan shows destroy `web` + create `frontend` (1 add, 1 destroy).
- Step 7: "Successfully moved 1 object(s)"; plan "No changes"; a `terraform.tfstate.*.backup` file exists.
- Step 8: plan shows "has moved to" for both instances; after removing the moved block: still "No changes".
- Step 9: plan proposes to **create** `terraform_data.legacy` — state forgot it, config still declares it.
- Step 10: push is refused (lineage OK but serial is lower / state differs) — protection against overwriting newer state.
- Step 11: plan says the module's resource "will no longer be managed by Terraform" and will **not** be destroyed.

## 7. Hints
<details><summary>Hint 1</summary><code>moved { from = terraform_data.worker  to = terraform_data.job }</code> moves all instances.</details>
<details><summary>Hint 2</summary>Quote addresses containing <code>["..."]</code> with single quotes in bash/zsh.</details>

## 8. Solution
[SOLUTION.md](SOLUTION.md)

## 9. Common errors
| Error | Cause |
|---|---|
| `Invalid target address` / `no matches` | Missing quotes around `["key"]` |
| `Cannot move to … already exists` | Destination address in use |
| `Unsupported block type "removed"` | Terraform < 1.7 |
| `cannot overwrite existing state with serial …` | state push of an older snapshot |

## 10. Exam concepts reinforced
Inspect state with the CLI (7b), `state mv/rm/pull/push` (6d), `moved`/`removed` (6d), backups, serial/lineage (2d).
