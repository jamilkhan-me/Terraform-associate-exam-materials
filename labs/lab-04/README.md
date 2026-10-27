# Lab 04 — Dependencies, Lifecycle, Custom Conditions, Provisioners

## 1. Objective
Observe implicit vs explicit dependencies, every lifecycle setting, the three kinds of custom
condition (validation, pre/postcondition, check), and provisioner behaviour — including
tainting on failure.

## 2. Prerequisites
Terraform ≥ 1.5 (`check` blocks, `startswith`/`endswith`). A POSIX shell (for `date`, `echo`).
On Windows use WSL or Git Bash.

## 3. Directory structure
```
lab-04/starter/
└── main.tf
```

## 4. Starter files
Read `starter/main.tf` fully. Before running: draw the dependency graph on paper.

## 5. Tasks
1. `terraform init`, then `terraform graph`. Compare to your drawing. Which edge comes from `depends_on`?
2. `terraform apply`. Note the creation order in the output, the **check-block warning**, and the contents of `provisioner.log`.
3. `terraform apply` again — does the provisioner run again? Check `provisioner.log`.
4. **Predict**, then run `terraform plan -var app_version=1.1.0`: which resources change, and with which symbol for `server`?
5. Apply it. Was the check warning still shown? Why/why not?
6. `terraform plan -var app_version=0.9.0` and `-var app_version=banana`. Which mechanism stops each?
7. Change `owner_tag` default to `"security-team"` and plan. Explain the result.
8. Set `prevent_destroy = true` on `protected`, apply, then run `terraform plan -destroy`. Read the error. Set it back to `false`.
9. Change the first `local-exec` command in `migration` to `exit 1`, and run `terraform apply -replace=terraform_data.migration`. What happens? Run `terraform state list` and `terraform plan`. What is the resource's status? Restore the command and apply.
10. `terraform destroy`. Check `provisioner.log` for the destroy-time provisioner. In what order were resources destroyed?

## 6. Expected observations
Summarised in SOLUTION.md. Look especially for: `+/-` (create-before-destroy) on `server`; `replace_triggered_by` causing replacement even though `server`'s own config is barely related; `ignore_changes` producing "No changes"; `prevent_destroy` error; **tainted** resource after provisioner failure.

## 7. Hints
<details><summary>Hint 1</summary>Creation-time provisioners only run when a resource is <b>created</b> (including replacement).</details>
<details><summary>Hint 2</summary>Validation errors mention the variable; precondition errors mention the resource. Check blocks only ever warn.</details>
<details><summary>Hint 3</summary>A tainted resource is shown in the plan as "is tainted, so must be replaced".</details>

## 8. Solution
[SOLUTION.md](SOLUTION.md)

## 9. Common errors
| Error | Cause |
|---|---|
| `Variables may not be used here` in lifecycle | Lifecycle values must be literals |
| `Instance cannot be destroyed` | `prevent_destroy = true` |
| `local-exec provisioner error … exit status 1` | Task 9 (intended) |
| `Invalid reference in variable validation` | Older Terraform (< 1.9) with cross-variable validation (not used here) |

## 10. Exam concepts reinforced
Implicit/explicit dependencies (4f), lifecycle (create_before_destroy, prevent_destroy, ignore_changes, replace_triggered_by), custom conditions (4g), provisioners & tainting, `-replace` (3e).
