# Lab 05 — Solution

## Task 1 — outputs
| Output | Value |
|---|---|
| `admins` | `["alice"]` |
| `users_by_team` | `{ app = ["bob"], platform = ["alice", "carol"] }` |
| `upper_envs` | `["DEV", "TEST", "PROD"]` |
| `count_ids` | list of 3 ids (in index order) |
| `each_ids` | map `{ dev = "...", prod = "...", test = "..." }` |
| `bastion_id` | `null` |

## Task 3 — remove "test"
```
by_count[1]: ~ input "test" -> "prod"     (update)
by_count[2]: - destroy
by_each["test"]: - destroy
Plan: 0 to add, 1 to change, 2 to destroy.
```

## Task 4 — prepend "qa"
```
by_count[0]: ~ "dev"  -> "qa"
by_count[1]: ~ "test" -> "dev"
by_count[2]: ~ "prod" -> "test"
by_count[3]: + create ("prod")
by_each["qa"]: + create
Plan: 2 to add, 3 to change, 0 to destroy.
```
With real resources whose name attribute forces replacement, that's **three needless replacements**.

## Task 5
With `true`: `bastion_id` = an id. With `false` again: the bastion is destroyed and `bastion_id` is `null`. `one()` returns null for an empty list and the element for a 1-element list — safer than `[0]`.

## Task 6
- `terraform_data.by_each["prod"].output` → `"prod"`
- `terraform_data.by_count[2].output` → `"prod"`
- `keys(terraform_data.user)` → `["alice", "bob", "carol"]`
- `values(terraform_data.user)[*].input.team` → `["platform", "app", "platform"]`

## Task 7
`Error: Invalid for_each argument … The given "for_each" argument value is unsuitable: the "for_each" argument must be a map, or set of strings, and you have provided a value of type list of string.`

## Task 8 — migrate count → for_each without destroy
```hcl
resource "terraform_data" "by_count" {
  for_each = toset(var.envs)
  input    = each.key
}

moved {
  from = terraform_data.by_count[0]
  to   = terraform_data.by_count["dev"]
}
moved {
  from = terraform_data.by_count[1]
  to   = terraform_data.by_count["test"]
}
moved {
  from = terraform_data.by_count[2]
  to   = terraform_data.by_count["prod"]
}
```
Also update `local.count_ids` (splat on a map no longer makes sense): e.g. `[for r in terraform_data.by_count : r.id]`.
Plan: `# terraform_data.by_count[0] has moved to terraform_data.by_count["dev"]` ×3, **0 to add, 0 to change, 0 to destroy**.
CLI alternative: `terraform state mv 'terraform_data.by_count[0]' 'terraform_data.by_count["dev"]'` etc.
