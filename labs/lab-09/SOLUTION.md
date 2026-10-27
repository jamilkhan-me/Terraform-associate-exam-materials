# Lab 09 — Solution

1. **No changes** — Terraform only knows about objects in state. Manually created objects are invisible until imported.
2.
```hcl
import {
  to = aws_s3_bucket.incident
  id = "jk-incident-artifacts-2026"
}

import {
  to = aws_cloudwatch_log_group.orders
  id = "/aws/lambda/orders-api"
}
```
3. `terraform plan -generate-config-out=generated.tf`
4. Candidates: remove `tags_all` (computed from provider default_tags + tags), remove `null`
   arguments like `bucket_prefix`/`name_prefix` (they conflict with `bucket`/`name`), set
   `retention_in_days` deliberately (0 = never expire — you probably want e.g. 14), remove
   `force_destroy = null`. Generated config is a **draft**.
5.
```hcl
resource "aws_s3_bucket" "incident" {
  bucket = "jk-incident-artifacts-2026"
}

resource "aws_cloudwatch_log_group" "orders" {
  name              = "/aws/lambda/orders-api"
  retention_in_days = 14
}
```
6. Ideal: `2 to import, 0 to add, 0 to change, 0 to destroy`.
   - "1 to import, 1 to change" → your config differs from reality (e.g. you set retention 14 while reality is 0). Acceptable **if intended** — the change will be applied after import.
   - "1 to import, 1 to add, 1 to destroy" → a ForceNew attribute differs → Terraform would **replace** the imported object. Stop and fix config.
7. Yes, after a successful apply they can be removed. Leaving them is harmless (already-imported targets are no-ops), but removing them keeps configs tidy.
8.
```bash
terraform import aws_s3_bucket.incident jk-incident-artifacts-2026
terraform import aws_cloudwatch_log_group.orders /aws/lambda/orders-api
```
   The resource blocks must already exist. The CLI writes state immediately (no plan preview) and doesn't generate configuration.
9.
```hcl
variable "iam_users" { type = set(string) }

import {
  for_each = var.iam_users
  to       = aws_iam_user.imported[each.key]
  id       = each.key
}

resource "aws_iam_user" "imported" {
  for_each = var.iam_users
  name     = each.key
}
```
10. During **plan**: `Cannot import non-existent remote object` (the provider's read finds nothing). Nothing is written to state.
