# Mock Exam 5 — Mixed Review B

**Questions:** 46 · **Time:** 46 minutes · **Closed book** · Answers in [answer-keys.md](answer-keys.md#mock-exam-05) (don't open it until you've finished).
**Scope:** all domains. **Source:** Practice Exam 2 from the original 15-day notes, corrected, with four weak questions replaced and the options shuffled. **When:** extension Day 12, or the day before the exam.
Write each answer as `1. B (3)`: the letter plus your confidence, 1 = guess, 2 = unsure, 3 = sure.

---

### Q1 — select ONE
When is HCP Terraform's agent execution mode the right choice?
- A. When you never want remote execution.
- B. When infrastructure is in a private network that HCP Terraform's shared workers cannot reach.
- C. When you are on the free tier.
- D. When you want runs on HCP Terraform's shared workers.

### Q2 — select ONE
What do Sentinel and OPA provide in HCP Terraform?
- A. Module hosting.
- B. Cost reporting only.
- C. Policy as code evaluated after the plan, which can block non-compliant runs before apply.
- D. DNS management.

### Q3 — select ONE
What does a `cloud` block in the `terraform` block enable?
- A. The CLI-driven workflow: local `terraform plan/apply` commands run in HCP Terraform.
- B. Nothing unless you are on a paid plan.
- C. Importing from AWS CloudFormation.
- D. A purely local workflow.

### Q4 — select ONE
What do dynamic provider credentials mainly improve?
- A. Module registry search.
- B. Plan speed only.
- C. Security: each run gets short-lived credentials via OIDC instead of static long-lived keys.
- D. The UI theme.

### Q5 — select ONE
What is a project in HCP Terraform?
- A. A container that groups related workspaces for organization and shared access/variable sets.
- B. Another name for a workspace.
- C. A Git repository.
- D. A feature that only exists in the free tier.

### Q6 — select ONE
In a VCS-driven workspace, what does opening a pull request typically trigger?
- A. An automatic apply to production.
- B. A destroy run.
- C. A speculative plan, shown on the pull request, that cannot be applied.
- D. Nothing at all.

### Q7 — select ONE
How do the remote and local execution modes differ?
- A. Local mode doesn't store state anywhere.
- B. Remote mode has no web UI.
- C. They are identical.
- D. Remote runs plan/apply on HCP Terraform workers; local runs them on your machine and uses HCP Terraform only for state.

### Q8 — select ONE
What does `terraform show` (with no arguments) display?
- A. The contents of the lock file.
- B. A new plan.
- C. Only the outputs, in JSON.
- D. The current state in human-readable form.

### Q9 — select ONE
Which statement about variable scope in modules is correct?
- A. A child module's variables are set only by arguments in the `module` block and are not visible elsewhere.
- B. Root variables are automatically visible in every child.
- C. Variables declared in a child module are global.
- D. Modules cannot declare variables.

### Q10 — select ONE
Why is committing `terraform.tfstate` to a public Git repository dangerous?
- A. There is no real risk.
- B. It only bloats the repository.
- C. It slows `git clone`.
- D. State can contain sensitive attribute values in plain text.

### Q11 — select ONE
What does `terraform state show aws_s3_bucket.demo` do?
- A. Formats the configuration.
- B. Shows all attributes recorded in state for that resource.
- C. Deletes the bucket.
- D. Creates a new bucket.

### Q12 — select ONE
What is HCP Terraform's private registry mainly used for?
- A. Sharing internally written modules (and providers) securely across an organization.
- B. Storing state files.
- C. Publishing public open-source modules only.
- D. Running applies.

### Q13 — select ONE
What distinguishes declarative IaC from imperative scripting?
- A. Declarative code always needs more lines.
- B. There is no meaningful difference.
- C. Declarative code defines the desired end state and the tool determines the steps.
- D. Imperative scripts are always faster.

### Q14 — select ONE
What does idempotency mean for Terraform?
- A. Applying the same configuration repeatedly reaches the same end state; with nothing to change, apply does nothing.
- B. Providers are re-downloaded on every run.
- C. Resources are destroyed automatically after use.
- D. Every apply changes something.

### Q15 — select ONE
What does "immutable infrastructure" mean?
- A. Replacing components with new ones instead of modifying them in place.
- B. Patching servers in place.
- C. Nothing can ever be destroyed.
- D. A rule that only applies to databases.

### Q16 — select ONE
What does "service-agnostic workflow" mean for Terraform?
- A. The same write/plan/apply workflow manages many platforms through provider plugins.
- B. Terraform works with only one cloud.
- C. Providers are optional.
- D. Providers replace the need for state.

### Q17 — select ONE
What does `terraform providers` show?
- A. The full contents of state.
- B. Installed operating systems.
- C. Billing information.
- D. The providers required by the configuration (and its modules) and those recorded in state.

### Q18 — select ONE
What is a provider `alias` used for?
- A. Renaming a resource.
- B. Defining several configurations of the same provider, e.g. two AWS regions.
- C. Encrypting state.
- D. Skipping version constraints.

### Q19 — select ONE
Official, Partner and Community are categories of what?
- A. HCP Terraform pricing tiers.
- B. State backends.
- C. Registry providers, by who maintains them.
- D. Terraform modules.

### Q20 — select ONE
What does `terraform init -upgrade` do?
- A. Upgrades the Terraform CLI itself.
- B. Migrates state to a new backend.
- C. Upgrades your HCP Terraform plan.
- D. Selects the newest provider (and module) versions allowed by your constraints, updating the lock file.

### Q21 — select ONE
What does `terraform fmt -check` do?
- A. Validates HCL syntax.
- B. Checks provider versions.
- C. Rewrites files and shows a diff.
- D. Exits non-zero if any file needs formatting, without rewriting files.

### Q22 — select ONE
What does `terraform init -from-module=SOURCE` do?
- A. Copies the given module into an empty working directory and initializes it.
- B. Deletes an existing module.
- C. Applies the module immediately.
- D. Works only with HCP Terraform.

### Q23 — select ONE
By default, how many resource operations does `terraform apply` run concurrently?
- A. Unlimited
- B. 1
- C. 5
- D. 10

### Q24 — select ONE
Which flag changes how many operations run concurrently during apply?
- A. `-threads=N`
- B. `-parallelism=N`
- C. `-parallel`
- D. `-concurrency=N`

### Q25 — select ONE
What does `-replace=ADDRESS` do on plan or apply?
- A. Forces that resource to be destroyed and recreated; it replaces the deprecated `terraform taint`.
- B. It renames a resource in state.
- C. It is deprecated in favour of `taint`.
- D. It only works on modules.

### Q26 — select ONE
How does a `check` block differ from preconditions and postconditions?
- A. `check` is another name for `validation`.
- B. They block apply in the same way.
- C. A failed `check` assertion produces a warning and the run continues; pre/postcondition failures are errors.
- D. `check` blocks only run during destroy.

### Q27 — select ONE
What does `lifecycle { ignore_changes = [tags] }` do?
- A. Deletes the `tags` attribute.
- B. It works only inside modules.
- C. Tells Terraform to ignore differences in `tags` when planning updates.
- D. Prevents any update to the resource.

### Q28 — select ONE
What is `terraform graph` used for?
- A. Listing provider versions.
- B. Producing the dependency graph in DOT format for visualization.
- C. Showing cost estimates.
- D. Charting cloud billing.

### Q29 — select ONE
Which argument is NOT valid inside a `variable` block?
- A. `validation`
- B. `depends_on`
- C. `sensitive`
- D. `nullable`

### Q30 — select ONE
What is `terraform.workspace` used for?
- A. Storing secrets.
- B. Triggering an HCP Terraform run.
- C. Setting the AWS region.
- D. Reading the current CLI workspace name inside the configuration.

### Q31 — select ONE
How do CLI workspaces differ from HCP Terraform workspaces?
- A. CLI workspaces require HCP Terraform.
- B. HCP Terraform workspaces are deprecated.
- C. A CLI workspace is an alternate state for the same working directory; an HCP Terraform workspace has its own configuration source, state, variables, permissions and run history.
- D. They are the same concept.

### Q32 — select ONE
You run `terraform workspace new dev` and then `terraform apply`. What happens?
- A. It requires HCP Terraform.
- B. It deletes the `default` workspace.
- C. The apply uses a separate, initially empty state for the `dev` workspace.
- D. It applies to the `default` workspace anyway.

### Q33 — select ONE
How does a `tuple` differ from a `list`?
- A. Tuples cannot be used in variables.
- B. They are identical.
- C. A tuple has a fixed length with its own type per position; a list holds any number of elements of one type.
- D. Lists cannot be indexed.

### Q34 — select ONE
What does `nullable = false` on a variable do?
- A. Is only valid on outputs.
- B. Makes the variable optional.
- C. Disallows `null` as the value (if `null` is passed, the default is used instead).
- D. Encrypts the variable.

### Q35 — select ONE
Which function returns `true` or `false` depending on whether an expression evaluates without error?
- A. `can()`
- B. `contains()`
- C. `regex()`
- D. `try()`

### Q36 — select ONE
What is `templatefile()` used for?
- A. Encrypting a file.
- B. Rendering a template file with supplied variables.
- C. Downloading a module.
- D. Validating JSON.

### Q37 — select ONE
Which statement best describes Terraform Core?
- A. A component that exists only in HCP Terraform.
- B. The `terraform` binary that parses configuration, builds the graph and manages state, relying on separate provider plugins to call platform APIs.
- C. A web UI.
- D. A single binary that contains every provider.

### Q38 — select ONE
You rename `resource "aws_instance" "web"` to `"app"` in config. What makes the next plan show a move instead of destroy + create?
- A. Adding `lifecycle { create_before_destroy = true }`.
- B. Running `terraform init -upgrade`.
- C. Running `terraform validate`.
- D. A `moved` block with `from = aws_instance.web` and `to = aws_instance.app`.

### Q39 — select ONE
You want Terraform to stop managing an S3 bucket without deleting it, as a change reviewed in a plan. What do you use?
- A. A `moved` block pointing to nothing.
- B. Delete the resource block and add a `removed` block with `lifecycle { destroy = false }`.
- C. `prevent_destroy = true` then delete the block.
- D. `terraform destroy -target` on the bucket.

### Q40 — select ONE
Which tool is mainly a configuration-management tool (installing and configuring software on existing servers)?
- A. Azure Bicep
- B. Ansible
- C. Terraform
- D. AWS CloudFormation

### Q41 — select ONE
What does `terraform login` do?
- A. Resets the state file.
- B. Logs in to the AWS console.
- C. Opens an SSH session to a managed instance.
- D. Obtains an API token for HCP Terraform and stores it in the CLI credentials file.

### Q42 — select ONE
What is a speculative plan?
- A. A plan-only run that previews changes and cannot be applied, e.g. on a pull request.
- B. A type of hard-mandatory policy.
- C. A run that deletes the workspace.
- D. A run that applies changes automatically.

### Q43 — select ONE
What is true about variable sets in HCP Terraform?
- A. They replace `variable` blocks in configuration.
- B. They can be applied to many workspaces, projects or a whole organization.
- C. They can only contain sensitive values.
- D. They apply to exactly one workspace.

### Q44 — select ONE
Which statement about HCP Terraform cost estimation is TRUE?
- A. It works for every provider in the registry.
- B. It replaces policy checks.
- C. It runs after apply, using the actual bill.
- D. It estimates the monthly cost change of supported resources on major clouds such as AWS, Azure and GCP, after plan and before apply.

### Q45 — select ONE
What does `terraform output -json` do?
- A. Prints all root module outputs from state in JSON format.
- B. Creates resources from outputs.
- C. Destroys the outputs.
- D. Works only with HCP Terraform.

### Q46 — select ONE
A child module needs the root's aliased provider configuration `aws.east`. How does it get it?
- A. It is inherited automatically, just like the default provider.
- B. The module block passes it: `providers = { aws = aws.east }`.
- C. The child declares its own `provider` block with the same alias.
- D. Through a `depends_on` on the provider.

---

**Stop.** Mark your answers with [answer-keys.md](answer-keys.md) and record the score in [SCORECARD.md](../SCORECARD.md). Log every miss in [mistakes/error-log.md](../mistakes/error-log.md).
