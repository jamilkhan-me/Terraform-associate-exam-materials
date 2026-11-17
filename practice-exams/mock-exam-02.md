# Mock Exam 2 — Full Simulation (Day 9)

**Questions:** 57 · **Time:** 60 minutes · **Exam conditions:** closed book, no terminal, no notes.
Answers in `answer-keys.md` → *Mock Exam 02* (do not open until submitted).
**Format:** approximation of the real exam — not official. All questions are original.
Answer format: `1. C (2)` — letter(s) + confidence 1/2/3.

---

### Q1 — select ONE
Which advantage of Infrastructure as Code most directly enables peer review before infrastructure changes?
- A. Changes take effect without any API calls.
- B. Cloud consoles are no longer needed for read access.
- C. Changes are expressed as code that can be stored in version control and reviewed in pull requests.
- D. It guarantees there will be no configuration errors.

### Q2 — select ONE
Which statement about idempotency in Terraform is correct?
- A. Each `terraform apply` recreates all resources from scratch.
- B. Terraform runs each script exactly once per server.
- C. Each apply increments a version number on every resource.
- D. Applying an unchanged configuration to unchanged infrastructure results in no changes.

### Q3 — select TWO
Why might an organisation choose Terraform over a cloud-specific IaC tool?
- A. It offers one workflow across multiple clouds and SaaS platforms.
- B. It doesn't need to track state.
- C. It has a large ecosystem of providers, including non-cloud services.
- D. Its resource types work on any cloud unchanged.
- E. It requires no credentials.

### Q4 — select ONE
The AMI of an `aws_instance` changes in the configuration. Which describes Terraform's typical behaviour?
- A. It connects to the instance over SSH and upgrades the OS in place.
- B. It replaces the instance with a new one built from the new AMI.
- C. It leaves the instance alone and only updates state.
- D. It snapshots the instance, then patches it.

### Q5 — select ONE
By default, where does `terraform init` install provider plugins?
- A. `~/.terraform.d/plugins`
- B. In a `.terraform/providers` directory inside the working directory
- C. `/usr/local/bin`
- D. Inside `terraform.tfstate`

### Q6 — select ONE
Which Terraform Registry provider tier describes providers maintained by a third-party technology company that has been verified by HashiCorp?
- A. Official
- B. Community
- C. Partner
- D. Archived

### Q7 — select ONE
A configuration contains two `provider "aws"` blocks, **neither** of which sets `alias`. What happens?
- A. Terraform uses the first block.
- B. Terraform uses the last block.
- C. Terraform merges the two blocks.
- D. Terraform reports a duplicate provider configuration error.

### Q8 — select ONE
A child module's resources must use the root module's provider configuration `aws.dr` as their default `aws` provider. What do you write in the `module` block?
- A. `provider = aws.dr`
- B. `providers = { aws = aws.dr }`
- C. `alias = "dr"`
- D. Nothing — modules automatically inherit aliased configurations

### Q9 — select ONE
How do provider plugins interact with Terraform Core?
- A. As separate processes that Terraform Core communicates with over RPC.
- B. They are compiled into the Terraform binary.
- C. Through HTTP calls to the registry on every operation.
- D. By reading and writing the state file directly.

### Q10 — select TWO
State may contain sensitive values. Which are recommended practices?
- A. Store state in a remote backend that encrypts data at rest and controls access.
- B. Commit state to Git so changes have history.
- C. Restrict who can read state and saved plan files.
- D. Mark variables `sensitive`, which encrypts them in state.
- E. Email state files to teammates who need them.

### Q11 — select ONE
Which field in a state file helps Terraform refuse to overwrite state with a snapshot from an unrelated state history?
- A. `serial`
- B. `version`
- C. `lineage`
- D. `terraform_version`

### Q12 — select ONE
You run `terraform apply` without a saved plan file. What happens first?
- A. Changes are applied immediately.
- B. Terraform errors because a plan file is required.
- C. Terraform creates a plan, shows it, and asks for approval.
- D. Terraform runs only `validate`.

### Q13 — select ONE
Which command checks formatting in CI **without** modifying files?
- A. `terraform validate -fmt`
- B. `terraform fmt -check`
- C. `terraform fmt -write=true`
- D. `terraform plan -fmt`

### Q14 — select TWO
Which statements about `terraform validate` are true?
- A. It can run after `terraform init -backend=false`.
- B. It detects that an AMI ID does not exist in your account.
- C. It detects references to undeclared variables.
- D. It updates state.
- E. It requires valid cloud credentials.

