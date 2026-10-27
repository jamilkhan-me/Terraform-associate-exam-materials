# Lab 05 — count, for_each, and Collection Expressions

## 1. Objective
Experience the index-shift problem with `count`, the stability of `for_each`, the
`count = cond ? 1 : 0` toggle, and `for`/splat/grouping expressions.

## 2. Prerequisites
Terraform ≥ 1.5. Labs 01–02.

## 3. Directory structure
```
lab-05/starter/main.tf
```

## 4. Starter files
`starter/main.tf` — read it fully. Note: `terraform fmt` will expand the one-line output blocks; that's fine.

## 5. Tasks
1. **Predict** every output value. Then `terraform init && terraform apply` and compare.
2. `terraform state list`. Write down the address format for count vs for_each instances.
3. **Predict** the plan after removing `"test"` from `envs` (edit the default). Then `terraform plan`. Count changes for `by_count` vs `by_each`.
4. Revert. Now add `"qa"` at the **start** of the list: `["qa","dev","test","prod"]`. Predict and plan.
5. Revert. Run `terraform apply -var create_bastion=true`. Then `terraform output bastion_id`. Then apply with `false` again — what happens to `bastion_id`?
6. In `terraform console`: `terraform_data.by_each["prod"].output`, `terraform_data.by_count[2].output`, `keys(terraform_data.user)`, `values(terraform_data.user)[*].input.team`.
7. Change `by_each` to `for_each = var.envs` (no `toset`). Run `terraform validate`/`plan` and read the error. Revert.
8. **Challenge:** migrate `by_count` to `for_each` keyed by env name **without** any destroy/create. Write the necessary blocks and prove it with `terraform plan` showing only moves.

## 6. Expected observations
- `count` instances: `terraform_data.by_count[0]`; `for_each`: `terraform_data.by_each["dev"]`.
- Removing `test`: `by_count` → 1 update + 1 destroy; `by_each` → 1 destroy.
- Prepending `qa`: `by_count` → 3 updates + 1 create (every index shifts); `by_each` → 1 create.
- `bastion_id` is `null` when the bastion doesn't exist (thanks to `one()`).

## 7. Hints
<details><summary>Hint 1</summary>The <code>...</code> after a value in a <code>for</code> map expression groups values with duplicate keys into lists.</details>
<details><summary>Hint 2 (task 8)</summary>You need one <code>moved</code> block per instance: from <code>terraform_data.by_count[0]</code> to the new for_each resource with key <code>"dev"</code>, etc.</details>

## 8. Solution
[SOLUTION.md](SOLUTION.md)

## 9. Common errors
| Error | Cause |
|---|---|
| `The given "for_each" argument value is unsuitable` | list passed to for_each |
| `"count" and "for_each" are mutually-exclusive` | both set |
| `Invalid index` | referencing `bastion[0]` when count is 0 |

## 10. Exam concepts reinforced
count vs for_each (4e), resource addressing (7b), `for` expressions, splat, `one()`, `moved` (6d).
