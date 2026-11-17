# Mock Exam 3 — Final Assessment (Day 10)

**Questions:** 57 · **Time:** 60 minutes · **Exam conditions.** All questions are new — none are reused from the diagnostic, Mock 1, or Mock 2.
Answers in `answer-keys.md` → *Mock Exam 03*. **Format:** approximation, not official.
Answer format: `1. A (3)`.

---

### Q1 — select ONE
Staging and production were configured by hand and have quietly diverged. Which IaC benefit most directly addresses this?
- A. Consistent, repeatable environments created from the same definitions
- B. Lower cloud bills
- C. Faster application code compilation
- D. Removing the need for monitoring

### Q2 — select ONE
What do you primarily write in a Terraform configuration?
- A. The ordered sequence of API calls to make
- B. Shell scripts that Terraform runs on each host
- C. The desired end state of the infrastructure
- D. A log of previous changes

### Q3 — select TWO
Using providers, which can Terraform manage?
- A. DNS records at a SaaS DNS provider that has an API
- B. Repositories and team permissions in GitHub
- C. Only virtual machines in public clouds
- D. Physical servers that have no API of any kind

### Q4 — select ONE
Comparing Terraform with a cloud-native IaC service such as AWS CloudFormation, which statement is TRUE?
- A. Terraform does not need provider plugins for AWS.
- B. Terraform can only manage AWS resources.
- C. Terraform requires a CloudFormation stack to store its state.
- D. Terraform tracks resources in its own state, stored in a backend you choose.

### Q5 — select ONE
A provider constraint is `version = ">= 2.0, < 2.5"`. Which version may be selected?
- A. `1.9.9`
- B. `2.5.0`
- C. `2.4.9`
- D. `3.0.0`

### Q6 — select ONE
What does `required_version = "~> 1.9.0"` inside the `terraform` block constrain?
- A. Every provider must be version 1.9.x.
- B. Module versions.
- C. The state file format version.
- D. The Terraform CLI must be 1.9.x (at least 1.9.0, below 1.10.0).

### Q7 — select ONE
Which command shows the providers required by the configuration and its modules, including which module requires which provider?
- A. `terraform version -providers`
- B. `terraform providers`
- C. `terraform state list -providers`
- D. `terraform init -list`

### Q8 — select ONE
`data "aws_ami" "app"` uses `most_recent = true`. A new matching AMI is published, and an `aws_instance` uses `data.aws_ami.app.id` for its `ami` argument. What does the next `terraform plan` show?
- A. The data source reads the new AMI ID, and the instance shows a change (replacement, since `ami` forces it).
- B. No change, because data sources are only read once when they are first created.
- C. An error, because the AMI changed.
- D. The old AMI is deleted.

### Q9 — select ONE
Which is **not** stored in Terraform state?
- A. Attribute values of managed resources
- B. Root module output values
- C. Cloud credentials supplied to the provider through environment variables
- D. Dependency information between resources

### Q10 — select ONE
What is the purpose of the `TF_PLUGIN_CACHE_DIR` environment variable?
- A. It stores state for each provider.
- B. It sets where crash logs are written.
- C. It lets multiple working directories share one cache of downloaded provider plugins.
- D. It disables provider downloads entirely.

### Q11 — select ONE
Developers use macOS (arm64). CI runs on Linux (amd64) and fails because the lock file lacks checksums for its platform. What is the best fix?
- A. Delete `.terraform.lock.hcl` in CI before every run.
- B. Use `terraform init -lockfile=ignore`.
- C. Add `.terraform.lock.hcl` to `.gitignore`.
- D. Run `terraform providers lock -platform=darwin_arm64 -platform=linux_amd64` and commit the updated lock file.

### Q12 — select ONE
Which order is correct for a CI pipeline that applies exactly what was reviewed?
- A. `plan -out=tfplan` → `init` → `validate` → `apply tfplan`
- B. `init` → `validate` → `plan -out=tfplan` → `apply tfplan`
- C. `validate` → `apply` → `init` → `plan`
- D. `init` → `apply -auto-approve` → `plan`

### Q13 — select ONE
What is the effect of `terraform plan -refresh=false`?
- A. Terraform refreshes state and writes it to the backend.
- B. Terraform skips checking real infrastructure and plans from state alone, so it may miss drift.
- C. Terraform ignores the configuration and only refreshes.
- D. Terraform disables state locking.

