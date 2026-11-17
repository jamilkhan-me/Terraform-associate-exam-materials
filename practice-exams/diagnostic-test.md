# Day 1 Diagnostic Test

**Purpose:** measure your starting point *before* teaching. A low score is expected and useful.
**Questions:** 30 · **Time:** 35 minutes · **Closed book** · Do **not** open `answer-keys.md`.

**How to answer** — write your answers on paper or in a text file in this format:

```
1. B (3)
2. A,C (2)
...
```
The number in brackets is your confidence: **3** = sure, **2** = unsure, **1** = guess.
Confidence is not optional — it reveals hidden misconceptions.

Terraform version assumed: **1.5+** (behaviour of current Terraform CLI).

---

### Q1 — select ONE
Which statement best describes how Terraform's *declarative* approach works?

- A. You write an ordered list of API calls and Terraform executes them top to bottom.
- B. Terraform logs into each server and runs shell scripts to configure it.
- C. You describe the desired end state; Terraform compares it to the current state and works out the actions needed.
- D. You must specify the exact order in which every resource is created.

### Q2 — select TWO
Which are genuine benefits of managing infrastructure as code?

- A. Infrastructure changes can be version-controlled and peer-reviewed.
- B. It removes the need for cloud provider APIs.
- C. Environments can be reproduced consistently from the same definitions.
- D. It guarantees that deployments can never fail.
- E. It eliminates the need to store any information about deployed resources.

### Q3 — select TWO
Which actions does `terraform init` perform?

- A. Downloads and installs the providers required by the configuration.
- B. Creates the resources defined in the configuration.
- C. Initializes the backend used to store state.
- D. Rewrites configuration files into canonical format.
- E. Verifies that your cloud credentials are valid by calling the provider API.

### Q4 — select ONE
Which file records the exact provider versions (and checksums) Terraform selected, so that future runs use the same versions?

- A. `.terraform.lock.hcl`
- B. `terraform.tfstate`
- C. `versions.tf`
- D. `terraform.tfvars`

### Q5 — select ONE
What is the **primary** purpose of Terraform state?

- A. To store cloud provider credentials securely.
- B. To keep a history of every CLI command that was run.
- C. To cache provider plugin binaries between runs.
- D. To map resources in the configuration to real-world objects and track their metadata.

### Q6 — select ONE
A teammate wants to see exactly what Terraform *would* change, without changing any infrastructure. Which command should they run?

- A. `terraform apply -auto-approve`
- B. `terraform plan`
- C. `terraform validate`
- D. `terraform fmt`

### Q7 — select ONE
What does `terraform validate` check?

- A. That the configuration is formatted in canonical style.
- B. That every resource in the configuration already exists in the cloud account.
- C. That the configuration is syntactically valid and internally consistent, without contacting remote services or real infrastructure.
- D. That the state file matches real infrastructure.

### Q8 — True / False
`terraform fmt` may change the behaviour of a configuration because it reorders arguments alphabetically.

- A. True
- B. False

### Q9 — select ONE
You ran `terraform plan -out=tfplan`. What happens when you run `terraform apply tfplan`?

- A. Terraform applies the saved plan without asking for approval.
- B. Terraform asks for interactive approval before applying.
- C. Terraform creates a brand-new plan, then asks for approval.
- D. Terraform errors unless you add `-auto-approve`.

### Q10 — select ONE
Which statement about `data` blocks is correct?

- A. A data block creates the object if it does not already exist.
- B. Data blocks can only be used with the AWS provider.
- C. A data block is the only way to declare a resource that can be destroyed.
- D. A data block reads information about an existing object; Terraform does not create, update, or destroy that object.

### Q11 — select ONE
Given:
```hcl
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
}
```
Which expression correctly references the `id` attribute of this data source?

- A. `aws_ami.ubuntu.id`
- B. `data.aws_ami.ubuntu.id`
- C. `data.ubuntu.id`
- D. `var.aws_ami.ubuntu.id`

### Q12 — select ONE
A variable is declared:
```hcl
variable "region" {
  default = "us-east-1"
}
```
`terraform.tfvars` contains `region = "eu-west-1"`, the environment has `TF_VAR_region=ap-south-1`, and you run:
```bash
terraform plan -var="region=us-west-2"
```
Which value does Terraform use?

- A. `us-east-1`
- B. `eu-west-1`
- C. `us-west-2`
- D. `ap-south-1`

### Q13 — select ONE
```hcl
variable "names" {
  default = ["alpha", "bravo", "charlie"]
}

resource "aws_iam_user" "u" {
  count = length(var.names)
  name  = var.names[count.index]
}
```
After applying, you remove `"bravo"` from the list. What will the next plan propose?

- A. Change `aws_iam_user.u[1]` from `bravo` to `charlie` and destroy `aws_iam_user.u[2]`.
- B. Destroy only the `bravo` user; leave the others untouched.
- C. Destroy all three users and create two new ones.
- D. No changes, because the users still exist.

### Q14 — select ONE
`aws_subnet.app` sets `vpc_id = aws_vpc.main.id`. How does Terraform know to create the VPC before the subnet?

