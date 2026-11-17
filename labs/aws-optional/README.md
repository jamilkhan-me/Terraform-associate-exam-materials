# Optional AWS Labs (real cloud)

These are the hands-on exercises from the original 15-day notes, collected in one place and
matched to the daily lessons. They are **optional**: the offline labs (`lab-01` to `lab-12`)
cover every exam objective without a cloud account. Do these if you want to see real
provider behaviour: real IDs in state, real drift, real `# forces replacement`.

> ⚠ **Safety and cost rules**
> - Use a **sandbox/personal account**, never a work or production account, and never point
>   these labs at an existing project's state.
> - Use an **IAM user or role, not root**. Check who you are with `aws sts get-caller-identity`.
> - Everything here is free-tier-friendly (S3 buckets, a security group; A4 optionally uses one
>   `t3.micro` instance). **Run `terraform destroy` at the end of every session.**
> - Work in a fresh folder such as `~/tf-aws-labs/`, not inside this repository.

**Prerequisites:** Terraform 1.10+ (1.12 matches the exam), AWS CLI configured
(`aws configure` or `AWS_PROFILE`), an editor with the HashiCorp Terraform extension.

Shared starting point (`versions.tf`), used by every lab below:

```hcl
terraform {
  required_version = ">= 1.10"
  required_providers {
    aws    = { source = "hashicorp/aws",    version = "~> 5.0" }
    random = { source = "hashicorp/random", version = "~> 3.6" }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "random_id" "suffix" {
  byte_length = 4
}
```

---

## A1 — First real workflow (Days 1-3)

1. `terraform init`. Find the two new artifacts: `.terraform/` (never commit) and
   `.terraform.lock.hcl` (commit). Open the lock file and read it.
2. Add a bucket:
   ```hcl
   resource "aws_s3_bucket" "demo" {
     bucket = "tf-assoc-demo-${random_id.suffix.hex}"
   }
   ```
3. `terraform plan` and read every line, not just the summary.
4. `terraform apply`. Open `terraform.tfstate` and find the bucket's real ARN. This is
   "state maps config to reality" seen with your own eyes.
