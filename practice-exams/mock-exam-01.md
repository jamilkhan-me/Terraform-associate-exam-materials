# Mock Exam 1 — Mid-Course Checkpoint (end of Day 7)

**Questions:** 40 · **Time:** 45 minutes · **Closed book** · Answers in `answer-keys.md` → *Mock Exam 01* (do not open until submitted).
**Scope:** Days 1–7. **Format:** approximation of the real exam style — not official.
Answer format in chat: `1. B (3)` — letter(s) + confidence 1/2/3.

---

### Q1 — select ONE
What is "drift" in Terraform terminology?
- A. A difference between two installed provider versions.
- B. A saved plan file that is older than the current state.
- C. Real infrastructure that no longer matches what the Terraform configuration and state describe, usually due to changes made outside Terraform.
- D. A module whose version constraint is not pinned.

### Q2 — select ONE
Which task is Terraform **primarily** designed for?
- A. Building container images.
- B. Repeatedly installing and patching packages on long-running servers.
- C. Collecting and searching application logs.
- D. Provisioning and managing infrastructure such as networks, databases, and IAM through provider APIs.

### Q3 — select TWO
How does Terraform support multi-cloud and service-agnostic workflows?
- A. The same workflow and language are used regardless of which provider is involved.
- B. A single resource type can be deployed to any cloud without changes.
- C. One configuration can use several providers and reference values between them.
- D. Terraform automatically converts AWS resources into equivalent Azure resources.

### Q4 — select ONE
A configuration declares `random` in `required_providers` and uses a `random_id` resource, but has **no** `provider "random"` block. What happens?
- A. Terraform uses an empty default configuration for the provider, which works because this provider needs no settings.
- B. Terraform errors: every provider requires a provider block.
- C. The `random_id` resource is skipped.
- D. You must use an alias to reference the provider.

### Q5 — select ONE
In `required_providers`, an entry omits the `source` argument. Which source address does Terraform assume?
- A. `registry.terraform.io/community/<local name>`
- B. `registry.terraform.io/hashicorp/<local name>`
- C. The first matching provider in the registry search results
- D. None — `source` is mandatory and init fails

### Q6 — select ONE
Which argument inside a **resource** block selects an alternate (aliased) provider configuration?
- A. `region = aws.west`
- B. `alias = "west"`
- C. `provider = aws.west`
- D. `providers = { aws = aws.west }`

### Q7 — select TWO
Which statements about `.terraform.lock.hcl` are true?
- A. It should be committed to version control.
- B. It records the versions of modules downloaded from the registry.
- C. It is updated when you run `terraform init -upgrade`.
- D. It contains the current state of your resources.
- E. It prevents you from upgrading the Terraform CLI.

### Q8 — select ONE
Which statement about Terraform state is TRUE?
- A. State only exists when using HCP Terraform.
- B. State is optional if all resources are tagged consistently.
- C. State stores a copy of your `.tf` files.
- D. Terraform uses state to determine which real-world objects correspond to the resources in your configuration.

### Q9 — select ONE
You add a new provider to `required_providers`. Which command must run before `terraform plan` will succeed?
- A. `terraform init`
- B. `terraform get`
- C. `terraform providers`
- D. `terraform validate`

### Q10 — select ONE
You saved a plan with `terraform plan -out=release.tfplan`. Which command displays it in human-readable form?
- A. `terraform output release.tfplan`
- B. `terraform show release.tfplan`
- C. `terraform state show release.tfplan`
- D. `terraform plan -in=release.tfplan`

### Q11 — select ONE
Which `terraform plan` option makes the command exit with status `2` when changes are present (useful for drift detection in CI)?
- A. `-check`
- B. `-refresh-only`
- C. `-detailed-exitcode`
- D. `-exit-on-change`

### Q12 — select ONE
Which statement about `terraform apply -refresh-only` is TRUE?
- A. It can only be used with HCP Terraform.
- B. It changes infrastructure back to match the configuration.
- C. It deletes resources that are not in state.
- D. It updates state to match the real infrastructure, without changing any infrastructure.

### Q13 — select TWO
Which commands relate correctly to destroying all resources in a configuration?
- A. `terraform apply -destroy` is equivalent to `terraform destroy`.
- B. `terraform plan -destroy` previews what would be destroyed.
- C. `terraform state rm -all` destroys all resources.
- D. `terraform delete` destroys all resources.

