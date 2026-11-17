# Lab 09 — Importing Existing Infrastructure

## 1. Objective
Bring manually created objects under Terraform management without recreating them, using
(a) config-driven `import` blocks with generated configuration and (b) the CLI `terraform import`
command — and understand what each does to config, state, and reality.

## 2. Prerequisites and safety
- **This lab is conceptual by default.** Importing requires a provider that supports import
  and real objects to import, which means a cloud account and provider download.
- The built-in `terraform_data` resource is not a meaningful import target, so there is no
  fully offline practical version.
- **Optional practical path (AWS):** requires the AWS provider (internet download), an AWS
  account, and creating one S3 bucket + one CloudWatch log group manually. Costs are
  typically negligible (empty bucket, empty log group), but **you must explicitly agree before
  any real-cloud step**, use a sandbox account, and never use your existing project accounts
  or state. See also [AWS lab A7](../aws-optional/README.md#a7--import-logging-and-cli-workspaces-days-5-6).

## 3. Directory structure
```
lab-09/starter/main.tf    # provider + TODOs (conceptual)
```

## 4. Starter files
See `starter/main.tf`.

## 5. Tasks (paper/conceptual — write your answers, then compare)
1. Before anything: what would `terraform plan` show right now? Why?
2. Write `import` blocks for both objects. (Import IDs: S3 bucket → bucket name; CloudWatch log group → log group name.)
3. Which command generates resource blocks for the import targets? Write it.
4. Study the **mock generated output** below. Identify two lines you'd remove or change and why.
5. Write the final cleaned resource blocks.
6. What should the plan summary say before you apply? What would it mean if it said "1 to import, 1 to change"? "1 to import, 1 to add, 1 to destroy"?
7. After apply, can the `import` blocks be removed? What happens if you leave them?
8. Write the equivalent **CLI** commands for both imports. What must exist before running them? What does the CLI not do that `-generate-config-out` does?
9. Scenario: you need to import 40 IAM users listed in a variable. Sketch an `import` block with `for_each` (1.7+).
10. Scenario: an import ID is wrong (typo). What error do you expect, and at which step?

### Mock generated output (`generated.tf`) — illustrative, not verbatim
```hcl
# __generated__ by Terraform
# Please review these resources and move them into your main configuration files.

# __generated__ by Terraform from "jk-incident-artifacts-2026"
resource "aws_s3_bucket" "incident" {
  bucket              = "jk-incident-artifacts-2026"
  bucket_prefix       = null
  force_destroy       = null
  object_lock_enabled = false
  tags                = {}
  tags_all            = {}
}

# __generated__ by Terraform from "/aws/lambda/orders-api"
resource "aws_cloudwatch_log_group" "orders" {
  kms_key_id        = null
  log_group_class   = "STANDARD"
  name              = "/aws/lambda/orders-api"
  name_prefix       = null
  retention_in_days = 0
  skip_destroy      = false
  tags              = {}
  tags_all          = {}
}
```

### Mock plan output after cleaning config
```
aws_s3_bucket.incident: Preparing import... [id=jk-incident-artifacts-2026]
aws_cloudwatch_log_group.orders: Preparing import... [id=/aws/lambda/orders-api]
aws_s3_bucket.incident: Refreshing state... [id=jk-incident-artifacts-2026]
aws_cloudwatch_log_group.orders: Refreshing state... [id=/aws/lambda/orders-api]

Terraform will perform the following actions:

  # aws_cloudwatch_log_group.orders will be imported
    resource "aws_cloudwatch_log_group" "orders" { ... }

  # aws_s3_bucket.incident will be imported
    resource "aws_s3_bucket" "incident" { ... }

Plan: 2 to import, 0 to add, 0 to change, 0 to destroy.
```

## 6. Expected observations
See SOLUTION.md.

## 7. Hints
<details><summary>Hint 1</summary>Import blocks go in the root module: <code>import { to = ADDRESS  id = "ID" }</code>.</details>
<details><summary>Hint 2</summary>Generated config often includes defaults/computed values (e.g. <code>tags_all</code>, null args) that you should tidy.</details>

## 8. Solution
[SOLUTION.md](SOLUTION.md)

## 9. Common errors
| Error | Meaning |
|---|---|
| `Cannot import non-existent remote object` | Wrong ID, region, or account |
| `Resource already managed by Terraform` | The address is already in state |
| `Configuration for import target does not exist` | Import block without resource block and without `-generate-config-out` |
| `Import block target … is not a resource in the root module`-type errors | `to` address invalid |

## 10. Exam concepts reinforced
Import (7a), generated config, relation of import to plan/apply, drift after import (6d).