### Q15 — select ONE
Which command opens an interactive session for evaluating expressions such as `cidrsubnet("10.0.0.0/16", 8, 1)`?
- A. `terraform eval`
- B. `terraform repl`
- C. `terraform show -expr`
- D. `terraform console`

### Q16 — select ONE
What is the recommended way to force replacement of `aws_instance.web` while being able to review the change in a plan?
- A. `terraform taint aws_instance.web`, then `terraform apply`
- B. `terraform apply -replace="aws_instance.web"`
- C. `terraform state rm aws_instance.web`, then `terraform apply`
- D. `terraform destroy -target=aws_instance.web`, then `terraform apply`

### Q17 — select ONE
You changed the backend configuration and do **not** want existing state copied to the new location. Which command?
- A. `terraform init -migrate-state`
- B. `terraform init -upgrade`
- C. `terraform init -reconfigure`
- D. `terraform init -backend=false`

### Q18 — select ONE
A script needs **all** root outputs, including sensitive ones, in machine-readable form. Which command?
- A. `terraform output -json`
- B. `terraform output -raw`
- C. `terraform show -outputs`
- D. `terraform state list -outputs`

### Q19 — select ONE
You saved `tfplan`. Before you apply it, a colleague applies a different change to the same state. You then run `terraform apply tfplan`. What happens?
- A. Terraform applies your plan anyway.
- B. Terraform re-plans automatically and applies.
- C. Terraform refuses because the saved plan is stale.
- D. Terraform merges both changes.

### Q20 — select ONE
In which format does `terraform graph` output the dependency graph?
- A. PNG
- B. JSON
- C. YAML
- D. DOT

### Q21 — select ONE
What does `terraform -chdir=infra plan` do?
- A. Runs `plan` as if it had been started in the `infra` directory.
- B. Changes the shell's working directory permanently.
- C. Copies `infra` into the current directory and plans.
- D. Plans only resources whose names start with `infra`.

### Q22 — select ONE
```hcl
locals {
  m = { b = 2, a = 1, c = 3 }
}
output "x" {
  value = keys(local.m)
}
```
What is `x`?
- A. `[2, 1, 3]`
- B. `["b", "a", "c"]`
- C. `["a", "b", "c"]`
- D. `[1, 2, 3]`

### Q23 — select ONE
What does `lookup({ a = "x" }, "b", "y")` return?
- A. `null`
- B. An error, because key `b` is missing
- C. `"x"`
- D. `"y"`

### Q24 — select ONE
What does `coalesce(null, "", "fallback")` return?
- A. `null`
- B. `""`
- C. `"fallback"`
- D. An error

### Q25 — select ONE
`aws_eip.this` uses `count = var.create ? 1 : 0`. Which reference safely returns the public IP, or `null` when the EIP isn't created?
- A. `aws_eip.this.public_ip`
- B. `aws_eip.this[0].public_ip`
- C. `one(aws_eip.this[*].public_ip)`
- D. `aws_eip.this["0"].public_ip`

### Q26 — select ONE
A variable has no default. CI runs `terraform plan -input=false` without providing a value. What happens?
- A. Terraform errors, reporting that no value was given for a required variable.
- B. Terraform uses an empty string.
- C. Terraform uses `null`.
- D. Terraform prompts for the value.

### Q27 — select ONE
```hcl
variable "cfg" {
  type = object({
    name     = string
    replicas = optional(number, 3)
  })
}
```
A caller passes `{ name = "api" }`. What is `var.cfg.replicas`?
- A. `null`
- B. `3`
- C. `0`
- D. An error: missing attribute `replicas`

### Q28 — select ONE
Which creates an **implicit** dependency between two resources?
- A. Declaring both resources in the same file.
- B. Giving them similar names.
- C. Using one resource's attribute in an argument of the other.
- D. Adding a comment that mentions the other resource.

### Q29 — select ONE
What is a possible side effect of adding `depends_on` to a **data source**?
- A. The data source becomes a managed resource.
- B. Terraform may defer reading it until apply, making dependent values unknown during plan.
- C. Terraform errors; data sources don't support `depends_on`.
- D. No effect is ever possible.

### Q30 — select ONE
A security scanner adds a `LastScanned` tag to your instances. You want Terraform to ignore **only** that tag key. Which setting?
- A. `lifecycle { ignore_changes = [tags] }`
- B. `lifecycle { ignore_changes = [tags["LastScanned"]] }`
- C. `lifecycle { prevent_destroy = true }`
- D. `lifecycle { replace_triggered_by = [tags] }`

