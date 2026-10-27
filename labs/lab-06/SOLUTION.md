# Lab 06 — Solution

## Task 2 — addresses
- `module.network.terraform_data.vpc`
- `module.network.terraform_data.subnet[0]`, `module.network.terraform_data.subnet[1]`
- `module.buckets["assets"].terraform_data.bucket`, `module.buckets["logs"].terraform_data.bucket`

## Task 3
```hcl
output "logs_bucket" {
  value = module.buckets["logs"].name
}
```

## Task 4
`Error: Unsupported attribute … This object does not have an attribute named "terraform_data".`
Module calls expose **outputs only**.

## Task 5
Variables are per-module; the bucket module has its own `var.env` because it declares
`variable "env"` and the root passes `env = var.env`. Locals are private to the module that
defines them → `Reference to undeclared local value`.

## Task 6
`Error: Invalid value for variable … az_count must be between 1 and 4.` — the validation lives in `modules/network/variables.tf`. Modules can validate their own inputs.

## Task 7
`Error: Missing required argument … The argument "cidr_block" is required, but no definition was found.`

## Task 8
- `module.network.terraform_data.vpc`: update (`name` and `tags.Env` change)
- `module.buckets[*].terraform_data.bucket`: update (name `staging-…`)
- subnets: unchanged (their inputs don't depend on env… except `vpc` id, which stays the same because `vpc` is updated in place, not replaced)
- No address changes.

## Task 9
`modules/network/main.tf`:
```hcl
resource "terraform_data" "flow_logs" {
  input = "flow-logs"
}
```
Root (remove the root-level resource block) and add:
```hcl
moved {
  from = terraform_data.flow_logs
  to   = module.network.terraform_data.flow_logs
}
```
Plan: `# terraform_data.flow_logs has moved to module.network.terraform_data.flow_logs` — `0 to add, 0 to change, 0 to destroy`.

## Task 10
With `count = 0` (or `count = 1`), the module becomes a list: references must become
`module.network[0].vpc_id`, and with 0 instances that index doesn't exist. Use
`one(module.network[*].vpc_id)` (null when absent) and make dependants tolerate null.

## Takeaways
- Module = directory; inputs via variables; outputs are the only public interface.
- `init` installs modules (local modules are referenced in place, recorded in `modules.json`).
- Module instances with `for_each`: `module.NAME["key"]`.
- Refactoring into modules is safe with `moved`.