5. `terraform apply` again: **"No changes"** is idempotency.
6. Add `tags = { Env = "lab" }` and plan. Is it `~` (in place) or `-/+` (replace)? Now change
   the `bucket` name and plan again (don't apply). Which attribute **forces replacement**?
7. Add a resource that references the bucket:
   ```hcl
   resource "aws_s3_bucket_versioning" "demo" {
     bucket = aws_s3_bucket.demo.id
     versioning_configuration { status = "Enabled" }
   }
   ```
   Confirm in the apply output that the bucket is created first, with no `depends_on`
   anywhere (an implicit dependency).
8. `terraform destroy`.

**The concept this proves:** config ≠ state ≠ reality, idempotency, update vs replace,
implicit ordering.

## A2 — fmt, validate, saved plans and drift (Day 3)

1. Mess up the indentation in `main.tf`, then run `terraform fmt -diff` and watch what it fixes.
   Run `terraform fmt -check` and note the exit code (`echo $?`).
2. Typo a resource type (`aws_s3_buckett`) and run `terraform validate`. Read the error, fix it.
   Note that `validate` needed no credentials.
3. `terraform plan -out=tfplan`, then `terraform show tfplan`, then `terraform apply tfplan`:
   no confirmation prompt, because the plan was already reviewed.
4. **Drift:** change a tag on the bucket in the AWS console. Run `terraform plan -refresh-only`:
   it reports the drift without proposing to change the bucket. Then run a normal
   `terraform plan`: it proposes to put the tag back. Choose: `apply` (enforce code),
   edit the config (accept the change), or `apply -refresh-only` (record reality in state).
5. `terraform apply -replace=aws_s3_bucket_versioning.demo` and read the plan symbol.
6. `terraform destroy`.

## A3 — Variables, outputs and precedence (Day 2)

```hcl
variable "name_prefix" {
  type    = string
  default = "tf-assoc"

  validation {
    condition     = length(var.name_prefix) >= 3 && length(var.name_prefix) <= 20
    error_message = "name_prefix must be 3-20 characters."
  }
}

resource "aws_s3_bucket" "demo" {
  bucket = "${var.name_prefix}-${random_id.suffix.hex}"
}

output "bucket_arn" {
  value = aws_s3_bucket.demo.arn
}
```

Plan four times and watch which value wins each time:
1. Default only.
2. `TF_VAR_name_prefix=fromenv terraform plan`
3. Add `terraform.tfvars` with `name_prefix = "fromfile"`, keep the env var set.
4. `terraform plan -var="name_prefix=fromcli"`

Expected winners: default → env → tfvars → CLI. Then try `-var="name_prefix=ab"` and watch the
validation block stop the plan before anything else runs. After an apply, try
`terraform output`, `terraform output -raw bucket_arn` and `terraform output -json`.

In `terraform console`, try: `merge({a=1},{b=2})`, `lookup({x="y"}, "x", "default")`,
`[for s in ["a","b"] : upper(s)]`, `true ? "yes" : "no"`, `cidrsubnet("10.0.0.0/16", 8, 2)`.

## A4 — Data sources, dependencies and lifecycle (Day 4)

```hcl
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "web" {
  name_prefix = "tf-assoc-web-"
  vpc_id      = data.aws_vpc.default.id

  dynamic "ingress" {
    for_each = [80, 443]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

variable "buckets" {
  type    = map(string)
  default = { logs = "private", assets = "private" }
}

resource "aws_s3_bucket" "multi" {
  for_each = var.buckets
  bucket   = "tf-assoc-${each.key}-${random_id.suffix.hex}"
  tags     = { Visibility = each.value }

  lifecycle {
    prevent_destroy = true
    postcondition {
      condition     = contains(keys(self.tags), "Visibility")
      error_message = "Bucket must have a Visibility tag."
    }
  }
}
```

1. Plan: the data sources are read during plan and show no action; the security group gets
   a `+`. Look at the dynamic `ingress` blocks in the plan.
2. Apply. Then remove `assets` from `var.buckets` and plan: **only that key** is affected.
   With `prevent_destroy`, the plan **errors**. Remove `prevent_destroy`, apply, then destroy.
3. *(Optional, small cost)* Add an `aws_instance` (`t3.micro`, `ami = data.aws_ami.al2023.id`,
   `vpc_security_group_ids = [aws_security_group.web.id]`). Watch the implicit ordering,
   then change the AMI filter to force replacement and add
   `lifecycle { create_before_destroy = true }` to see `+/-` instead of `-/+`.
   **Destroy it the same session.**
4. `terraform graph | dot -Tpng > graph.png` (if Graphviz is installed).

## A5 — Your first module (Day 6)

Create `modules/s3-bucket/` with `variables.tf` (`name_prefix`), `main.tf` (the bucket) and
`outputs.tf` (`bucket_arn`). Call it from the root:

```hcl
module "logs_bucket" {
  source      = "./modules/s3-bucket"
  name_prefix = "tf-assoc-logs"
}

output "logs_bucket_arn" {
  value = module.logs_bucket.bucket_arn
}
```

1. `terraform init` (modules need init too), then apply.
2. Try to reference `module.logs_bucket.aws_s3_bucket.this.arn` in the root: it fails, because
   only outputs cross the boundary.
3. Notice the child uses the root's default `aws` provider **without** you passing it
   (default providers are inherited). Add an aliased provider `aws.west` and pass it with
   `providers = { aws = aws.west }` to put the bucket in another region.
4. Add a small registry module with a pinned version (e.g.
   `terraform-aws-modules/s3-bucket/aws`, `version = "~> 4.0"`), run `init`, and look inside
   `.terraform/modules/`.

## A6 — Remote state, drift and state commands (Day 5)

1. In a **separate** folder, create a state bucket (versioning + encryption enabled). Then
   in your lab folder add:
   ```hcl
   terraform {
     backend "s3" {
       bucket       = "YOUR-STATE-BUCKET"
       key          = "labs/terraform.tfstate"
       region       = "us-east-1"
       encrypt      = true
       use_lockfile = true      # S3-native locking, Terraform 1.10+
     }
   }
   ```
   Run `terraform init -migrate-state` and answer `yes`. Verify with `terraform state list`
   and `terraform plan` (expect **No changes**).
2. Open two terminals and run `terraform apply` in both: the second gets a lock error.
   Look for the `.tflock` object in the bucket during the first apply.
3. Rename `aws_s3_bucket.demo` to `aws_s3_bucket.renamed` in config **and** add a `moved`
   block. Plan shows a move, with no destroy. Check the console: same bucket.
4. `terraform state rm aws_s3_bucket_versioning.demo`, then plan: Terraform wants to *create*
   it again. Fix it with an `import` block (`id` = the bucket name).
5. Clean up: `terraform destroy`, then delete the state bucket from its own folder.

## A7 — Import, logging and CLI workspaces (Days 5-6)

1. Create a bucket by hand in the console. Import it the modern way:
   ```hcl
   import {
     to = aws_s3_bucket.manual
     id = "YOUR-MANUAL-BUCKET-NAME"
   }
   ```
   `terraform plan -generate-config-out=generated.tf`, review `generated.tf`, then
   `terraform plan` (expect *1 to import, 0 to add, 0 to change*), then `terraform apply`.
   Inspect with `terraform state show aws_s3_bucket.manual`.
2. Break something (e.g. a wrong region in the provider) and run with
   `TF_LOG=DEBUG TF_LOG_PATH=./debug.log terraform plan`. Find the failing HTTP request in
   the log. Then set only `TF_LOG_PATH` and confirm **no** log is written.
3. `terraform workspace new dev`, then `terraform state list`: empty. Apply, then switch back
   with `terraform workspace select default`: different state. Use `terraform.workspace`
   in a tag. Destroy in **both** workspaces, then `terraform workspace delete dev`.

## A8 — HCP Terraform CLI-driven workflow (Day 7)

1. Create a free account at app.terraform.io: Organization → Project → Workspace
   (CLI-driven).
2. Replace any `backend` block with:
   ```hcl
   terraform {
     cloud {
       organization = "YOUR-ORG"
       workspaces { name = "tf-assoc-lab" }
     }
   }
   ```
3. `terraform login`, `terraform init`, `terraform plan`: watch the run stream from HCP
   Terraform. Your laptop's AWS env vars are **not** available to remote runs; add them
   as workspace (or variable-set) environment variables marked **sensitive**, or set up
   dynamic provider credentials.
4. Explore (read, don't necessarily configure): variable sets, policy sets and enforcement
   levels, run history, state versions, team access.
5. `terraform destroy` (a destroy run in the workspace), then delete the workspace.