### Q14 — select ONE
When is the `-target` option appropriate?
- A. In exceptional situations, such as recovering from errors or working around a specific problem.
- B. As the normal way to apply changes in large configurations.
- C. Whenever a module is added.
- D. Every time you create a new resource.

### Q15 — select ONE
A resource has `lifecycle { prevent_destroy = true }`. You run `terraform destroy`. What happens?
- A. All other resources are destroyed and the protected one is skipped.
- B. The protected resource is destroyed after a second confirmation.
- C. Terraform reports an error, and no resources are destroyed.
- D. Terraform removes the resource from state but doesn't destroy it.

### Q16 — select ONE
A teammate clones a repository whose lock file selects AWS provider `5.1.0`. The constraint is `~> 5.0`, and `5.9.0` is available. Which version does `terraform init` install?
- A. `5.9.0`
- B. It fails until `-upgrade` is used
- C. `5.0.0`
- D. `5.1.0`

### Q17 — select ONE
Which command displays the Terraform CLI version together with the versions of the installed providers?
- A. `terraform show -version`
- B. `terraform -v providers`
- C. `terraform providers -version`
- D. `terraform version`

### Q18 — select ONE
Which command downloads and updates **only** modules?
- A. `terraform init -providers=false`
- B. `terraform get`
- C. `terraform modules`
- D. `terraform pull`

### Q19 — select ONE
An apply was meant to create 5 resources. It created 3, then failed on the 4th because of an IAM permission error. After the permission is fixed, what does the next `terraform apply` do?
- A. Creates the remaining 2 resources; the 3 created earlier are already in state.
- B. Rolls back the 3 created resources, then creates all 5.
- C. Recreates all 5 resources.
- D. Fails until you run `terraform destroy`.

### Q20 — select ONE
You run `terraform plan -destroy -out=d.tfplan`, then `terraform apply d.tfplan`. What happens?
- A. Terraform prompts for confirmation, then destroys.
- B. Terraform errors: destroy plans can't be saved.
- C. Terraform destroys the resources without prompting.
- D. Terraform creates the resources described in the plan.

### Q21 — select ONE
Which flag tells `terraform apply` to skip interactive approval?
- A. `-yes`
- B. `-force`
- C. `-auto-approve`
- D. `-no-prompt`

### Q22 — select ONE
Given `var.prod = false`, what does this string evaluate to?
```hcl
"%{ if var.prod }prod%{ else }dev%{ endif }-api"
```
- A. `"prod-api"`
- B. An error
- C. `"-api"`
- D. `"dev-api"`

### Q23 — select ONE
What does `flatten([["a", "b"], [], ["c"]])` return?
- A. `[["a", "b"], ["c"]]`
- B. `["a", "b", "c"]`
- C. `["a", "b", null, "c"]`
- D. `"abc"`

### Q24 — select ONE
What does `merge({ env = "dev", team = "a" }, { team = "b" })` return?
- A. `{ env = "dev", team = "a" }`
- B. `{ team = "b" }`
- C. `{ env = "dev", team = "b" }`
- D. An error caused by the duplicate key

### Q25 — select ONE
What does `length("terraform")` return?
- A. `1`
- B. `9`
- C. An error: `length` works only on collections
- D. `"9"`

### Q26 — select ONE
What does `element(["a", "b", "c"], 4)` return?
- A. An error: index out of range
- B. `"c"`
- C. `null`
- D. `"b"`

### Q27 — select ONE
What is the result of `toset(["b", "a", "b"])`?
- A. An error: duplicates are not allowed
- B. A list `["b", "a", "b"]`
- C. A list `["a", "b", "b"]`
- D. A set containing `"a"` and `"b"`

### Q28 — select ONE
A variable has `type = list(string)`, and the caller passes `["a", 1]`. What is the result?
- A. `["a", "1"]` — the number is converted to a string
- B. An error: mixed types
- C. `["a"]` — the invalid element is dropped
- D. `["a", 1]` unchanged

### Q29 — select ONE
Inside a resource's `postcondition`, how do you refer to that resource's own attributes?
- A. `this.<attr>`
- B. `resource.<attr>`
- C. `self.<attr>`
- D. `each.<attr>`

### Q30 — select ONE
```hcl
dynamic "setting" {
  for_each = var.settings
  iterator = s
  content {
    name  = s.key
    value = s.value
  }
}
```
Without the `iterator = s` line, what name would refer to the current element?
- A. `each`
- B. `dynamic`
- C. `item`
- D. `setting`

