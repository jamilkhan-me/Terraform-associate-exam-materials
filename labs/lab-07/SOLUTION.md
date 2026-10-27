# Lab 07 — Solution

## Task 2
```
  # terraform_data.web will be updated in-place
  ~ resource "terraform_data" "web" {
        id               = "..."
      ~ input            = { ~ instance_type = "t3.micro" -> "t3.small" }
      ~ output           = { ... } -> (known after apply)
        # (1 unchanged attribute hidden)
    }
Plan: 0 to add, 1 to change, 0 to destroy.
```
`dns` and `lb` reference `web.id`, which is unchanged by an in-place update.

## Task 3
```
  # terraform_data.web must be replaced
+/- resource "terraform_data" "web" {
      ~ id               = "aaa" -> (known after apply)
      ~ triggers_replace = "ami-111" -> "ami-222" # forces replacement
    }
  # terraform_data.dns will be updated in-place
  ~ input = "web.example.internal -> aaa" -> (known after apply)
  # terraform_data.lb will be updated in-place
  ~ input = "lb -> aaa" -> (known after apply)
Plan: 1 to add, 2 to change, 1 to destroy.
```
Symbols: `dns`/`lb` are updates, so both show `~`. For `web`, the default would be `-/+`
(destroy, then create), **but** `lb` depends on `web` and has `create_before_destroy`, and
Terraform propagates create-before-destroy to the dependencies of such a resource — so
expect `+/-` ("create replacement and then destroy") for `web`. Experiment: remove the
`lifecycle` block from `lb`, re-plan, and watch `web` return to `-/+`.

## Task 4
`terraform show ami.tfplan` renders the saved plan. JSON shows `resource_changes[].change.actions` such as `["delete","create"]` or `["create","delete"]`.

## Task 5
`Error: Saved plan is stale — The given plan file can no longer be applied because the state was changed by another operation after the plan was created.`

## Task 6
Applies without prompting. (Passing `-var` with a plan file is an error.)

## Task 7
`terraform_data.dns` `-/+` "will be replaced, as requested". This is the modern replacement for `terraform taint`.

## Task 8
`0` (no changes), `2` (changes present). `1` would mean an error.

## Task 9
Terraform warns that resource targeting is in effect and the plan may be incomplete. `web`
is replaced but `dns` and `lb` still contain the old id → configuration and reality diverge
until a full apply. Use `-target` only for exceptional recovery.

## Takeaways
- The **schema** decides update vs replace; the plan tells you which attribute forced it.
- Replacement propagates as updates (or replacements, if ForceNew) to dependants.
- Saved plans: no prompt, rejected if stale, include variable values (and secrets).
