# Lab 03 — Resources vs Data Sources

## 1. Objective
See the difference between a **managed resource** (lifecycle owned by this configuration)
and a **data source** (read-only lookup) using two configurations that share data through
the built-in `terraform_remote_state` data source — the same pattern as a network stack
feeding an application stack in your 3-tier project.

## 2. Prerequisites
Terraform ≥ 1.5. Labs 01–02.

## 3. Directory structure
```
lab-03/starter/
├── network/main.tf   # manages terraform_data.vpc, exports outputs
└── app/main.tf       # reads network outputs via data "terraform_remote_state"
```

## 4. Starter files
See `starter/`. Read both files and draw the dependency between them before running anything.

## 5. Tasks
1. **Predict:** what happens if you run `terraform plan` in `app/` before `network/` has been applied?
2. In `app/`: `terraform init && terraform plan`. Compare with your prediction.
3. In `network/`: `terraform init && terraform apply`.
4. In `app/`: `terraform plan`. Which block appears as an action in the plan, and which doesn't? Apply it.
5. In `app/`: `terraform state list`. Is the data source in state? What is its address?
6. In `app/`: `terraform state show data.terraform_remote_state.network`.
7. In `network/`: `terraform apply -var cidr=10.30.0.0/16`. Then in `app/` run `terraform plan`. What changed and why did the app config notice?
8. In `app/`: `terraform destroy`. Did anything in `network/` get destroyed? Check with `terraform state list` in `network/`.
9. **Think:** list two reasons why reading another stack's whole state is a security concern, and one alternative.
10. Clean up `network/` with `terraform destroy`.

## 6. Expected observations
- Step 2: the data source fails because the state file / outputs don't exist yet (error about the state file or missing output attributes).
- Step 4: only `terraform_data.service` shows `+ create`; the data source is read during plan and isn't an "action".
- Step 5: `data.terraform_remote_state.network` appears in `state list` — data sources are stored in state (mode `data`).
- Step 7: `service` shows `~ update in-place` because the subnets list changed.
- Step 8: network resources are untouched — destroying a config never destroys what it only *reads*.

## 7. Hints
<details><summary>Hint 1</summary>Data sources are read at plan time if their arguments are known.</details>
<details><summary>Hint 2</summary><code>terraform_remote_state</code> exposes only root-level <code>outputs</code> of the other state.</details>

## 8. Solution
[SOLUTION.md](SOLUTION.md)

## 9. Common errors
| Error | Fix |
|---|---|
| `Unable to find remote state` / no such file | Apply `network/` first; check the path |
| `Unsupported attribute` on `.outputs.x` | The output doesn't exist in the other state (or wasn't applied yet) |
| Forgot `.outputs` | Use `data.terraform_remote_state.network.outputs.vpc_id` |

## 10. Exam concepts reinforced
Resource vs data block (4a), cross-configuration references (4b), data sources in state (2d), `terraform_remote_state` reads outputs only (6c).
