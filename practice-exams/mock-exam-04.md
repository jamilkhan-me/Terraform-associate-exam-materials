# Mock Exam 4 — Mixed Review A

**Questions:** 50 · **Time:** 50 minutes · **Closed book** · Answers in [answer-keys.md](answer-keys.md#mock-exam-04) (don't open it until you've finished).
**Scope:** all domains. **Source:** Practice Exam 1 from the original 15-day notes, corrected (e.g. Q3) and with the options shuffled. **When:** extension Day 11, or any time after Mock 3 as a fresh re-check.
Write each answer as `1. B (3)`: the letter plus your confidence, 1 = guess, 2 = unsure, 3 = sure.

---

### Q1 — select ONE
Which best describes Terraform's execution model?
- A. Event-driven: resources are created when cloud events fire.
- B. Imperative: you script each API call in order.
- C. Declarative: you describe the desired end state and Terraform works out the actions to reach it.
- D. Purely functional: it computes values but never causes side effects.

### Q2 — select ONE
Which command initializes a working directory and installs the providers it needs?
- A. `terraform init`
- B. `terraform get`
- C. `terraform plan`
- D. `terraform validate`

### Q3 — select ONE
Which version constraint allows `2.3.5` and `2.3.9` but NOT `2.4.0`?
- A. `= 2.3.5`
- B. `~> 2.3`
- C. `>= 2.3.0`
- D. `~> 2.3.0`

### Q4 — select ONE
What does `terraform validate` check?
- A. Whether the next apply will succeed against the cloud provider.
- B. Whether real infrastructure matches the configuration.
- C. The estimated monthly cost of the planned changes.
- D. Syntax and internal consistency of the configuration, without contacting any provider API or reading state.

### Q5 — select ONE
What is a `data` block used for?
- A. Storing secrets securely outside of state.
- B. Declaring values exported from a module.
- C. Reading information about existing objects that this configuration does not manage.
- D. Creating infrastructure that should never be destroyed.

### Q6 — select ONE
The same variable is set by a default, by `TF_VAR_region`, by `terraform.tfvars` and by `-var="region=..."` on the command line. Which value wins?
- A. The default in the `variable` block.
- B. The `-var` command-line value.
- C. The `terraform.tfvars` value.
- D. The `TF_VAR_region` environment variable.

### Q7 — select ONE
A variable must hold `["a", "b", "a"]`, and both the order and the duplicate matter. Which type fits?
- A. `object({})`
- B. `list(string)`
- C. `map(string)`
- D. `set(string)`

### Q8 — select ONE
Which function combines two maps into one?
- A. `concat()`
- B. `zipmap()`
- C. `join()`
- D. `merge()`

### Q9 — select ONE
When is `depends_on` needed?
- A. When a real dependency exists but no attribute reference expresses it.
- B. Whenever a resource uses `for_each`.
- C. Never, because Terraform always infers every dependency.
- D. Whenever a resource uses `count`.

### Q10 — select ONE
What does `sensitive = true` on an output do?
- A. Redacts the value in CLI output; the value is still stored in plain text in state.
- B. Removes the value from state entirely.
- C. Encrypts the value in the state file.
- D. Prevents other modules from reading the value.

### Q11 — select ONE
What does `terraform fmt` primarily do?
- A. Applies pending changes.
- B. Validates syntax and references.
- C. Refreshes state from real infrastructure.
- D. Rewrites configuration files to the canonical style.

### Q12 — select ONE
What does `terraform plan -out=tfplan` do?
- A. Applies the changes immediately.
- B. Saves the plan to a file so that exactly that plan can be applied later.
- C. Deletes any previously saved plans.
- D. Writes only a JSON summary of the changes.

### Q13 — select ONE
What does the `for_each` meta-argument accept?
- A. Only a list.
- B. Only a number.
- C. A map, or a set of strings.
- D. Only a single string.

### Q14 — select ONE
What best describes "drift"?
- A. A bug in Terraform Core.
- B. Two teammates using different provider versions.
- C. Real infrastructure that differs from what state and configuration describe, usually due to changes made outside Terraform.
- D. A syntax error in a `.tf` file.

### Q15 — select ONE
Which mechanism checks an input value before any resource is planned?
- A. A `check` block.
- B. A `validation` block inside the `variable` block.
- C. A `precondition` in a resource's `lifecycle`.
- D. The `prevent_destroy` lifecycle argument.

### Q16 — select ONE
`count.index` and `each.key` are used with which meta-arguments?
- A. `count` and `for_each` respectively.
- B. Only inside output blocks.
- C. Only inside module blocks.
- D. Both are interchangeable in any resource.

### Q17 — select ONE
What is the `~>` operator called?
- A. The pessimistic constraint operator.
- B. The range operator.
- C. The strict equality operator.
- D. The lock operator.

### Q18 — select ONE
Which statement about `.terraform.lock.hcl` is TRUE?
- A. It should be excluded from version control.
- B. It records the selected provider versions and checksums, and should be committed to version control.
- C. It records module versions.
- D. It stores the resource state.

### Q19 — select ONE
In a CI job, `terraform plan -detailed-exitcode` exits with code `2`. What does that mean?
- A. A destroy is required.
- B. The plan succeeded with no changes.
- C. An error occurred.
- D. The plan succeeded and there are changes to apply.

### Q20 — select ONE
What is the safest way for CI to apply exactly what reviewers approved?
- A. Skip `plan` and run `terraform apply -refresh=false`.
- B. An interactive `terraform apply` on the runner.
- C. `terraform apply -auto-approve` straight away.
- D. `terraform plan -out=tfplan`, review it, then `terraform apply tfplan`.

### Q21 — select ONE
How should a module from the public registry normally be referenced in production?
- A. With a pinned version constraint, e.g. `version = "~> 5.0"`.
- B. By copying the files into the repo by hand instead.
- C. With `source = "latest"`.
- D. Never pinned, so it always gets the latest version.

### Q22 — select ONE
How do you reference output `vpc_id` from a module block named `network`?
- A. `var.network.vpc_id`
- B. `module.network.vpc_id`
- C. `output.network.vpc_id`
- D. `network.vpc_id`

### Q23 — select ONE
What is `terraform console` used for?
- A. Evaluating expressions and functions interactively, without changing anything.
- B. Editing state directly.
- C. Opening an SSH session to a resource.
- D. Applying infrastructure changes.

### Q24 — select ONE
Which of these creates an implicit dependency?
- A. Adding a `for_each` loop.
- B. Writing `depends_on = [aws_iam_role.x]`.
- C. Referencing `aws_vpc.main.id` inside an `aws_subnet` resource.
- D. Adding a `provisioner` block.

### Q25 — select ONE
What does `lifecycle { prevent_destroy = true }` do?
- A. Allows destroys but logs a warning.
- B. Encrypts the resource.
- C. Makes any plan that would destroy or replace the resource fail with an error.
- D. Affects `plan` only, not `apply`.

### Q26 — select ONE
What does `jsonencode()` do?
- A. Parses a JSON string into a Terraform value.
- B. Converts a Terraform value into a JSON-formatted string.
- C. Validates JSON syntax only.
- D. Decrypts a string.

### Q27 — select ONE
Which statement about `list` and `set` is correct?
- A. They behave identically.
- B. A set can only contain numbers.
- C. A set keeps order and allows duplicates.
- D. A list keeps order and allows duplicates; a set is unordered with unique elements.

### Q28 — select ONE
Which variable-definition files are loaded automatically, without `-var-file`?
- A. `terraform.tfvars`, `terraform.tfvars.json`, and any `*.auto.tfvars` / `*.auto.tfvars.json`.
- B. Only files in a `vars/` subdirectory.
- C. Every file ending in `.tfvars` in the directory.
- D. None; all files need `-var-file`.

### Q29 — select ONE
What is a `postcondition` inside the `lifecycle` block of a data source used for?
- A. Creating a dependency on another resource.
- B. Asserting something about the data that was read, failing the run if it is false.
- C. Preventing the data source from being read.
- D. Formatting the data source output.

### Q30 — select ONE
You saved a plan as `tfplan`. Which command displays it in human-readable form?
- A. `terraform plan -out=tfplan`
- B. `terraform output tfplan`
- C. `terraform show tfplan`
- D. `terraform state show tfplan`

### Q31 — select ONE
What is the recommended way to supply a real database password to Terraform?
- A. Hard-code it in the `.tf` file.
- B. Put it in `terraform.tfvars` and commit it.
- C. Store it in an output marked `sensitive`.
- D. Fetch it from a secrets manager such as Vault, or pass it as a sensitive variable from a secure store, never from committed files.

### Q32 — select ONE
How should `terraform apply -target=aws_instance.web` be viewed?
- A. As the recommended way to apply changes.
- B. As required on every apply.
- C. As an exception mechanism for recovery situations, not routine use.
- D. As valid only for modules.

### Q33 — select ONE
Which statement best differentiates `resource` and `data` blocks?
- A. Both create infrastructure in the same way.
- B. `data` blocks are deprecated.
- C. A `resource` is created, updated and destroyed by Terraform; a `data` source is only read.
- D. `resource` blocks cannot export attributes.

### Q34 — select ONE
What is required to manage AWS and Azure resources in one configuration?
- A. HCP Terraform.
- B. Declare both providers (in `required_providers`, plus provider blocks as needed) and use each provider's resource types.
- C. It isn't possible; use two configurations.
- D. Two separate Terraform installations.

### Q35 — select ONE
What does `terraform destroy -target=aws_instance.web` do?
- A. Destroys everything in state.
- B. Destroys only the targeted resource and anything that depends on it.
- C. It only works with modules.
- D. It is not a valid command.

### Q36 — select ONE
What is the root module?
- A. Any module that has no variables.
- B. The most-downloaded module in the registry.
- C. The module that contains the backend block only.
- D. The configuration in the working directory where you run Terraform commands.

### Q37 — select ONE
A module `source` can be any of these EXCEPT:
- A. The Terraform Registry.
- B. A local relative path such as `./modules/vpc`.
- C. A Git repository.
- D. An existing state file.

### Q38 — select ONE
How does a child module get values from the root module?
- A. It inherits all root variables automatically.
- B. Only through arguments passed explicitly in the `module` block.
- C. It uses `data.root.*` references.
- D. It reads `terraform.tfstate` directly.

### Q39 — select ONE
Why pin module versions in production?
- A. It only affects cost estimation.
- B. Terraform syntax requires it.
- C. To avoid unexpected behaviour changes from a new upstream release.
- D. There is no real benefit.

### Q40 — select ONE
Which statement about the default local backend is TRUE?
- A. State is a local file locked only on that machine, so it is unsuitable for a team.
- B. It requires HCP Terraform.
- C. Its state can never be migrated to a remote backend.
- D. It locks state across every machine in the team.

### Q41 — select ONE
What must you run after changing the `backend` block?
- A. `terraform init` (it offers to migrate state; or use `-migrate-state` / `-reconfigure`).
- B. `terraform destroy` first.
- C. Nothing, the change is detected automatically.
- D. `terraform state rm` on every resource.

### Q42 — select ONE
What does `terraform apply -refresh-only` do?
- A. Updates state to match real infrastructure without changing any infrastructure.
- B. Deletes the state file.
- C. Behaves exactly like a normal apply.
- D. Changes real infrastructure to match the configuration.

### Q43 — select ONE
Which command changes a resource's address in state without destroying or recreating it?
- A. `terraform taint`
- B. `terraform state mv`
- C. `terraform import`
- D. `terraform state rm`

### Q44 — select ONE
What does `terraform state rm aws_instance.old` do?
- A. Renames the resource.
- B. Terraform stops tracking the instance; the real instance keeps running.
- C. The same as `terraform destroy -target`.
- D. Terminates the EC2 instance.

### Q45 — select ONE
From Terraform 1.10, what enables S3 backend state locking without DynamoDB?
- A. A separate lock provider plugin.
- B. The `dynamodb_table` argument.
- C. It is not possible without DynamoDB.
- D. `use_lockfile = true`, which uses S3 conditional writes to create a lock file.

### Q46 — select ONE
What does the classic `terraform import ADDRESS ID` command do?
- A. Adds the existing object to state only; you must write matching configuration yourself.
- B. Works only for resources inside modules.
- C. Deletes and recreates the resource.
- D. Generates matching `.tf` configuration automatically.

### Q47 — select ONE
Which approach imports a resource AND generates its configuration?
- A. `terraform refresh`
- B. `terraform state push`
- C. `terraform import --generate`
- D. An `import` block plus `terraform plan -generate-config-out=FILE`.

### Q48 — select ONE
What does setting `TF_LOG=TRACE` before a command do?
- A. Silences all output.
- B. Logs only errors.
- C. Enables the most verbose logging level.
- D. Affects HCP Terraform runs only.

### Q49 — select ONE
What does `TF_LOG_PATH` do?
- A. Writes the log output to a file; `TF_LOG` must also be set.
- B. Chooses which provider to log.
- C. Sets the path of the state file.
- D. Sets the path of the saved plan.

### Q50 — select ONE
In HCP Terraform, what does a workspace most closely correspond to?
- A. A GitHub repository only.
- B. An IAM role.
- C. One configuration's state plus its variables, settings and run history.
- D. A billing account.

---

**Stop.** Mark your answers with [answer-keys.md](answer-keys.md) and record the score in [SCORECARD.md](../SCORECARD.md). Log every miss in [mistakes/error-log.md](../mistakes/error-log.md).