### Q14 — select ONE
By default, `terraform fmt`:
- A. Formats configuration files in the current directory only.
- B. Formats files in the current directory and all subdirectories.
- C. Validates and formats files, failing on invalid references.
- D. Requires `terraform init` to have been run.

### Q15 — select ONE
The constraint is `version = "~> 4.60"`, the lock file has `4.61.0`, and the registry offers `4.67.0` and `5.2.0`. What version is selected after `terraform init -upgrade`?
- A. `4.61.0`
- B. `4.67.0`
- C. `5.2.0`
- D. Init fails because the lock file conflicts

### Q16 — select ONE
What is the value of this expression?
```hcl
[for i, v in ["a", "b", "c"] : "${i}-${v}"]
```
- A. `["a-0", "b-1", "c-2"]`
- B. `{ "0" = "a", "1" = "b", "2" = "c" }`
- C. `["0-a", "1-b", "2-c"]`
- D. An error: `for` cannot bind two symbols over a list

### Q17 — select ONE
Which type constraint describes a map whose values are objects with a string `cidr` and a number `azs`?
- A. `map(tuple([string, number]))`
- B. `object(map({ cidr = string, azs = number }))`
- C. `list(map(string, number))`
- D. `map(object({ cidr = string, azs = number }))`

### Q18 — select ONE
A data source's argument depends on an attribute of a resource that hasn't been created yet. How does the plan treat the data source?
- A. It shows the data source will be read during apply, and dependent values are `(known after apply)`.
- B. It fails; data sources can't depend on resources.
- C. It creates the resource and reads the data source during plan.
- D. It ignores the data source until the next run.

### Q19 — select ONE
A Lambda function must not be created until an IAM policy attachment exists, but none of the function's arguments reference the attachment. What should you add to the function?
- A. `depends_on = ["aws_iam_role_policy_attachment.logs"]`
- B. `depends_on = [aws_iam_role_policy_attachment.logs]`
- C. `lifecycle { create_before_destroy = true }`
- D. Nothing — Terraform creates resources in file order

### Q20 — select ONE
`aws_instance.web` uses `count = 3`. What does `aws_instance.web[*].private_ip` return?
- A. The private IP of the first instance only.
- B. A map keyed by instance ID.
- C. A list of the three private IPs.
- D. An error; splat expressions only work with `for_each`.

### Q21 — select ONE
```hcl
resource "aws_instance" "app" {
  for_each      = { small = "t3.micro", large = "m5.large" }
  instance_type = each.value
  ami           = var.ami
}
```
For the instance with key `"large"`, what are `each.key` and `each.value`?
- A. `0` and `"m5.large"`
- B. `"large"` and `{ large = "m5.large" }`
- C. `"m5.large"` and `"large"`
- D. `"large"` and `"m5.large"`

### Q22 — select ONE
`terraform.tfvars` sets `x = 1`, `x.auto.tfvars` sets `x = 2`, and `TF_VAR_x=3` is exported. You run `terraform plan` with no flags. What is `var.x`?
- A. 2
- B. 1
- C. 3
- D. Terraform prompts because the sources conflict

### Q23 — select ONE
An `output` block's value refers to a variable declared with `sensitive = true`, but the output does not set `sensitive = true`. What happens?
- A. The value is printed in plain text.
- B. Terraform returns an error during planning.
- C. The output is silently omitted.
- D. The value is encrypted in state.

### Q24 — select ONE
You need to generate a variable number of `ingress` nested blocks inside an `aws_security_group` from a list variable. Which construct?
- A. `count` on the `ingress` block
- B. A `for_each` on the security group resource
- C. A `dynamic "ingress"` block
- D. A `for` expression assigned to `ingress =`

### Q25 — select ONE
A resource must be replaced when a ForceNew attribute changes, and the team wants to avoid downtime. Which setting?
- A. `lifecycle { prevent_destroy = true }`
- B. `depends_on = [self]`
- C. `lifecycle { ignore_changes = all }`
- D. `lifecycle { create_before_destroy = true }`

### Q26 — select TWO
Which mechanisms **stop** a plan or apply with an error when their condition is false?
- A. A `validation` block in a variable
- B. An `assert` inside a `check` block
- C. A `precondition` in a resource's `lifecycle` block
- D. The `description` of an output

