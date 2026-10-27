# Lab 10 — Solution

| Step | Result | Explanation |
|---|---|---|
| 3–4 | Error: backend initialization required | Any backend change must go through `init` |
| 5 | Prompt: "Do you want to copy existing state to the new backend?" | Terraform found state in the previous (default local) backend |
| 6 | `state/app.tfstate` holds the state; lineage unchanged; No changes | Migration copies the same state history. The old `terraform.tfstate` is left behind (not deleted) — remove only after verification |
| 7 | `Variables may not be used here` | Backend is configured before evaluation; use partial config |
| 8 | State moves to `state/dev.tfstate` | `-backend-config` fills in missing backend arguments at init |
| 9 | Plan: create both resources | `-reconfigure` ignored existing state; the new path is empty. In real infrastructure, this is how teams accidentally duplicate stacks |
| 10 | Back to `terraform.tfstate` | Removing the backend block = local default; `-migrate-state` copies back |

## Real-world mapping (S3)
```hcl
terraform {
  backend "s3" {}   # partial
}
```
```bash
terraform init -migrate-state \
  -backend-config="bucket=jk-tfstate" \
  -backend-config="key=app/prod.tfstate" \
  -backend-config="region=eu-west-2" \
  -backend-config="use_lockfile=true"
```
Then verify with `terraform plan` → No changes.

## Locking note
The local backend uses local file locking (protects against two processes on the same
machine). Team backends (S3 lockfile/DynamoDB, HCP Terraform, azurerm, gcs, consul) protect
across machines.
