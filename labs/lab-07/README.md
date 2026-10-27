# Lab 07 — Reading Plans, Update vs Replace, Saved Plans, `-replace`

## 1. Objective
Read plans like an examiner: symbols, `# forces replacement`, `(known after apply)`, the
summary arithmetic, propagation of replacements through references, saved/stale plans,
`-replace`, `-detailed-exitcode`, and why `-target` is exceptional.

## 2. Prerequisites
Terraform ≥ 1.5. Lab 04.

## 3. Directory structure
```
lab-07/starter/main.tf
```

## 4. Starter files
`terraform_data` is used as a stand-in for a provider resource: `input` behaves like an
in-place attribute (e.g. `instance_type`) and `triggers_replace` behaves like a ForceNew
attribute (e.g. `ami`).

## 5. Tasks
1. `terraform init && terraform apply -auto-approve` (fine in a lab — avoid in real work).
2. **Predict** the plan for `-var instance_type=t3.small`. Run `terraform plan -var instance_type=t3.small`. Symbol? Does `dns` change?
3. **Predict** the plan for `-var ami=ami-222`. Run it. Note:
   - the symbol for `web`, and the annotation on `triggers_replace`
   - what happens to `dns` and `lb` (they reference `web.id`)
   - the different symbols for `dns` vs `lb` — why?
   - the summary line arithmetic
4. Save that plan: `terraform plan -var ami=ami-222 -out=ami.tfplan`. Inspect with `terraform show ami.tfplan` and `terraform show -json ami.tfplan | head -c 600`.
5. Before applying it, run `terraform apply -auto-approve -var instance_type=t3.large` (someone else changed infra). Now `terraform apply ami.tfplan`. What happens?
6. Re-create the saved plan and apply it properly. Did it prompt?
7. With no config changes, run `terraform apply -replace=terraform_data.dns`. What changes?
8. `terraform plan -detailed-exitcode; echo $?` with no changes, then with `-var ami=ami-333`. Record the exit codes.
9. `terraform plan -var ami=ami-444 -target=terraform_data.web`. Read the warning. Why is this dangerous as a habit?
10. `terraform destroy -auto-approve`.

## 6. Expected observations
- Task 2: `~ update in-place`, only `web`. `dns` unchanged because `web.id` is stable on update.
- Task 3: `web` must be replaced (`# forces replacement` on `triggers_replace`). Because `lb` (which depends on `web`) has `create_before_destroy`, Terraform propagates create-before-destroy to `web`, so expect `+/-` rather than `-/+` — compare with what your version prints. `dns` and `lb` are `~` updates in place (their input becomes the new, unknown id). Summary: `1 to add, 2 to change, 1 to destroy`.
- Task 5: `Saved plan is stale` error.
- Task 6: no prompt.
- Task 7: `dns` `-/+` replaced; nothing else.
- Task 8: `0` then `2`.
- Task 9: Warning about resource targeting being in effect / not for routine use; `dns`/`lb` left out of sync.

## 7. Hints
<details><summary>Hint 1</summary>A replacement in the summary counts as one add and one destroy.</details>
<details><summary>Hint 2</summary>Changing an argument of a dependent resource updates it in place unless that argument forces replacement.</details>

## 8. Solution
[SOLUTION.md](SOLUTION.md)

## 9. Common errors
| Error | Cause |
|---|---|
| `Saved plan is stale` | state changed after plan |
| `Can't set variables when applying a saved plan` | passing `-var` with a plan file (values are baked into the plan) |

## 10. Exam concepts reinforced
Plan review (3d), apply with saved plan (3e), `-replace`, `-detailed-exitcode`, `-target`, update vs replacement (provider schema), `create_before_destroy` (4f).