### Q31 — select ONE
```hcl
resource "aws_eip" "this" {
  for_each = toset(aws_instance.app[*].id)
  instance = each.key
}
```
The `aws_instance.app` instances are being created in the same apply. What happens at plan time?
- A. It works; Terraform creates EIPs after the instances.
- B. An error: the `for_each` keys can't be determined until apply.
- C. Terraform creates one EIP with an unknown key.
- D. Terraform silently skips the EIPs.

### Q32 — select ONE
`aws_iam_user.u` uses `for_each`. Which expression returns a list of all the users' ARNs?
- A. `values(aws_iam_user.u)[*].arn`
- B. `aws_iam_user.u[*].arn`
- C. `aws_iam_user.u.arn`
- D. `aws_iam_user.u["*"].arn`

### Q33 — select ONE
A database password is read from Vault with `data "vault_kv_secret_v2"` and passed to `aws_db_instance.password`. Where does the password value end up?
- A. Nowhere — Vault values are never persisted.
- B. Only in Vault's audit log.
- C. In Terraform state (and in saved plan files), in plain text.
- D. Only in environment variables.

### Q34 — select ONE
In Terraform 1.10 and later, which variable setting lets a value be used during a run **without** being persisted to state or plan files?
- A. `sensitive = true`
- B. `nullable = false`
- C. `ephemeral = true`
- D. `secret = true`

### Q35 — select ONE
What does `templatefile("${path.module}/user_data.tftpl", { port = 8080 })` do?
- A. Reads a file and renders it as a template, using the given variables.
- B. Writes a template file to disk.
- C. Downloads a template from the registry.
- D. Validates HCL syntax in the file.

### Q36 — select ONE
A module block uses `count = 1`. How do you reference its output `endpoint`?
- A. `module.api.endpoint`
- B. `module.api.endpoint[0]`
- C. `module[0].api.endpoint`
- D. `module.api[0].endpoint`

### Q37 — select ONE
The root module is in `envs/prod/`, and the module is in `modules/db/` at the repository root. Which `source` is correct from `envs/prod/main.tf`?
- A. `"modules/db"`
- B. `"/modules/db"`
- C. `"../../modules/db"`
- D. `"root::modules/db"`

### Q38 — select ONE
What happens if you add `version = "1.2.0"` to a module block whose `source` is `"./modules/db"`?
- A. Terraform checks out tag 1.2.0 from Git.
- B. Terraform reports an error, because `version` applies only to registry sources.
- C. The argument is silently ignored.
- D. Terraform copies the module to a folder named 1.2.0.

### Q39 — select ONE
A child module declares `variable "subnet_ids" { type = list(string) }` with no default. The `module` block doesn't set it. What happens?
- A. An empty list is used.
- B. `null` is used.
- C. Terraform reports a missing required argument.
- D. Terraform prompts during apply.

### Q40 — select ONE
A legacy module contains its own `provider "aws"` block. Which is a consequence?
- A. The module gets its own state file.
- B. The module can't be called with `count`, `for_each`, or `depends_on`.
- C. The module can't define outputs.
- D. Its resources are created in parallel with no ordering.

### Q41 — select ONE
How are new module versions published on the public Terraform Registry?
- A. By pushing Git tags that follow semantic versioning in the linked repository.
- B. By uploading zip files through the CLI.
- C. By editing a `VERSION` file.
- D. Through `terraform publish`.

### Q42 — select ONE
In Terraform 1.10 and later, which `s3` backend argument enables state locking using an S3 lock file instead of a DynamoDB table?
- A. `dynamodb_table = "none"`
- B. `lock = "s3"`
- C. `use_lockfile = true`
- D. `encrypt = true`

### Q43 — select ONE
With the local backend, what is `terraform.tfstate.backup`?
- A. The state of the `default` workspace only
- B. A copy of `.terraform.lock.hcl`
- C. An encrypted version of the state
- D. The state from before the most recent write

### Q44 — select ONE
A provider moved from `oldorg/thing` to `neworg/thing` in the registry. Existing resources in state still reference the old source. Which command updates state?
- A. `terraform init -upgrade`
- B. `terraform providers mirror`
- C. `terraform state mv oldorg neworg`
- D. `terraform state replace-provider oldorg/thing neworg/thing`

### Q45 — select ONE
What can a configuration read through the `terraform_remote_state` data source?
- A. Any resource attribute stored in the other state
- B. Only the root module outputs of the other state
- C. Only the other configuration's variables
- D. The other configuration's `.tf` files

