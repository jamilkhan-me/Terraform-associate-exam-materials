# Lab 06 — Building and Calling Local Modules

## 1. Objective
Build two local child modules, call them from a root module (including with `for_each`),
pass inputs, consume outputs, and observe module boundaries, scope rules, and refactoring
into a module with `moved`.

## 2. Prerequisites
Terraform ≥ 1.5. Labs 01–05.

## 3. Directory structure
```
lab-06/starter/
├── main.tf                      # root module
└── modules/
    ├── network/
    │   ├── main.tf              # vpc + count subnets
    │   ├── variables.tf
    │   └── outputs.tf
    └── bucket/
        └── main.tf              # variables, resource, output in one file (allowed)
```

## 4. Starter files
See `starter/`. Trace the data flow: root var → module input → child resource → child output → root output.

## 5. Tasks
1. Run `terraform plan` **before** `init`. Read the error. Run `terraform init` — what does it say about modules? Inspect `.terraform/modules/modules.json`.
2. `terraform apply`. Then `terraform state list` — write down the full address of the second subnet and of the `assets` bucket.
3. Only **root** outputs are printed. Add a root output that exposes the `logs` bucket name only.
4. In the root, try to reference `module.network.terraform_data.vpc.id` in an output. Plan. Read the error. Remove it.
5. In `modules/bucket/main.tf`, try to use `var.env` … it works — why? Now try to use `local.common_tags` there. Read the error. Revert.
6. Pass `az_count = 5`. What stops it, and where is the rule defined?
7. Remove the `cidr_block` argument from `module "network"`. What error appears? Revert.
8. **Predict** the plan for `terraform apply -var env=staging`. Which resources update? Which addresses change? Apply.
9. **Refactor challenge:** add a root-level resource
   ```hcl
   resource "terraform_data" "flow_logs" { input = "flow-logs" }
   ```
   apply it, then move it *into* the network module (as `terraform_data.flow_logs` inside `modules/network/main.tf`) **without destroy/create**. Prove with plan.
10. Add `count = 0` to the `module "network"` block… wait — what else breaks? Reason about it before trying (outputs and the bucket module reference `module.network.vpc_id`). Write how you would fix references with `count`. (Thinking task; don't leave it broken.)
11. `terraform destroy`.

## 6. Expected observations
- Step 1: `Module not installed` → after init: `Initializing modules... - network in modules/network`.
- Step 2: `module.network.terraform_data.subnet[1]`, `module.buckets["assets"].terraform_data.bucket`.
- Step 4: `Unsupported attribute` — module internals are private.
- Step 5: `var.env` works because the bucket module declares its own `variable "env"` (passed from root). `local.common_tags` → `Reference to undeclared local value`.
- Step 6: validation inside the child module's variable.
- Step 8: in-place updates of inputs; addresses unchanged (keys `logs`/`assets` don't depend on env).

## 7. Hints
<details><summary>Hint 1</summary>Root can only see <code>module.NAME.OUTPUT</code>.</details>
<details><summary>Hint 2 (task 9)</summary><code>moved { from = terraform_data.flow_logs  to = module.network.terraform_data.flow_logs }</code> goes in the root module.</details>

## 8. Solution
[SOLUTION.md](SOLUTION.md)

## 9. Common errors
| Error | Cause |
|---|---|
| `Module not installed` | init not run after adding module |
| `Unsupported argument` | passing an input the child doesn't declare |
| `Missing required argument` | child variable without default not passed |
| `Unsupported attribute` | referencing a child output that doesn't exist / child internals |

## 10. Exam concepts reinforced
Module sources (5a), variable scope (5b), using modules & outputs (5c), module meta-args, `moved` into modules (6d).
