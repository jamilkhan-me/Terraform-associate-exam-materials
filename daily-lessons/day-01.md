# Day 1 — Terraform Fundamentals

**Objectives covered:** 1a, 1b, 1c, 2a, 2b, 2d (intro), 3a, 4a (intro)
**Prerequisite:** complete the [diagnostic test](../practice-exams/diagnostic-test.md) first.
**Lab:** [Lab 01](../labs/lab-01/README.md)

---

## A. Learning objectives

By the end of today you can:

1. Define Infrastructure as Code and list its advantages with concrete examples.
2. Explain declarative vs imperative provisioning and where Terraform sits.
3. Describe Terraform's architecture: **Core**, **providers** (plugins), **state**, **backend**.
4. Explain how Terraform is cloud-agnostic yet not "write once, run on any cloud".
5. Distinguish **configuration**, **state**, and **real infrastructure** — and say what each
   command reads and writes.
6. Distinguish a `resource` block from a `data` block.
7. Recognise every top-level HCL block type and what it is for.
8. Run the core workflow: `init → (fmt/validate) → plan → apply → destroy`.

---

## B. Plain-English explanation

You have already built API Gateway + Lambda + DynamoDB with Terraform. Think about what you
*didn't* do: you didn't write "first call CreateTable, wait, then call CreateFunction, then
call AddPermission". You wrote **what should exist** and Terraform figured out the calls.

**Infrastructure as Code (IaC)** means infrastructure is defined in text files that can be
versioned, reviewed, tested, and re-run — instead of clicking in a console.

**Terraform** is an IaC tool that:
- reads your `.tf` files (the **desired state**),
- remembers what it created last time in a **state** file,
- asks the real world what currently exists (**refresh**),
- computes the difference (**plan**),
- makes API calls to close the difference (**apply**).

It talks to platforms via **providers** — plugins that know a specific API (AWS, Azure,
GitHub, Kubernetes, Datadog, even "random" and "local file"). Terraform itself knows
nothing about S3 or Lambda; the AWS provider does.


### 🧠 Mental models (from the original 15-day notes)

- **Pets vs cattle (immutable infrastructure).** A pet has a name and you nurse it back to
  health; cattle are numbered and replaceable. "SSH in and patch the server" is pet thinking;
  "destroy it and let Terraform build a fresh one from code" is cattle thinking.
- **GPS vs dictated directions (declarative vs imperative).** A GPS only needs the
  destination and recalculates if something changes. Dictated turn-by-turn directions assume
  a starting point; if anything changed, they are simply wrong.
- **Operating system and device drivers (Core vs providers).** The OS (Terraform Core) offers
  one consistent interface but has no idea how a particular printer works; the driver
  (provider) does. Swap the driver and the OS works the same way against different hardware.
- **Coat-check ticket (state).** The ticket doesn't contain your coat, but it's the only
  reliable way to match "the coat on this ticket" to the coat on hook #47. Lose the ticket and
  the coat still exists, but nobody can say which one is yours.
- **Own it vs look it up (resource vs data).** Owning a car means buying, maintaining and
  scrapping it (resource). Looking up the market value of a car is reading a fact you can't
  change (data source).

---

## C. Technical deep dive

### C1. Declarative vs imperative

| | Imperative (procedural) | Declarative |
|---|---|---|
| You write | Steps (how) | End state (what) |
| Example | Bash + AWS CLI, Boto3 script | Terraform HCL, CloudFormation |
| Re-running | Often repeats actions (creates duplicates) unless you add checks | **Idempotent** — re-running with no changes = "No changes" |
| Ordering | You manage it | Tool derives it from references |
| Drift handling | Manual | Detected by diffing desired vs actual |

**Idempotent**: applying the same configuration twice leaves the system in the same state;
the second apply makes no changes.

