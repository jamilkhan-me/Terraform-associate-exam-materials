# Day 4 — Providers, Resources, Data Sources, and Lifecycle

**Objectives covered:** 2a, 2b, 2c, 4a, 4f, 4g, plus count/for_each, provisioners, drift
**Labs:** [Lab 03](../labs/lab-03/README.md), [Lab 04](../labs/lab-04/README.md), [Lab 05](../labs/lab-05/README.md)

---

## A. Learning objectives

1. Write `required_providers` with correct source addresses and version constraints; decode every constraint operator.
2. Explain the dependency lock file: what it records, when it changes, why to commit it.
3. Configure multiple providers and multiple configurations of one provider (`alias`).
4. Address resources: single, `count`, `for_each`, data, module-nested.
5. Choose `count` vs `for_each` and predict plan changes when collections change.
6. Use every `lifecycle` argument: `create_before_destroy`, `prevent_destroy`, `ignore_changes`, `replace_triggered_by`, `precondition`, `postcondition`.
7. Use `check` blocks and explain how they differ from pre/postconditions.
8. Explain provisioners, their types, failure behaviour, and why they're a last resort.
9. Predict update-in-place vs replacement and explain that the provider schema decides.

---

## B. Plain-English explanation

A **provider** is a plugin that teaches Terraform an API. You declare which providers you
need (and which versions), configure them (region, credentials), and then declare
**resources** (things to manage) and **data sources** (things to look up).

When you need several similar resources, `count` stamps out N numbered copies; `for_each`
stamps out one copy per key of a map/set. **Lifecycle** settings tweak *how* Terraform
replaces, protects, or ignores changes on a resource.

---

## C. Technical deep dive

### C1. Provider requirements & versions

```hcl
terraform {
  required_version = ">= 1.6, < 2.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"      # local name "aws" → registry.terraform.io/hashicorp/aws
      version = "~> 5.40"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0"
    }
  }
}
```

| Constraint | Meaning |
|---|---|
| `= 5.40.0` or `5.40.0` | Exactly this version |
| `!= 5.41.0` | Anything except |
| `>= 5.40` | At least |
| `> 5.40, < 6.0` | Comma = AND |
| `~> 5.40` | `>= 5.40, < 6.0` (rightmost component may increment) |
| `~> 5.40.0` | `>= 5.40.0, < 5.41.0` (only patch increments) |

Rule for `~>` (pessimistic constraint): only the **right-most specified** component may
increase. Two parts → minor may increase; three parts → only patch may increase. The
single-component form (`~> 5`) is an edge case I'm not confident the exam uses — focus on
the two- and three-part forms.

Best practice: in **root modules**, constrain providers tightly enough to avoid surprise
majors (`~> 5.40`); in **reusable child modules**, specify a **minimum** (`>= 5.0`) and let
the root decide. `required_version` constrains the **CLI**, not providers.

If `source` is omitted, Terraform assumes `hashicorp/<local name>` — works for `aws`, fails
for third-party providers (e.g. `datadog` must be `DataDog/datadog`).

### C2. Dependency lock file `.terraform.lock.hcl`

```hcl
provider "registry.terraform.io/hashicorp/aws" {
  version     = "5.42.0"
  constraints = "~> 5.40"
  hashes = [
    "h1:abc...",
    "zh:def...",
  ]
}
```
- Created/updated by `terraform init`; respected on every later `init` (same version chosen
  even if newer exist) unless `init -upgrade`.
- Records **providers only**, not modules, not the Terraform CLI version.
- Hashes verify downloaded packages; multi-platform hashes via `terraform providers lock`.
- **Commit to version control** so every teammate & CI uses identical provider builds.
- If a constraint changes so the locked version no longer satisfies it, `init` errors and
  tells you to run `init -upgrade`.

### C3. Provider configuration, aliases, multiple providers

```hcl
provider "aws" {               # default configuration
  region = "eu-west-2"
}

provider "aws" {               # alternate configuration
  alias  = "us_east"
  region = "us-east-1"
}

resource "aws_acm_certificate" "cdn" {
  provider          = aws.us_east     # CloudFront certs must be in us-east-1
  domain_name       = "example.com"
  validation_method = "DNS"
}

resource "aws_s3_bucket" "site" {      # no provider arg → default aws
  bucket = "jk-site"
}
```