### Q31 — select ONE
`aws_ecs_service.app` must be **replaced** whenever `terraform_data.release` changes. Which configuration?
- A. `depends_on = [terraform_data.release]`
- B. `lifecycle { create_before_destroy = true }`
- C. `lifecycle { ignore_changes = [terraform_data.release] }`
- D. `lifecycle { replace_triggered_by = [terraform_data.release] }`

### Q32 — select TWO
Which statements about provisioners are true?
- A. `local-exec` runs on the machine executing Terraform.
- B. Creation-time provisioners run on every `terraform apply`.
- C. If a creation-time provisioner fails, the resource is marked as tainted by default.
- D. The commands a provisioner will run are shown in detail in the plan.
- E. `remote-exec` runs commands on the machine executing Terraform.

### Q33 — select ONE
You want a **non-blocking warning** if a website's health endpoint does not return 200 after apply. What should you use?
- A. A `postcondition` block
- B. A `check` block with an `assert`
- C. A variable `validation` block
- D. A `precondition` block

### Q34 — select ONE
A variable marked `sensitive = true` is used in a resource argument. How does `terraform plan` display that argument?
- A. As `(sensitive value)`
- B. In plain text
- C. It errors and refuses to plan
- D. The argument is omitted entirely from state

### Q35 — select ONE
```hcl
locals {
  users   = [{ name = "ana", team = "ops" }, { name = "raj", team = "dev" }]
  by_name = { for u in local.users : u.name => u.team }
}
```
What is `local.by_name`?
- A. `["ops", "dev"]`
- B. `{ ops = "ana", dev = "raj" }`
- C. An error: `for` cannot produce a map from a list
- D. `{ ana = "ops", raj = "dev" }`

### Q36 — select ONE
A child module declares `variable "region" { default = "eu-west-1" }`. The root module's `var.region` is `"us-east-1"`, but the `module` block does not pass `region`. Which value does the child use?
- A. `"us-east-1"`
- B. `"eu-west-1"`
- C. An error: `region` must be passed
- D. `null`

### Q37 — select ONE
Which is a valid source address for a module in HCP Terraform's **private registry**?
- A. `"tfe://acme/network"`
- B. `"acme/network/aws/private"`
- C. `"app.terraform.io/acme/network/aws"`
- D. `"registry://app.terraform.io/acme/network"`

### Q38 — select ONE
A registry module has `version = "~> 3.2"`; 3.2.0 is installed and 3.3.0 has been released. How do you install 3.3.0?
- A. `terraform init -upgrade`
- B. `terraform validate`
- C. `terraform plan -upgrade`
- D. `terraform state replace-provider`

### Q39 — select ONE
Which source correctly references the `modules/vpc` subdirectory of a Git repository at tag `v2.0.0`?
- A. `"git::https://example.com/infra.git/modules/vpc@v2.0.0"`
- B. `"git::https://example.com/infra.git?dir=modules/vpc&ref=v2.0.0"`
- C. `"https://example.com/infra.git#modules/vpc:v2.0.0"`
- D. `"git::https://example.com/infra.git//modules/vpc?ref=v2.0.0"`

### Q40 — select ONE
After `terraform apply`, outputs declared inside a child module are not shown. Why?
- A. Child module outputs are only printed with `-verbose`.
- B. Only root module outputs are displayed; expose the value through a root `output` if you need it shown.
- C. Child module outputs are stored only in `.terraform/`.
- D. Outputs in child modules are ignored by Terraform.

### Q41 — select ONE
Module `network` outputs `subnet_ids`; module `app` needs them. What is the correct approach?
- A. Inside the `app` module, reference `module.network.subnet_ids` directly.
- B. In the root module, set `subnet_ids = module.network.subnet_ids` in the `module "app"` block.
- C. Use `terraform_remote_state` — modules in one configuration can't share values.
- D. Declare `subnet_ids` as a global variable.

### Q42 — select ONE
You want the decision to **stop managing** an S3 bucket (without deleting it) to be reviewed in a pull request and shown in a plan. Which approach?
- A. `terraform state rm aws_s3_bucket.archive`
- B. Delete the resource block and run `terraform apply`
- C. Replace the resource block with a `removed` block whose `lifecycle` sets `destroy = false`
- D. Add `lifecycle { prevent_destroy = true }`