### Q27 — select ONE
A module is called with `module "web" { for_each = toset(["blue", "green"]) ... }` and has an output `url`. How do you reference the `blue` instance's URL?
- A. `module.web["blue"].url`
- B. `module.web.blue.url`
- C. `module["web"].blue.url`
- D. `module.web.url["blue"]`

### Q28 — select ONE
Which `source` correctly references tag `v1.4.0` of a module in a generic Git repository?
- A. `"git::https://example.com/net.git"` with `version = "v1.4.0"`
- B. `"git::https://example.com/net.git?ref=v1.4.0"`
- C. `"https://example.com/net.git@v1.4.0"`
- D. `"git::https://example.com/net.git#v1.4.0"`

### Q29 — select ONE
Which is a valid **public Terraform Registry** module source?
- A. `"aws/vpc"`
- B. `"./terraform-aws-modules/vpc"`
- C. `"terraform-aws-modules/vpc/aws"`
- D. `"registry:vpc@5.0"`

### Q30 — select ONE
Which meta-argument is **not** supported in a `module` block?
- A. `for_each`
- B. `depends_on`
- C. `providers`
- D. `lifecycle`

### Q31 — select ONE
Which practice is recommended for reusable child modules?
- A. Declare `required_providers` with minimum versions, and let the caller configure providers.
- B. Include a `provider` block with credentials in every module.
- C. Include a `backend` block in each child module.
- D. Pin the exact Terraform CLI patch version in every module.

### Q32 — select ONE
Your backend block is `backend "s3" {}`. How do you supply the bucket name when initialising?
- A. `terraform init -var="bucket=jk-tfstate"`
- B. `terraform init -backend-config="bucket=jk-tfstate"`
- C. Set `TF_VAR_bucket=jk-tfstate`
- D. Add `bucket = var.bucket` to the backend block

### Q33 — select ONE
Which statement about state locking is TRUE?
- A. Locking prevents anyone from running `terraform output`.
- B. Locking is off by default and must be enabled with `-lock=true`.
- C. For backends that support it, Terraform automatically locks state for operations that could write state.
- D. Every backend supports locking.

### Q34 — select ONE
You replaced the default local backend with an `s3` backend block and want your existing state copied to S3. Which command?
- A. `terraform init -reconfigure`
- B. `terraform apply -backend=s3`
- C. `terraform state push s3`
- D. `terraform init -migrate-state`

### Q35 — select TWO
You renamed `aws_lb.main` to `aws_lb.public` in the configuration. Which actions prevent Terraform from destroying and recreating the load balancer?
- A. Add a `moved` block from `aws_lb.main` to `aws_lb.public`.
- B. Run `terraform state mv aws_lb.main aws_lb.public`.
- C. Run `terraform apply -replace=aws_lb.public`.
- D. Add `lifecycle { ignore_changes = all }`.
- E. Run `terraform import aws_lb.main`.

### Q36 — select ONE
With the local backend, where is the state for a CLI workspace named `staging` stored?
- A. `terraform.tfstate.d/staging/terraform.tfstate`
- B. `terraform.tfstate`
- C. `.terraform/staging.tfstate`
- D. `staging/terraform.tfstate`

### Q37 — select ONE
You run `terraform import aws_instance.web i-0abc123`, but the configuration has no `aws_instance.web` block. What happens?
- A. Terraform imports the instance and generates the resource block.
- B. Terraform errors because the resource address does not exist in the configuration.
- C. Terraform imports the instance into a temporary address.
- D. Terraform destroys the instance.

### Q38 — select ONE
Which `TF_LOG` level produces the most detailed output?
- A. `DEBUG`
- B. `INFO`
- C. `TRACE`
- D. `VERBOSE`

### Q39 — select ONE
Which HCP Terraform workflow starts runs automatically when commits are pushed to a linked repository branch?
- A. CLI-driven workflow
- B. Local execution mode
- C. API-driven workflow
- D. VCS-driven workflow

### Q40 — select ONE
What is a **speculative plan** in HCP Terraform?
- A. A plan-only run, for example on a pull request, that cannot be applied.
- B. A plan that is applied automatically if policies pass.
- C. A plan generated by cost estimation.
- D. A plan that runs on the user's laptop only.

---
**Stop.** Submit answers in chat.