- You met this exact need in your CloudFront project (ACM certificate in us-east-1).
- Resources choose a provider by **type prefix** (`aws_…` → `aws`) unless `provider =` overrides.
- Passing aliased providers into modules: `providers = { aws = aws.us_east }` (Day 6).
- Credentials: never hard-code in `provider` blocks. Use env vars (`AWS_PROFILE`,
  `AWS_ACCESS_KEY_ID`), shared credentials, instance/role credentials, OIDC (your GitHub
  Actions setup), or HCP Terraform dynamic credentials.
- Provider blocks can't use values only known after apply in a single run (e.g. a cluster
  endpoint of a cluster being created) without issues — a classic EKS gotcha.

Multiple providers in one config (2c):
```hcl
resource "aws_route53_record" "www" { ... }
resource "github_repository" "site" { name = "site" }
resource "random_id" "suffix" { byte_length = 4 }
```

### C4. Resource addressing

| Form | Example |
|---|---|
| Single | `aws_instance.web` |
| count instance | `aws_instance.web[0]` |
| for_each instance | `aws_instance.web["api"]` |
| Whole collection | `aws_instance.web` (all instances) |
| Data source | `data.aws_ami.ubuntu` |
| In a module | `module.network.aws_subnet.private["a"]` |
| Nested module | `module.app.module.db.aws_db_instance.this` |

Shell quoting: `terraform state show 'aws_instance.web["api"]'`.

### C5. `count` vs `for_each`

```hcl
# count: identical-ish copies, indexed
resource "aws_instance" "worker" {
  count         = 3
  ami           = var.ami
  instance_type = "t3.micro"
  tags          = { Name = "worker-${count.index}" }
}

# for_each over a set of strings
resource "aws_iam_user" "u" {
  for_each = toset(["alice", "bob"])
  name     = each.key                 # each.value == each.key for sets
}

# for_each over a map
resource "aws_s3_bucket" "b" {
  for_each = {
    logs   = "private"
    assets = "public-read"
  }
  bucket = "jk-${each.key}"
  tags   = { acl = each.value }
}
```

| | `count` | `for_each` |
|---|---|---|
| Accepts | whole number | map, or set of strings |
| Instance key | integer index `[0]` | string key `["alice"]` |
| Reference inside | `count.index` | `each.key`, `each.value` |
| Remove a middle element | **shifts indices → unintended updates/destroys** | only that key is destroyed |
| Good for | N identical copies, on/off toggle (`count = var.x ? 1 : 0`) | distinct items with stable identities |
| Both in one block? | **Not allowed** | |
| Values must be known at plan? | count value yes | keys yes (values may be unknown) |

`for_each` errors you will see:
- *"The given "for_each" argument value is unsuitable: … list of string"* → wrap with `toset()`.
- *"…keys that cannot be determined until apply"* → keys derived from resource attributes
  only known after apply (e.g. generated IDs). Use static keys.

Referencing collections: `aws_instance.worker[*].id` (count) and
`[for u in aws_iam_user.u : u.arn]` or `values(aws_iam_user.u)[*].arn` (for_each).

Migrating from `count` to `for_each` changes addresses → use `moved` blocks (Day 5) to
avoid destroy/recreate.

### C6. Lifecycle meta-argument

```hcl
resource "aws_launch_template" "app" {
  # ...
  lifecycle {
    create_before_destroy = true
    prevent_destroy       = false
    ignore_changes        = [tags["LastDeployedBy"], description]
    replace_triggered_by  = [terraform_data.app_version]

    precondition {
      condition     = data.aws_ami.app.architecture == "x86_64"
      error_message = "AMI must be x86_64."
    }
    postcondition {
      condition     = self.latest_version > 0
      error_message = "Launch template has no versions."
    }
  }
}
```