- A. Because the VPC block appears earlier in the file.
- B. It doesn't — you must add `depends_on`.
- C. Terraform creates resources in alphabetical order of type.
- D. The reference creates an implicit dependency in the dependency graph.

### Q15 — select ONE
A variable is declared with `sensitive = true`. Which statement is TRUE?

- A. Terraform encrypts the value inside the state file.
- B. The value is redacted in plan/apply CLI output but is still stored in state in plain text.
- C. The variable cannot be referenced by resources.
- D. The value is never written to state.

### Q16 — select ONE
Which construct lets you reject an invalid **input variable value** with a custom error message before any resources are planned?

- A. `lifecycle { ignore_changes = all }`
- B. A `postcondition` inside an `output` block.
- C. A `validation` block inside the `variable` block.
- D. A `provisioner "local-exec"` that exits non-zero.

### Q17 — select ONE
Which built-in function combines two or more **maps** into a single map?

- A. `merge()`
- B. `concat()`
- C. `join()`
- D. `lookup()`

### Q18 — select ONE
For which module source type can you use the `version` argument inside a `module` block?

- A. Local paths such as `./modules/vpc`
- B. Any source — `version` works everywhere
- C. Any Git repository URL
- D. Modules from a Terraform registry (public or private)

### Q19 — select ONE
A child module needs the value of the root module's variable `env`. How does it get it?

- A. Child modules automatically inherit all root variables as `var.env`.
- B. The root module must pass it explicitly as an argument in the `module` block, and the child must declare `variable "env"`.
- C. The child reads it with `terraform.env`.
- D. Through a `global` block.

### Q20 — select ONE
A module is called with `module "network" { ... }` and declares `output "vpc_id"`. How do you reference that output in the root module?

- A. `network.vpc_id`
- B. `module.network.outputs.vpc_id`
- C. `module.network.vpc_id`
- D. `output.network.vpc_id`

### Q21 — select ONE
If a configuration has no `backend` or `cloud` block, where is state stored?

- A. In a local file named `terraform.tfstate` in the working directory.
- B. In HCP Terraform automatically.
- C. In memory only; it is discarded after each run.
- D. In `.terraform/terraform.tfstate` only.

### Q22 — select ONE
An apply crashed and left a state lock in place. You have confirmed nobody else is running Terraform. Which command releases the lock?

- A. `terraform state unlock`
- B. `terraform apply -lock=false -unlock`
- C. `terraform init -unlock`
- D. `terraform force-unlock LOCK_ID`

### Q23 — select ONE
Someone changed a resource's tags manually in the cloud console. You want Terraform **state** to reflect reality, without proposing any change to the infrastructure. What should you run?

- A. `terraform plan -destroy`
- B. `terraform apply -refresh-only`
- C. `terraform state push`
- D. `terraform fmt -check`

### Q24 — select ONE
What happens when you run `terraform state rm aws_s3_bucket.logs`?

- A. The bucket is deleted from AWS and removed from state.
- B. The resource block is removed from the configuration files.
- C. The bucket is removed from state only; it still exists in AWS and Terraform no longer manages it.
- D. The bucket is marked to be replaced on the next apply.

### Q25 — select ONE
Using an `import` block (Terraform 1.5+), which statement is correct?

- A. You can ask Terraform to generate configuration for the imported resource with `terraform plan -generate-config-out=generated.tf`.
- B. Terraform always writes the resource block into your `.tf` files automatically.
- C. Importing destroys the existing object and recreates it under Terraform management.
- D. Import blocks only work with HCP Terraform.

### Q26 — select ONE
Which environment variable enables detailed Terraform logging?

- A. `TF_DEBUG`
- B. `TF_VAR_log`
- C. `TERRAFORM_VERBOSE`
- D. `TF_LOG`

### Q27 — select ONE
Which command displays all attributes of a single resource as recorded in state?

- A. `terraform show -resource=aws_instance.web`
- B. `terraform state show aws_instance.web`
- C. `terraform state list aws_instance.web`
- D. `terraform output aws_instance.web`

### Q28 — select TWO
Which are features of HCP Terraform?

- A. Remote state storage with locking and versioned state history.
- B. Policy-as-code enforcement (Sentinel / OPA) on runs.
- C. It removes the need for providers.
- D. It runs every plan only on the user's laptop.
- E. It automatically rewrites invalid HCL into valid HCL.

### Q29 — select ONE
In an HCP Terraform run, when are policy checks evaluated?

- A. Before the plan is generated.
- B. After the apply completes.
- C. After the plan, before the apply.
- D. Only when a workspace is deleted.

### Q30 — select ONE
Which statement about **Terraform CLI workspaces** using the local backend is TRUE?

- A. Each non-default workspace has its own state file, stored under `terraform.tfstate.d/<workspace>/`.
- B. Each workspace uses a separate copy of the configuration files.
- C. The `default` workspace can be deleted once another workspace exists.
- D. Workspaces provide strong isolation of credentials and access control.

---
**Stop.** Mark your answers with [answer-keys.md](answer-keys.md#diagnostic-test) → *Diagnostic Test*, then fill in
[SCORECARD.md](../SCORECARD.md) (score, per-domain, and confidence calibration).