### Q46 — select ONE
You move `aws_s3_bucket.logs` from the root module into a new child module, `module "logging"`, where it is named `aws_s3_bucket.this`. Which block avoids recreating the bucket?
- A. `moved { from = aws_s3_bucket.logs  to = module.logging.aws_s3_bucket.this }`
- B. `moved { from = module.logging.aws_s3_bucket.this  to = aws_s3_bucket.logs }`
- C. `import { to = module.logging.aws_s3_bucket.this  id = aws_s3_bucket.logs }`
- D. `removed { from = aws_s3_bucket.logs }`

### Q47 — select ONE
You run `terraform workspace delete -force test` while the `test` workspace still tracks resources. What happens to those real resources?
- A. They keep running but are no longer tracked by any state (orphaned).
- B. They are destroyed.
- C. They move to the `default` workspace.
- D. The command always fails while resources exist.

### Q48 — select ONE
After `terraform init -migrate-state` to a new S3 backend, what is the best way to confirm the migration worked?
- A. Run `terraform apply -auto-approve`.
- B. Run `terraform plan` and confirm it reports no changes.
- C. Delete the local state file and see whether errors occur.
- D. Run `terraform fmt`.

### Q49 — select ONE
`var.subnets` is a map of name → subnet ID, for subnets that already exist. Which import block imports them all into `aws_subnet.this` (Terraform 1.7+)?
- A.
```hcl
import {
  for_each = var.subnets
  to       = aws_subnet.this[each.key]
  id       = each.value
}
```
- B.
```hcl
import {
  count = length(var.subnets)
  to    = aws_subnet.this[count.index]
  id    = var.subnets[count.index]
}
```
- C.
```hcl
import {
  to = aws_subnet.this
  id = var.subnets
}
```
- D.
```hcl
import "aws_subnet" "this" {
  ids = values(var.subnets)
}
```

### Q50 — select ONE
Which command shows the attributes of the instance with key `"b"` of `aws_subnet.this`?
- A. `terraform state show aws_subnet.this.b`
- B. `terraform state show 'aws_subnet.this["b"]'`
- C. `terraform show aws_subnet.this[b]`
- D. `terraform state list -show b`

### Q51 — select ONE
You want detailed logs from **providers only**, not from Terraform Core. Which variable?
- A. `TF_LOG_CORE`
- B. `TF_PROVIDER_DEBUG`
- C. `TF_LOG_PROVIDER`
- D. `TF_LOG=PROVIDER`

### Q52 — select ONE
Terraform itself panics (crashes). Which file should you attach to a bug report?
- A. `terraform.tfstate`
- B. `terraform.rc`
- C. `.terraform.lock.hcl`
- D. `crash.log`

### Q53 — select ONE
What do **run tasks** in HCP Terraform do?
- A. Schedule nightly applies.
- B. Call external services (for example, security or compliance scanners) at defined stages of a run, and can affect whether it continues.
- C. Replace Sentinel policies.
- D. Run shell commands on your laptop.

### Q54 — select ONE
What do **dynamic provider credentials** in HCP Terraform provide?
- A. Short-lived cloud credentials obtained through workload identity (OIDC) for each run.
- B. Long-lived access keys stored as sensitive variables.
- C. Automatic rotation of SSH keys on your servers.
- D. Credentials shared between organisations.

### Q55 — select ONE
A workspace uses the VCS-driven workflow. A developer runs `terraform apply` from their laptop with a `cloud` block pointing at that workspace. What happens?
- A. The apply runs remotely as usual.
- B. The apply runs locally and overwrites remote state.
- C. Terraform refuses: applies for VCS-connected workspaces must come from the VCS integration (e.g. merges).
- D. The workspace switches to CLI-driven.

### Q56 — select ONE
In an HCP Terraform run where both are enabled, which stage comes directly after the plan?
- A. Apply
- B. Speculative plan
- C. Policy check
- D. Cost estimation

### Q57 — select ONE
What is **Terraform Enterprise**?
- A. A different configuration language.
- B. A self-hosted distribution of the HCP Terraform platform.
- C. A paid version of the Terraform CLI with extra commands.
- D. A provider for enterprise software.

---
**Stop.** Mark your answers with [answer-keys.md](answer-keys.md), record the score and per-domain results in
[SCORECARD.md](../SCORECARD.md), and log every miss in [mistakes/error-log.md](../mistakes/error-log.md).