| Setting | Effect | Gotchas |
|---|---|---|
| `create_before_destroy` | On replacement: create new first, then destroy old (`+/-`). Reduces downtime | New and old coexist briefly → unique names may collide (use `name_prefix`). Propagates to dependencies |
| `prevent_destroy` | Any plan that would destroy this resource **errors** | Doesn't help if you delete the resource block (the lifecycle goes with it). Doesn't stop console deletion |
| `ignore_changes` | Ignore differences in listed attributes when planning updates | `all` ignores every attribute. Used when something else manages a field (autoscaling `desired_count`, tags added by other tools) |
| `replace_triggered_by` (1.2+) | Replace this resource when referenced resources/attributes change | References to managed resources (or `terraform_data`) only |
| `precondition` | Checked **before** evaluating the resource's planned change; failure = error | Use for assumptions about inputs/data |
| `postcondition` | Checked **after** (plan or apply, once values are known); can use `self` | Use for guarantees about results |

Lifecycle values must be **static literals** — no variables (`prevent_destroy = var.x` is an error).

### C7. Custom conditions and `check` blocks (objective 4g)

| Mechanism | Where | When evaluated | On failure |
|---|---|---|---|
| `validation` | `variable` block | plan, before anything | **Error**, stops |
| `precondition` | `lifecycle` of resource/data; `output` | plan/apply, before the object | **Error**, stops |
| `postcondition` | `lifecycle` of resource/data | after object planned/applied | **Error**, stops (dependents blocked) |
| `check` block (1.5+) | top-level | end of plan and apply | **Warning** only; run continues |

```hcl
check "site_up" {
  data "http" "site" {               # scoped data source, only visible inside the check
    url = "https://example.com/health"
  }
  assert {
    condition     = data.http.site.status_code == 200
    error_message = "Health endpoint not returning 200."
  }
}
```
`check` blocks are for **continuous validation** — in HCP Terraform, health assessments
can evaluate them on a schedule.

### C8. Provisioners (last resort)

```hcl
resource "aws_instance" "web" {
  # ...
  provisioner "remote-exec" {
    inline = ["sudo systemctl start nginx"]
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip          # must use self, not aws_instance.web
    }
  }

  provisioner "local-exec" {
    command = "echo ${self.private_ip} >> inventory.txt"   # runs on the machine running Terraform
  }

  provisioner "local-exec" {
    when       = destroy                   # destroy-time provisioner
    command    = "echo destroyed"
    on_failure = continue                  # default is fail
  }
}
```

| Type | Runs where |
|---|---|
| `local-exec` | Machine running Terraform (your laptop / CI runner / HCP worker) |
| `remote-exec` | On the resource, over SSH/WinRM (`connection` block) |
| `file` | Copies files to the resource over SSH/WinRM |

Behaviour:
- Creation-time provisioners run **only when the resource is created**, not on updates.
- If a creation-time provisioner fails, the resource is marked **tainted** → replaced next apply (default `on_failure = fail`).
- Destroy-time provisioners run before destroy; they don't run if the resource block is removed and `create_before_destroy` complicates them.
- Terraform cannot model what provisioners do — not in plan, not in state.
- **Prefer**: `user_data`/cloud-init, pre-baked images (Packer), configuration management, native provider resources.
- For running a provisioner with no "real" resource: `terraform_data` (successor to `null_resource`).

### C9. Update in place vs replace — who decides?

The **provider schema** marks some attributes as "ForceNew". Changing those forces
replacement; others update in place. Terraform core just follows the schema.

| Change (AWS examples — provider-specific!) | Typical result |
|---|---|
| `aws_instance.instance_type` | update in place (instance stopped/started by provider) |
| `aws_instance.ami` | replace |
| `aws_s3_bucket.bucket` (name) | replace |
| tags on most resources | update in place |
| `aws_db_instance.engine` major change / `identifier` | replace (identifier) — read the plan! |

Exam rule: **you can't know from Terraform core alone**; read the plan's
`# forces replacement` annotation.

### C10. Drift

Drift = real infrastructure differs from state/config because of out-of-band changes.

```
1. Change made in console             reality ≠ state
2. terraform plan                      refresh notices → "Objects have changed outside of Terraform"
                                       and proposes to revert reality to config
3. Choose:
   a) apply           → overwrite reality with config (enforce code)
   b) update config to match, then plan shows no changes (accept change into code)
   c) apply -refresh-only → accept reality into state only (record it)
   d) ignore_changes  → permanently ignore that attribute
```
If a managed object was **deleted** out-of-band, refresh removes it from state and plan
proposes to **create** it again.

