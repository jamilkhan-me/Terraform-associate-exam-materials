# Lab 08 — Solution

## Part 1
- `state list` shows 7 addresses: `module.orders.terraform_data.queue`, `terraform_data.bucket["assets"]`, `terraform_data.bucket["logs"]`, `terraform_data.legacy`, `terraform_data.web`, `terraform_data.worker[0]`, `terraform_data.worker[1]`.
- `terraform show` prints the whole state (or a plan file); `terraform state show ADDR` prints one resource instance.

## Part 2
```bash
terraform state mv terraform_data.web terraform_data.frontend
# Move "terraform_data.web" to "terraform_data.frontend"
# Successfully moved 1 object(s).
```
Plan → No changes. A timestamped backup of the previous state is written for local state.

## Part 3
```hcl
resource "terraform_data" "job" {
  count = 2
  input = "worker-${count.index}"
}
moved {
  from = terraform_data.worker
  to   = terraform_data.job
}
```
Plan shows `terraform_data.worker[0] has moved to terraform_data.job[0]` (and `[1]`); 0/0/0.
After apply, removing the `moved` block is fine for **this** configuration because state already
uses the new address. (In shared modules, keep `moved` blocks longer so consumers on older
versions can upgrade safely.)

## Part 4
- Step 9: `+ terraform_data.legacy will be created`. State no longer maps the block to the existing object.
- Step 10: push is refused because the snapshot is older (lower serial) than the current state. `-force` would overwrite the newer state and **undo** the renames you made in Parts 2–3, so the next plan would be wrong. Real-world recovery after an accidental `state rm` is **import**, not push.

## Part 5
Plan: `# module.orders.terraform_data.queue will no longer be managed by Terraform` …
`Plan: 0 to add, 0 to change, 0 to destroy.` After apply, it is gone from `state list`.

## Part 6 table
| Operation | Changes real infra? | Changes state? | Visible in plan first? |
|---|---|---|---|
| `state mv` | No | Yes, immediately | No |
| `moved` block | No | Yes, at apply | **Yes** |
| `state rm` | No | Yes, immediately | No |
| `removed` (destroy=false) | No | Yes, at apply | **Yes** |
| `state push` | No | Yes, overwrites | No |

## Takeaways
- Back up (`state pull`) before manual state operations.
- Prefer `moved`/`removed`/`import` blocks — reviewed in a plan, applied atomically, repeatable in CI.
- None of these commands touch real infrastructure.