### Q43 — select ONE
Which statement about the default `local` backend is TRUE?
- A. It stores state on the local filesystem and isn't suited to team collaboration.
- B. It encrypts state at rest automatically.
- C. It stores state in HCP Terraform.
- D. It doesn't support workspaces.

### Q44 — select ONE
A backend block contains `key = "${var.env}/terraform.tfstate"`. What happens at `terraform init`?
- A. The key is resolved from `var.env`.
- B. Terraform errors because variables are not allowed in backend configuration.
- C. Terraform prompts for `env`.
- D. The literal string `${var.env}` is used as the key.

### Q45 — select ONE
How do you save a local backup copy of the current remote state?
- A. `terraform state push > backup.tfstate`
- B. `terraform state pull > backup.tfstate`
- C. `terraform show -backup`
- D. `terraform output > backup.tfstate`

### Q46 — select ONE
Two CI jobs run `terraform apply` simultaneously against the same S3 backend with locking configured. What happens to the job that starts second?
- A. It fails to acquire the state lock (or waits, if `-lock-timeout` is set).
- B. Both apply and Terraform merges their changes.
- C. The second job overwrites the first job's changes.
- D. The second job silently switches to local state.

### Q47 — select ONE
Someone deleted a Terraform-managed security group in the console. What will the next `terraform plan` propose?
- A. Nothing, because the configuration hasn't changed.
- B. To remove the resource block from configuration.
- C. To create the security group again.
- D. To import the deleted security group.

### Q48 — select TWO
Which statements about Terraform CLI workspaces are true?
- A. The current workspace's name is available as `terraform.workspace`.
- B. Each workspace uses separate backend credentials.
- C. `terraform workspace select` switches which state Terraform uses.
- D. Each workspace gets its own copy of the configuration files.

### Q49 — select ONE
You add an `import` block and matching configuration for an existing bucket. Which plan summary indicates that your configuration exactly matches the real bucket?
- A. `Plan: 1 to add, 0 to change, 0 to destroy.`
- B. `Plan: 1 to import, 0 to add, 0 to change, 0 to destroy.`
- C. `Plan: 1 to import, 1 to add, 0 to change, 1 to destroy.`
- D. `Plan: 0 to add, 1 to change, 0 to destroy.`

### Q50 — select ONE
Which command lists only the resources within the module `network`?
- A. `terraform state list module.network`
- B. `terraform show module.network`
- C. `terraform state show module.network`
- D. `terraform output module.network`

### Q51 — select TWO
You want detailed logs written to a file. Which environment variables must you set?
- A. `TF_LOG`
- B. `TF_LOG_PATH`
- C. `TF_DEBUG_FILE`
- D. `TF_VERBOSE`

### Q52 — select ONE
What determines the `id` value you use when importing a resource?
- A. It's always the resource's ARN.
- B. It's defined by the provider for each resource type.
- C. It's always the `Name` tag.
- D. It's the Terraform resource address.

### Q53 — select ONE
Which Sentinel enforcement level blocks a run on failure but allows authorised users to override it?
- A. Advisory
- B. Soft-mandatory
- C. Hard-mandatory
- D. Override-optional

### Q54 — select ONE
You need the same cloud credentials in 30 HCP Terraform workspaces and want to manage them in one place. Which feature fits best?
- A. Variable sets
- B. Run triggers
- C. Speculative plans
- D. The private registry

### Q55 — select ONE
Which block connects a CLI-driven configuration to an HCP Terraform workspace?
```hcl
terraform {
  ________ {
    organization = "jk-labs"
    workspaces {
      name = "app-prod"
    }
  }
}
```
- A. `remote_state`
- B. `hcp`
- C. `cloud`
- D. `workspace`

### Q56 — select ONE
What is the purpose of **projects** in HCP Terraform?
- A. They replace organisations.
- B. They group related workspaces so access and shared settings can be managed together.
- C. They store Terraform state.
- D. They are another name for VCS repositories.

### Q57 — select ONE
You want Terraform to run on your own machine but store state in HCP Terraform. Which workspace execution mode?
- A. Remote
- B. Agent
- C. Local
- D. Speculative

---
**Stop.** Mark your answers with [answer-keys.md](answer-keys.md), record the score and per-domain results in
[SCORECARD.md](../SCORECARD.md), and log every miss in [mistakes/error-log.md](../mistakes/error-log.md).