---

## D. Why it matters

The `count`-index-shift bug destroys real resources in production. `create_before_destroy`
is how you avoid downtime on replacements (your ALB target groups, launch templates).
`prevent_destroy` protects RDS. Provider version pinning keeps CI reproducible. The exam
loves "predict the plan" and "which lifecycle option" questions.

---

## E. Syntax quick reference

```hcl
resource "TYPE" "NAME" {
  count      = N                        # OR
  for_each   = map_or_set
  provider   = PROVIDER.ALIAS
  depends_on = [OTHER.RESOURCE]
  lifecycle {
    create_before_destroy = bool
    prevent_destroy       = bool
    ignore_changes        = [attr, ...] | all
    replace_triggered_by  = [resource.or.attribute]
    precondition  { condition = bool  error_message = string }
    postcondition { condition = bool  error_message = string }
  }
  provisioner "local-exec" { command = "..." }
}
```
Meta-arguments (available on every resource): `count`, `for_each`, `provider`,
`depends_on`, `lifecycle` (+ `provisioner`/`connection` blocks). Modules support
`count`, `for_each`, `providers`, `depends_on` (not `lifecycle`).

---

## F. Worked example — predict the plans

```hcl
variable "envs" { default = ["dev", "test", "prod"] }

resource "terraform_data" "by_count" {
  count = length(var.envs)
  input = var.envs[count.index]
}

resource "terraform_data" "by_each" {
  for_each = toset(var.envs)
  input    = each.key
}
```
Applied. Now change `envs` to `["dev", "prod"]`. **Predict both plans.**

<details><summary>Answer</summary>

`by_count`:
```
  # terraform_data.by_count[1] will be updated in-place
  ~ input  = "test" -> "prod"
  # terraform_data.by_count[2] will be destroyed
```
`by_each`:
```
  # terraform_data.by_each["test"] will be destroyed
```
Plan: 0 to add, 1 to change, 2 to destroy. `for_each` touched only what you removed.
(`terraform_data`'s `input` updates in place; an AWS resource whose identity attribute is
ForceNew would be *replaced* at index 1 — far worse.)
</details>

---

## G. Visual — replacement ordering

```
Default replacement (-/+)                 create_before_destroy (+/-)
time ─────────────────────►               time ─────────────────────►
[old]███████ destroy                      [old]█████████████████ destroy
                [new]  create ██████      [new]     create ███████████
        ▲ gap: downtime                           ▲ overlap: no gap, but
                                                    names must not collide
```

---

## H. Common misconceptions

| # | Misconception | Reality |
|---|---|---|
| 1 | "The lock file pins modules too." | Providers only. |
| 2 | "`~> 1.2.0` allows 1.3.0." | No: `>= 1.2.0, < 1.3.0`. |
| 3 | "`prevent_destroy` protects against deleting the resource block." | Removing the block removes the protection; Terraform then plans to destroy. |
| 4 | "`ignore_changes` stops Terraform from creating the resource." | It only ignores diffs on listed attributes during update planning. |
| 5 | "Provisioners run on every apply." | Creation-time provisioners run once, at creation. |
| 6 | "`for_each` accepts a list." | It needs a map or set of strings — `toset()` the list. |
| 7 | "`check` failures stop the apply." | They are warnings. |
| 8 | "Terraform decides whether a change replaces." | The provider schema decides. |
| 9 | "You can use variables in `lifecycle`." | Lifecycle args must be literal values. |
| 10 | "`provider` meta-arg takes a string." | It takes a bare reference: `provider = aws.us_east`. |

---

## I. Exam traps
- Question gives `version = "~> 3.1"` and asks if 3.9 is allowed (yes) / 4.0 (no).
- "Which file should be committed?" → `.terraform.lock.hcl` yes; `.terraform/` no; `terraform.tfstate` no (use a remote backend).
- "Which option avoids downtime when a resource must be replaced?" → `create_before_destroy`.
- "An autoscaler changes desired_count; Terraform keeps reverting it" → `ignore_changes`.
- "Force replacement when the app version changes" → `replace_triggered_by` (or `-replace` one-off).
- Provisioner failure → resource **tainted**, not rolled back.