Terraform also counts as **immutable-leaning**: when an attribute can't be changed in place
(e.g. an EC2 instance's AMI), Terraform **replaces** the resource (destroy + create) rather
than patching it. Configuration-management tools (Ansible, Chef, Puppet) are typically
**mutable**: they modify running servers. Terraform is primarily a *provisioning* tool;
config-management tools primarily configure software on existing machines. (They overlap
and are often combined.)

### C2. Advantages of IaC (objective 1b)

| Advantage | Concrete example from your projects |
|---|---|
| Version control & audit trail | Your CloudFront + S3 site: every change is a Git commit, reviewable in a PR |
| Reproducibility / consistency | Recreate the 3-tier VPC stack in a second region from the same code |
| Reduced human error | No forgotten security group rule clicked in the console |
| Speed & automation | GitHub Actions + OIDC runs `plan` on PR, `apply` on merge |
| Reusability | A VPC module used by the 3-tier app and the EKS project |
| Self-documentation | The code *is* the inventory of what exists |
| Drift detection | `plan` reveals console changes made outside Terraform |
| Disposable environments | Spin up a test stack, `destroy` it after |

### C3. Multi-cloud, hybrid, service-agnostic (objective 1c)

- **One workflow, one language**, many providers. The same `init/plan/apply` and HCL work
  for AWS, Azure, GCP, on-prem vSphere, Kubernetes, GitHub, PagerDuty…
- **Hybrid**: one configuration can use several providers at once, e.g. create an AWS RDS
  instance and a Datadog monitor and a Cloudflare DNS record — with cross-provider
  references (`cloudflare_record.value = aws_lb.app.dns_name`).
- **Not cloud-portable code**: `aws_instance` does not run on Azure. Terraform is
  *cloud-agnostic as a tool*, not a cloud abstraction layer. Exam trap: "Terraform lets you
  write one resource block that deploys to any cloud" — **false**.
- Compared with **CloudFormation** (AWS-only, state managed by AWS) and **ARM/Bicep**
  (Azure-only), Terraform's distinguishing features are provider breadth and one workflow.

### C4. Architecture

```
                 ┌──────────────────────────────────────────────┐
  *.tf files ──► │               TERRAFORM CORE                 │
  (desired)      │  • parses HCL           • builds graph       │
                 │  • reads/writes state   • computes diff      │
  state ◄──────► │  • walks graph in parallel (default 10)      │
  (backend)      └───────┬───────────────────┬──────────────────┘
                         │ gRPC (plugin      │
                         │ protocol)         │
                 ┌───────▼───────┐   ┌───────▼────────┐
                 │ AWS provider  │   │ random provider│  ← separate binaries,
                 └───────┬───────┘   └────────────────┘    downloaded by init
                         │ HTTPS API calls
                 ┌───────▼───────┐
                 │   AWS APIs    │   ← real infrastructure
                 └───────────────┘
```

- **Terraform Core**: the `terraform` binary. Language, graph, state, plan logic.
- **Providers**: separate executables, installed by `terraform init` into
  `.terraform/providers/`, discovered from the **Terraform Registry** by default
  (`registry.terraform.io`). Each provider defines **resource types** and **data sources**
  and translates CRUD operations to API calls.
- **Provider source address**: `hostname/namespace/type`, e.g.
  `registry.terraform.io/hashicorp/aws` (hostname defaults to the public registry, so you
  write `hashicorp/aws`).
- **Provider tiers** in the registry: **Official** (HashiCorp-maintained), **Partner**
  (maintained by the technology company, verified by HashiCorp), **Community** (individuals).
- **Built-in provider**: `terraform.io/builtin/terraform` — provides `terraform_data` and
  `terraform_remote_state`. Never downloaded. Our labs use it.

### C5. Configuration vs state vs real infrastructure

This is the most important mental model in the course.

```
 CONFIGURATION (.tf)          STATE (terraform.tfstate)        REAL INFRASTRUCTURE
 "what I want"                "what Terraform believes          "what actually exists"
                               it manages, last time it looked"
 ┌───────────────────┐        ┌───────────────────────────┐     ┌────────────────────┐
 │ resource          │        │ aws_s3_bucket.site        │     │ bucket             │
 │ "aws_s3_bucket"   │ ─────► │   id = "jk-site-prod"     │ ──► │ "jk-site-prod"     │
 │ "site" { ... }    │ address│   tags = {env="prod"}     │ ID  │ tags {env="dev"} ✱ │
 └───────────────────┘        └───────────────────────────┘     └────────────────────┘
                                                        ✱ drift: someone changed it
```

| Operation | Reads config | Reads state | Talks to real infra | Writes state | Changes infra |
|---|---|---|---|---|---|
| `init` | yes (blocks for providers/modules/backend) | backend only | no (registry downloads only) | no | no |
| `validate` | yes | no | no | no | no |
| `plan` | yes | yes | yes (refresh, read-only) | no* | no |
| `apply` | yes | yes | yes | **yes** | **yes** |
| `apply -refresh-only` | yes | yes | yes (read) | **yes** | no |
| `destroy` | yes | yes | yes | **yes** | **yes** |
| `state rm` | no | yes | no | **yes** | no |

\* `plan` refreshes in memory only; it does not persist the refreshed state.

### C6. HCL top-level blocks

| Block | Purpose | Example label(s) |
|---|---|---|
| `terraform` | Settings: `required_version`, `required_providers`, `backend`/`cloud` | none |
| `provider` | Configure a provider (region, credentials, alias) | `"aws"` |
| `resource` | A managed object Terraform creates/updates/destroys | `"aws_s3_bucket" "site"` |
| `data` | Read-only lookup of existing information | `"aws_caller_identity" "me"` |
| `variable` | Input parameter | `"region"` |
| `locals` | Named intermediate values | none (contains many) |
| `output` | Value exported from a module / shown after apply | `"bucket_name"` |
| `module` | Call another module | `"network"` |
| `import` | Bring existing object under management (1.5+) | none |
| `moved` | Record an address rename (1.1+) | none |
| `removed` | Stop managing an object, optionally without destroying it (1.7+) | none |
| `check` | Continuous assertions that warn, not fail (1.5+) | `"health"` |

**Resource address** = `<TYPE>.<NAME>` e.g. `aws_s3_bucket.site`. The *type* is chosen by
the provider (prefix `aws_` → AWS provider). The *name* is your local label; it is not the
cloud name of the bucket.

### C7. Resource vs data source

```hcl
# Managed resource — Terraform creates, updates, destroys it.
resource "aws_s3_bucket" "site" {
  bucket = "jk-site-prod"
}

# Data source — Terraform only reads. Never creates or destroys.
data "aws_caller_identity" "me" {}

output "account_id" {
  value = data.aws_caller_identity.me.account_id   # note the "data." prefix
}
```

| | `resource` | `data` |
|---|---|---|
| Lifecycle managed? | Yes (CRUD) | No (read) |
| Address | `TYPE.NAME` | `data.TYPE.NAME` |
| Appears in plan as | `+ create`, `~ update`, `- destroy`, `-/+ replace` | `<= read` (only shown when the read is deferred to apply) |
| Stored in state? | Yes | Yes (last-read result) |
| Typical use | Things you own | Lookup AMI IDs, account ID, existing VPC, another stack's outputs |

### C8. The core workflow (objective 3a)

```
   WRITE                 PLAN                       APPLY
 ┌────────┐  init   ┌─────────────┐  review   ┌─────────────────┐
 │ edit   │ ──────► │ terraform   │ ───────►  │ terraform apply │
 │ *.tf   │ (once / │ plan        │  approve  │ (executes plan, │
 │        │  when   │ (diff)      │           │  updates state) │
 └────────┘  deps   └─────────────┘           └─────────────────┘
      ▲     change)                                    │
      └──────────────── iterate ───────────────────────┘
                                         ... eventually: terraform destroy
```

HashiCorp describes the workflow as **Write → Plan → Apply**. `init` is a prerequisite
step; `fmt` and `validate` are hygiene steps during *Write*.

---

## D. Why it matters

- In real teams, the configuration/state/reality distinction drives every incident:
  "Terraform wants to destroy prod!" almost always means state and config disagree.
- The exam heavily tests *which object a command touches*. If you can fill in the table in
  C5 from memory, a large class of questions becomes easy.
- Provider architecture explains why `init` must run after adding a provider and why
  version locking matters for reproducible CI runs (your GitHub Actions pipelines).

---

## E. Syntax and command reference (Day 1 subset — full detail on Day 3)

```hcl
terraform {
  required_version = ">= 1.5.0"          # constrains the Terraform CLI version
  required_providers {
    aws = {
      source  = "hashicorp/aws"          # registry.terraform.io/hashicorp/aws
      version = "~> 5.0"                 # >= 5.0, < 6.0
    }
  }
}

provider "aws" {
  region = "eu-west-2"                   # provider configuration
}
```

| Command | What happens | Common error | Easily confused with |
|---|---|---|---|
| `terraform init` | Installs providers & modules, configures backend, writes lock file | "Failed to query available provider packages" (no network/registry) | `terraform get` (modules only) |
| `terraform fmt` | Rewrites files to canonical style | — | `validate` |
| `terraform validate` | Checks syntax/consistency | "Missing required argument" | `plan` |
| `terraform plan` | Refresh + diff, shows proposed actions | Credential/API errors appear here | `apply` |
| `terraform apply` | Plans (unless given a plan file), prompts, executes | Partial failures leave partial state | `apply plan.tfplan` |
| `terraform destroy` | Plans destruction of everything in state, prompts | `prevent_destroy` errors | `state rm` |

---

## F. Worked example — a first configuration (no cloud needed)

```hcl
# main.tf
terraform {
  required_version = ">= 1.5.0"
}

variable "project" {
  type    = string
  default = "bootcamp"
}

locals {
  greeting = "Hello from ${var.project}"
}

resource "terraform_data" "hello" {
  input = local.greeting
}

output "message" {
  value = terraform_data.hello.output
}
```

Line by line:

| Line | Meaning |
|---|---|
| `terraform { required_version = ">= 1.5.0" }` | Refuse to run on older CLI versions (`terraform_data` needs 1.4+) |
| `variable "project"` | Declares an input named `project`, type string, default `bootcamp` |
| `locals { greeting = "Hello from ${var.project}" }` | String template; `${...}` interpolates. Referenced as `local.greeting` (singular!) |
| `resource "terraform_data" "hello"` | Managed resource of type `terraform_data` (built-in provider), local name `hello` |
| `input = local.greeting` | Argument; value stored in state |
| `output "message"` | After apply, prints the resource's `output` **attribute** (which mirrors `input`) |

Expected behaviour:

```
$ terraform init
Initializing the backend...
Initializing provider plugins...
Terraform has been successfully initialized!

$ terraform plan
Terraform will perform the following actions:

  # terraform_data.hello will be created
  + resource "terraform_data" "hello" {
      + id     = (known after apply)
      + input  = "Hello from bootcamp"
      + output = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + message = (known after apply)

$ terraform apply      # type "yes"
terraform_data.hello: Creating...
terraform_data.hello: Creation complete after 0s [id=...]
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
Outputs:
message = "Hello from bootcamp"

$ terraform apply      # run again, nothing changed
No changes. Your infrastructure matches the configuration.
```

The second apply demonstrates **idempotency**.

Note the distinction: `input` is an **argument** (you set it); `id` and `output` are
**attributes** (exported by the resource, some only known after apply).

---

## G. Visual — one full run, step by step

```
terraform apply
 │
 ├─1 Load all *.tf files in the directory (order of files irrelevant)
 ├─2 Read state from backend (local file by default), acquire lock if supported
 ├─3 Build dependency graph from references
 ├─4 Refresh: for each resource in state, provider reads real object
 ├─5 Diff desired (config) vs current (refreshed state) → plan
 ├─6 Show plan, wait for "yes"
 ├─7 Walk graph: independent nodes in parallel (default parallelism 10)
 │     each node: provider API call → result written into state
 ├─8 Persist state (with backup), release lock
 └─9 Print outputs
```

---

## H. Common misconceptions

| # | Misconception | Reality |
|---|---|---|
| 1 | "Terraform code is portable across clouds." | Resource types are provider-specific. The *workflow* is portable. |
| 2 | "State is just a cache; I can delete it." | Without state, Terraform doesn't know it manages anything — the next plan proposes creating everything again (and may collide). |
| 3 | "A data source will create the thing if missing." | Data sources only read; missing objects normally cause an error. |
| 4 | "Terraform runs files in order." | All `.tf` files in a directory are merged; order comes from the dependency graph. |
| 5 | "Terraform configures software inside VMs like Ansible." | Provisioning is its job; in-VM configuration via provisioners is a last resort. |
| 6 | "A successful plan guarantees a successful apply." | Apply can fail on permissions, quotas, name conflicts, API errors, eventual consistency. |
| 7 | "The resource name label is the cloud resource name." | `aws_s3_bucket.site` → `site` is a Terraform-internal label; the bucket name is the `bucket` argument. |
| 8 | "`plan` saves the refreshed state." | Plan refreshes in memory only. |

---

## I. Exam traps

- **"Which is NOT a benefit of IaC?"** — look for absolutes ("guarantees zero downtime",
  "eliminates the need for state"). Absolutes are almost always wrong.
- **Provider vs provisioner** — similar words, totally different. Provider = plugin for an
  API. Provisioner = run a script on create/destroy (last resort).
- **"Terraform Core makes API calls to AWS"** — no; providers do. Core talks to providers
  over RPC.
- **Data source address** — must start with `data.`.
- **"Terraform is a configuration management tool"** — HashiCorp frames it as a provisioning
  / orchestration tool.

**More traps from the original notes**
- **"Idempotent" ≠ "does nothing".** The first apply does create resources; only a re-run
  with nothing changed is a no-op.
- **"Terraform can only manage cloud resources"** — false: providers exist for SaaS (GitHub,
  Datadog, PagerDuty), on-prem (vSphere) and utilities (`random`, `local`, `time`).
- **IaC (the practice) vs Terraform (one tool).** Ansible/Chef/Puppet are also IaC in a broad
  sense but are configuration-management tools; Terraform is a provisioning tool. They are
  complementary.
- **Lock file vs state file in Git:** commit `.terraform.lock.hcl`; never commit
  `terraform.tfstate`.

---

## J. Active recall (answer before expanding)

1. Name the three "views of the world" Terraform reconciles.
2. Which component actually calls the AWS API?
3. What does idempotent mean, and how do you demonstrate it with Terraform?
4. What is the source address of the AWS provider written in full?
5. What prefix does every data source reference have?
6. Which command writes `.terraform.lock.hcl`?

<details><summary>Answers</summary>

1. Configuration (desired), state (recorded/believed), real infrastructure (actual).
2. The provider plugin (e.g. the AWS provider binary), invoked by Terraform Core over RPC.
3. Running the same operation repeatedly yields the same result; run `apply` twice — the
   second reports "No changes".
4. `registry.terraform.io/hashicorp/aws`.
5. `data.` — e.g. `data.aws_ami.ubuntu.id`.
6. `terraform init` (also updated by `init -upgrade` and `terraform providers lock`).
</details>

---

## K. Practice exercises

**K1 — Interpret.** What does each block do, and what appears in the plan?
```hcl
data "aws_vpc" "default" { default = true }

resource "aws_security_group" "web" {
  name   = "web"
  vpc_id = data.aws_vpc.default.id
}
```

**K2 — Classify.** Imperative or declarative? (a) a Python Boto3 script, (b) CloudFormation,
(c) a Bash loop of `aws ec2 run-instances`, (d) Terraform, (e) Pulumi *program* executed by
the Pulumi engine (tricky — discuss).

**K3 — Scenario.** You delete `terraform.tfstate` for the static website project and run
`terraform plan`. What does Terraform propose, and what will happen if you apply?

**K4 — Predict.** You add a `provider "random" {}` block and a `random_pet` resource, then
run `terraform plan` without running `init`. What happens?

<details><summary>Answers</summary>

**K1.** The data block reads the default VPC (no changes to it). The resource creates a
security group in that VPC. Plan: `+ create aws_security_group.web`. The data source read
normally happens during plan (its arguments are known), so it doesn't appear as an action.
Implicit dependency: the SG depends on the data source.

**K2.** (a) imperative, (b) declarative, (c) imperative, (d) declarative, (e) you write code
in a general-purpose language, but the engine treats the resulting resource graph
declaratively — commonly described as declarative with an imperative authoring language.
The exam won't test Pulumi; the point is to judge by *what you describe*: steps vs end state.

**K3.** Terraform no longer knows it manages anything, so it proposes **creating** every
resource. Apply would attempt to create a bucket that already exists → error (S3 names are
global) or, for other resource types, create duplicates. Recovery: restore state from
backup/versioned backend, or `import` the existing objects.

**K4.** Terraform errors: the provider is not installed / "Inconsistent dependency lock
file" / "Required plugins are not installed" — run `terraform init`.
</details>

> Optional real-cloud practice: [AWS lab A1 — first workflow](../labs/aws-optional/README.md#a1--first-real-workflow-days-1-3).

---

## L. Lesson assessment — mastery quiz

Closed book. Write every answer down **before** opening the answers, and give each a confidence (1 = guess, 2 = unsure, 3 = sure). Pass mark: **10/12**. Record the score in [SCORECARD.md](../SCORECARD.md) and log misses in [mistakes/error-log.md](../mistakes/error-log.md).

*These questions are the self-test questions from the original 15-day notes, corrected and regrouped by topic.*

1. In one sentence, what is the core difference between declarative and imperative infrastructure tools?
2. List four advantages of IaC over manual console changes.
3. Define idempotency and explain why it matters operationally.
4. What does immutable infrastructure mean, and how does it differ from patching in place?
5. True or false: Terraform can only manage cloud resources.
6. Provisioning tool vs configuration-management tool: which is Terraform?
7. What does "service-agnostic workflow" mean for Terraform?
8. Why should a state file never be committed to a public Git repository?
9. Is state "just a cache" or the source of truth? Explain.
10. Name the three provider maintainer tiers.
11. What is the fundamental difference between a `resource` block and a `data` block, and how do you reference each?
12. Can a `data` block ever create infrastructure? What does a data source look like in a plan?

<details><summary>Answers</summary>

1. Declarative tools (Terraform) take a description of the desired end state and work out the steps; imperative tools (a shell script) execute steps you specify, with no built-in awareness of current state.
2. Any four of: consistency across environments, version control and peer review, automation (CI/CD), reusability (modules), auditability / change history, fewer human errors, fast disaster recovery, drift detection.
3. Re-applying the same configuration to the same infrastructure converges on the same end state, doing nothing if nothing changed. It makes it safe to run Terraform repeatedly (e.g. on every merge) without duplicates.
4. Replace a component with a new one built from code instead of modifying it while it runs. Patching in place accumulates drift and creates "pets" nobody can reproduce exactly.
5. False. Providers exist for on-prem systems, SaaS tools and utilities such as `random`, `local` and `time`.
6. Provisioning: it creates and destroys infrastructure. Configuration management (Ansible, Chef, Puppet) installs and configures software on existing servers. They're often combined.
7. The same write → plan → apply workflow and language work for every platform; platform-specific logic lives in provider plugins, not in Terraform Core. (The *code* is not portable between clouds.)
8. State stores every attribute in plain text, which can include passwords, keys and internal addresses. Once committed, it stays in Git history.
9. Both, but the mapping role is what makes it essential: state links each resource address to a real object ID. Caching attribute values is a secondary performance benefit.
10. Official (HashiCorp), Partner (the technology vendor, verified by HashiCorp), Community (individuals).
11. A resource's full lifecycle is managed by Terraform (`TYPE.NAME.ATTR`); a data source only reads something that already exists (`data.TYPE.NAME.ATTR`).
12. Never; it is read-only. Usually it's read during plan and shows no action. If the read must wait until apply (unknown arguments, `depends_on`), it appears as `<= read`. It never shows `+`, `~` or `-`.
</details>

## M. Summary

- IaC = infrastructure defined as versioned, reviewable, repeatable code.
- Terraform is declarative and idempotent; it computes actions from desired vs current.
- Core (graph, state, plan) + providers (API plugins installed by `init`).
- Config ≠ state ≠ reality. Plan reads all three; apply writes state and changes reality.
- `resource` = managed; `data` = read-only, address `data.TYPE.NAME`.
- Workflow: Write → Plan → Apply (init first).

### Flashcards (Day 1)
| Front | Back |
|---|---|
| Declarative IaC | Describe desired end state; tool computes the steps |
| Idempotent | Re-applying the same config makes no further changes |
| Terraform Core vs provider | Core: language/graph/state; provider: plugin that calls an API |
| Default provider registry host | `registry.terraform.io` |
| Provider tiers | Official, Partner, Community |
| Data source address format | `data.<TYPE>.<NAME>.<ATTR>` |
| Plan persists refreshed state? | No — in memory only |
| Where state goes by default | `terraform.tfstate` in the working directory (local backend) |
| Built-in provider resources | `terraform_data`, data source `terraform_remote_state` |

---

## N. Mastery decision

| Result on Day 1 quiz | Decision |
|---|---|
| 7–8 / 8 | ✅ Mastered — proceed to Day 2 |
| 5–6 / 8 | ➕ More practice — redo K1–K4 aloud, 3 extra questions, then proceed |
| ≤ 4 / 8 | 🔁 Re-teach sections C4–C7 before Day 2 |

Recorded in [PROGRESS.md](../PROGRESS.md).