---

## J. Active recall
1. What does `~> 2.7.1` permit?
2. What three things does the lock file record per provider?
3. When would you choose `count` over `for_each`?
4. Difference between precondition and check block?
5. What happens if a `remote-exec` provisioner fails during creation?
6. Meta-arguments available on module blocks?

<details><summary>Answers</summary>

1. `>= 2.7.1, < 2.8.0`.
2. Selected version, the constraints, the package hashes.
3. Identical copies or an on/off toggle (`count = cond ? 1 : 0`).
4. Precondition failure is an error that halts; a check block assertion failure is a warning.
5. The resource is marked tainted and will be replaced on the next apply (default `on_failure = fail`).
6. `count`, `for_each`, `providers`, `depends_on` (plus `source`, `version`).
</details>

---

## K. Practice exercises

**K1 — Predict.** A resource has `lifecycle { prevent_destroy = true }`. You change its
name argument, which forces replacement. What happens on `plan`?

**K2 — Fix.**
```hcl
resource "aws_instance" "x" {
  count    = 2
  for_each = toset(["a", "b"])
}
```

**K3 — Write** a provider config so that `aws_s3_bucket.dr` is created in `eu-west-1` while
everything else defaults to `eu-west-2`.

**K4 — Scenario.** ECS service `desired_count` is changed by Application Auto Scaling.
Every plan wants to set it back to 2. What do you add?

**K5 — Interpret.** Plan shows:
```
-/+ resource "aws_instance" "web" {
      ~ ami = "ami-111" -> "ami-222" # forces replacement
```
What will happen, in what order, and how could you reverse the order?

<details><summary>Answers</summary>

**K1.** Plan errors: "Instance cannot be destroyed … lifecycle.prevent_destroy is set".
Nothing changes. To proceed you'd have to remove/flip the setting deliberately.

**K2.** `count` and `for_each` cannot both be set. Pick one.

**K3.**
```hcl
provider "aws" { region = "eu-west-2" }
provider "aws" {
  alias  = "ireland"
  region = "eu-west-1"
}
resource "aws_s3_bucket" "dr" {
  provider = aws.ireland
  bucket   = "jk-dr"
}
```

**K4.** `lifecycle { ignore_changes = [desired_count] }`.

**K5.** Destroy old instance, then create new one (downtime). Add
`lifecycle { create_before_destroy = true }` → `+/-`.
</details>

---

## L. Lesson assessment
10 questions: 2 version constraints, 3 count/for_each predictions, 3 lifecycle selection, 1
provisioner, 1 aliases. Pass mark **8/10**.

## M. Summary
- `required_providers` (source + version) · `~>` = pessimistic · lock file = providers, commit it.
- Aliases: `provider "aws" { alias = "x" }` → `provider = aws.x`.
- `count` = index (shift risk) · `for_each` = stable keys (map/set).
- Lifecycle: CBD, prevent_destroy, ignore_changes, replace_triggered_by, pre/postconditions (literals only).
- `check` = warnings; validation/pre/post = errors.
- Provisioners: local-exec/remote-exec/file, creation-time by default, failure taints, last resort.
- Replacement is decided by provider schema (`# forces replacement`).

### Flashcards (Day 4)
| Front | Back |
|---|---|
| `~> 1.4` | `>= 1.4, < 2.0` |
| `~> 1.4.2` | `>= 1.4.2, < 1.5.0` |
| Lock file contains | provider versions, constraints, hashes (no modules) |
| Default provider source if omitted | `hashicorp/<name>` |
| Use alternate provider config | `provider = aws.alias_name` |
| count vs for_each key type | integer vs string |
| Avoid downtime on replace | `create_before_destroy = true` |
| Block destroy of a resource | `prevent_destroy = true` |
| Ignore external changes to an attr | `ignore_changes = [attr]` |
| Replace when another thing changes | `replace_triggered_by = [...]` |
| Failed creation provisioner | resource tainted |
| check block failure | warning |
| Successor to null_resource | `terraform_data` (1.4+) |

## N. Mastery decision
8–10 ✅ · 6–7 ➕ redo F + K1–K5 with new values · ≤5 🔁 re-teach C5, C6.
