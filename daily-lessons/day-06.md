# Day 6 — Modules, Workspaces, and Reusable Infrastructure

**Objectives covered:** 5a, 5b, 5c, 5d + CLI workspaces (003 objective, frequent distractor)
**Labs:** [Lab 06](../labs/lab-06/README.md), [Lab 11](../labs/lab-11/README.md)

---

## A. Learning objectives

1. Define root module and child module; explain that every configuration is a module.
2. List module source types and their syntax; know where `version` works.
3. Explain variable scope: inputs in, outputs out, nothing else crosses.
4. Build, call, and compose modules; use `count`/`for_each`/`depends_on`/`providers` on modules.
5. Pass provider configurations into modules; know why modules shouldn't define providers.
6. Version modules and upgrade them safely.
7. Explain CLI workspaces, `terraform.workspace`, state layout, and limitations.
8. Choose between workspaces and separate directories/state for environments.
9. Distinguish CLI workspaces from HCP Terraform workspaces.

---

## B. Plain-English explanation

A **module** is a folder of `.tf` files. The folder you run Terraform in is the **root
module**. When it uses `module "x" { source = "./modules/vpc" }`, that folder becomes a
**child module**. Modules work like functions: **variables are parameters, outputs are
return values**, internals are private.

A **CLI workspace** is a named, separate *state* for the *same* configuration. Same code,
different state file — handy for throw-away copies, weak for prod/non-prod isolation.

---

## C. Technical deep dive

### C1. Module structure (standard)

```
modules/vpc/
├── main.tf          # resources
├── variables.tf     # inputs
├── outputs.tf       # outputs
├── versions.tf      # required_providers (minimum versions), no provider blocks
└── README.md
```
Registry-published modules follow `terraform-<PROVIDER>-<NAME>` repo naming and may
have `examples/` and nested `modules/` directories.

### C2. Calling a module

```hcl
module "network" {
  source  = "./modules/vpc"     # required
  # version = "~> 5.0"          # only for registry sources

  # inputs (must match child's variable names)
  cidr_block = "10.0.0.0/16"
  azs        = ["eu-west-2a", "eu-west-2b"]
  tags       = local.common_tags
}

resource "aws_security_group" "app" {
  vpc_id = module.network.vpc_id          # output from child
}
```
After adding or changing a module `source`/`version`: `terraform init` (or `terraform get`).

### C3. Module sources (5a)

| Source | Syntax | Version pinning |
|---|---|---|
| Local path | `"./modules/vpc"`, `"../shared/vpc"` (must start with `./` or `../`) | none (same repo) |
| Public Terraform Registry | `"terraform-aws-modules/vpc/aws"` → `<NAMESPACE>/<NAME>/<PROVIDER>` | `version = "~> 5.0"` |
| Private registry (HCP Terraform/TFE) | `"app.terraform.io/acme/vpc/aws"` → `<HOST>/<ORG>/<NAME>/<PROVIDER>` | `version = "1.2.0"` |
| GitHub | `"github.com/acme/tf-vpc"` | `?ref=v1.2.0` |
| Generic Git | `"git::https://example.com/vpc.git?ref=v1.2.0"`, `"git::ssh://..."` | `?ref=` tag/branch/SHA |
| Bitbucket | `"bitbucket.org/acme/vpc"` | `?ref=` |
| HTTP URL | `"https://example.com/vpc.zip"` | — |
| S3 / GCS | `"s3::https://s3-eu-west-2.amazonaws.com/bucket/vpc.zip"`, `"gcs::https://..."` | — |
| Mercurial | `"hg::https://..."` | `?ref=` |
| Subdirectory | `"git::https://example.com/repo.git//modules/vpc?ref=v1.0"` (`//` separates) | |

Without `./`, `"modules/vpc"` is interpreted as a **registry** address → error.

Registry facts:
- Modules on the public registry are sourced from public GitHub repos, versioned by
  **semantic version Git tags** (`v1.2.0`).
- Registry modules can be marked as maintained by verified partners (labels/badges vary).
- The registry shows inputs, outputs, dependencies, resources, examples.
- Private registry (HCP Terraform) lets an org share internal modules with versioning.

### C4. Variable scope (5b)

```
 ROOT MODULE                               CHILD MODULE (./modules/vpc)
 ┌────────────────────────────┐            ┌──────────────────────────────┐
 │ var.env (root input)       │            │ variable "cidr_block" {}     │
 │ local.common_tags          │  inputs    │ variable "tags" {}           │
 │ module "network" {         │ ─────────► │                              │
 │   cidr_block = "10.0..."   │            │ resource "aws_vpc" "this" {} │
 │   tags = local.common_tags │            │                              │
 │ }                          │  outputs   │ output "vpc_id" {            │
 │ module.network.vpc_id  ◄───┼────────────│   value = aws_vpc.this.id    │
 └────────────────────────────┘            └──────────────────────────────┘
  ✘ child cannot see var.env unless passed
  ✘ root cannot see aws_vpc.this directly — only module.network.vpc_id
```
- Child resources are addressed in state as `module.network.aws_vpc.this`, but you
  **cannot reference** `module.network.aws_vpc.this.id` in expressions; expose an output.
- Child module outputs are not printed by `terraform apply` unless re-exported by a root output.
- Siblings communicate via the root: `module.b` input = `module.a.output`.

### C5. Meta-arguments on modules

```hcl
module "bucket" {
  source   = "./modules/bucket"
  for_each = toset(["logs", "assets"])
  name     = each.key
}
# module.bucket["logs"].arn

module "app" {
  source     = "./modules/app"
  depends_on = [module.network]      # whole-module dependency (0.13+)
  providers  = {
    aws = aws.us_east                 # child's "aws" = root's aliased config
  }
}
```
Supported: `count`, `for_each`, `depends_on`, `providers` (+ `source`, `version`). **Not**
`lifecycle` (put lifecycle in the child's resources).

### C6. Providers and module boundaries
- Child modules **inherit the default (un-aliased) provider configurations** of the parent automatically.
- Aliased configs must be passed explicitly via `providers = { }`.
- A child that needs multiple configurations declares them with `configuration_aliases`:
  ```hcl
  terraform {
    required_providers {
      aws = {
        source                = "hashicorp/aws"
        version               = ">= 5.0"
        configuration_aliases = [aws.us_east]
      }
    }
  }
  ```
- **Reusable modules should not contain `provider` blocks.** A module with its own provider
  block can't use `count`/`for_each`/`depends_on`, and removing it from config becomes
  painful (the provider config disappears with it, so Terraform can't destroy its resources).
- Modules declare `required_providers` (source + minimum version) so the root knows what to install.

### C7. Versioning and upgrades (5d)
- Pin registry modules: `version = "~> 5.1"` (or exact for maximum stability).
- Git: `?ref=v5.1.0` (tags) — avoid branches for prod (moving target).
- Module versions are **not** recorded in `.terraform.lock.hcl`; the constraint (and your
  VCS ref) is your pin.
- Upgrade: change `version`, run `terraform init -upgrade` (or `init` if the new constraint
  excludes the installed version), then **plan carefully** — module upgrades can rename
  internal resources (look for `moved` blocks provided by the author).
- Local modules have no version; they change when the files change.

### C8. Module composition patterns

```
root (envs/prod)
 ├── module "network"  (./modules/vpc)        → outputs vpc_id, private_subnet_ids
 ├── module "db"       (./modules/rds)        ← vpc_id, subnet_ids
 ├── module "service"  (./modules/ecs-service) ← vpc_id, subnet_ids, db_endpoint
 └── module "cdn"      (registry module)      ← providers = { aws = aws.us_east }
```
- Prefer **flat composition** (root wires modules together) over deep nesting.
- Keep modules small and purposeful; avoid "wrapper of one resource" modules.
- Don't over-parameterise — expose what consumers need.

### C9. CLI workspaces

```bash
terraform workspace list        # * default
terraform workspace new dev     # creates & switches
terraform workspace select prod # switch (1.4+: `select -or-create`)
terraform workspace show        # current name
terraform workspace delete dev  # must not be current; must be empty unless -force
```
```hcl
resource "aws_instance" "web" {
  instance_type = terraform.workspace == "prod" ? "m5.large" : "t3.micro"
  tags          = { Name = "web-${terraform.workspace}" }
}
```
Local backend layout:
```
terraform.tfstate                          ← default workspace
terraform.tfstate.d/dev/terraform.tfstate
terraform.tfstate.d/prod/terraform.tfstate
```
Remote backends store per-workspace state too (e.g. S3 under `env:/<workspace>/<key>` by
default, configurable with `workspace_key_prefix`).

| Fact | Detail |
|---|---|
| Always exists | `default` — cannot be deleted |
| Shares | Configuration, backend, provider credentials |
| Separates | State only |
| Env var | `TF_WORKSPACE=dev` selects a workspace |
| Supported backends | Many (local, s3, azurerm, gcs, consul, pg, …) — not all |

**When workspaces fit:** temporary copies, feature-branch test stacks, identical
environments that share credentials and differ only by small parameters.

**When to use separate configurations/directories (or separate HCP Terraform workspaces):**
prod vs non-prod (different accounts, credentials, access control), significantly different
infrastructure, need for independent blast radius. Easy to `apply` to the wrong workspace —
nothing in the code tells you which one is selected.

```
envs/
├── dev/   main.tf → module "app" { source = "../../modules/app" ... }   backend key dev
├── prod/  main.tf → module "app" { source = "../../modules/app" ... }   backend key prod
modules/app/
```

### C10. CLI workspace vs HCP Terraform workspace

| | CLI workspace | HCP Terraform workspace |
|---|---|---|
| What | Alternate state for one working dir | A unit with its own config source, state, variables, permissions, run history |
| Config | Shared by all workspaces | Each workspace links to a config (VCS repo/dir, or CLI upload) |
| Variables | Same tfvars unless you branch on `terraform.workspace` | Per-workspace variables + variable sets |
| Access control | None of its own | Team permissions per workspace/project |
| Typical mapping | dev/test copies | one workspace per environment per component |

---

## D. Why it matters

Your four AWS projects share patterns (VPC, IAM, logging). Modules let you stop copy-pasting
them. Workspaces are a common exam distractor and a common real-world foot-gun
("I applied dev changes to prod because the wrong workspace was selected").

---

## E. Reference — module errors

| Error | Cause |
|---|---|
| `Module not installed` | Added/changed module; run `terraform init` |
| `Unsupported argument "x"` on module | Child has no `variable "x"` |
| `Missing required argument` on module | Child variable has no default and wasn't passed |
| `Unsupported attribute` on `module.x.y` | Child has no `output "y"` |
| `Module ... has invalid source` / registry lookup failure for `modules/vpc` | Missing `./` |
| `version` argument with local source | Error: version only for registry modules |

---

## F. Worked example — build and call a module

`modules/bucket/variables.tf`
```hcl
variable "name"  { type = string }
variable "env"   { type = string }
variable "tags"  {
  type    = map(string)
  default = {}
}
```
`modules/bucket/main.tf`
```hcl
locals {
  full_name = "${var.env}-${var.name}"
}
resource "terraform_data" "bucket" {
  input = {
    name = local.full_name
    tags = merge({ Env = var.env }, var.tags)
  }
}
```
`modules/bucket/outputs.tf`
```hcl
output "name" { value = local.full_name }
output "id"   { value = terraform_data.bucket.id }
```
Root `main.tf`
```hcl
variable "env" { default = "dev" }

module "buckets" {
  source   = "./modules/bucket"
  for_each = toset(["logs", "assets"])
  name     = each.key
  env      = var.env
}

output "bucket_names" {
  value = [for b in module.buckets : b.name]
}
```
`terraform init` installs the module; plan shows
`module.buckets["assets"].terraform_data.bucket` and `module.buckets["logs"].terraform_data.bucket`
to create; output `["dev-assets", "dev-logs"]`.

**Predict:** change `env` default to `"prod"`. What changes? <details><summary>Answer</summary>
Both module instances' `terraform_data.bucket.input` change → **update in place** (input is
not a replace-trigger); output becomes `["prod-assets","prod-logs"]`. No addresses change
because the for_each keys (`logs`,`assets`) didn't change.</details>

---

## G. Visual — workspaces vs directories

```
WORKSPACES (one config, many states)          DIRECTORIES (many configs, many states)
  main.tf ─┬─► default  state                   envs/dev/main.tf  ─► dev state  (dev account creds)
           ├─► dev      state                   envs/prod/main.tf ─► prod state (prod account creds)
           └─► prod     state                        both call modules/app
  same creds, same backend, same code            separate creds/backends/access, explicit
```

---

## H. Common misconceptions

| # | Misconception | Reality |
|---|---|---|
| 1 | "Child modules can read root variables." | Only what's passed explicitly. |
| 2 | "`version` works with Git sources." | Registry only; Git uses `?ref=`. |
| 3 | "Lock file pins module versions." | Providers only. |
| 4 | "I can reference `module.x.aws_vpc.this.id`." | Only outputs: `module.x.vpc_id`. |
| 5 | "Workspaces give separate configurations." | Same configuration, separate state. |
| 6 | "Workspaces isolate credentials." | Shared backend & credentials. |
| 7 | "`default` workspace can be deleted." | Never. |
| 8 | "Modules should configure their own providers." | Reusable modules should not contain provider blocks. |
| 9 | "`lifecycle` can be set on a module block." | Not supported. |
| 10 | "Child outputs display after apply." | Only root outputs display. |

---

## I. Exam traps
- Registry address format `<NAMESPACE>/<NAME>/<PROVIDER>` — e.g. `hashicorp/consul/aws`.
- Private registry adds a hostname prefix.
- "Which command downloads modules?" → `init` (and `get`). Both are accepted; read whether it asks for "only modules".
- "Variable scope" questions: no globals.
- "Workspace" without a qualifier: decide from context whether it means a CLI workspace
  (alternate state) or an HCP Terraform workspace (config + state + variables + permissions).

---

## J. Active recall
1. What makes a module "root"?
2. Source string for a local module two directories up in `shared/vpc`?
3. How does a child get an aliased provider?
4. Name the state file path for CLI workspace `qa` on the local backend.
5. Two reasons to prefer separate directories over workspaces for prod.

<details><summary>Answers</summary>

1. It's the working directory Terraform is run in.
2. `"../../shared/vpc"`.
3. `providers = { aws = aws.alias }` in the module block (child may declare `configuration_aliases`).
4. `terraform.tfstate.d/qa/terraform.tfstate`.
5. Separate credentials/access control/backends; reduced risk of applying to the wrong env; ability for envs to differ structurally.
</details>

---

## K. Practice exercises

**K1 — Debug.** `module "net" { source = "modules/network" }` fails at init. Why?

**K2 — Predict.** Module called with `count = 2`. How do you reference the `vpc_id` output of the second instance?

**K3 — Scenario.** You upgrade a registry module from 4.x to 5.x; plan shows 12 resources
to destroy and 12 to create with new addresses. What happened, and what should you look for?

**K4 — Choose.** Startup with one AWS account, needs short-lived per-PR copies of a stack. Workspaces or directories?

<details><summary>Answers</summary>

**K1.** Missing `./` → treated as registry address. Use `"./modules/network"`.

**K2.** `module.net[1].vpc_id`.

**K3.** The major version refactored internal resource addresses. Look for `moved` blocks
in the new version (or add your own), read the upgrade notes in the module's README /
CHANGELOG (local copy), or pin back to 4.x. Never apply a mass destroy blindly.

**K4.** CLI workspaces fit well (same config, same credentials, disposable).
</details>

---

## L. Lesson assessment
10 questions in chat: 3 sources/versions, 3 scope/outputs, 2 providers in modules, 2 workspaces. Pass **8/10**.

## M. Summary
- Every directory of `.tf` is a module; root = where you run Terraform.
- Inputs = variables; outputs = return values; no implicit sharing.
- Sources: local (`./`), registry (`ns/name/provider` + `version`), private registry (host prefix), Git (`?ref=`), HTTP, S3/GCS; `//` for subdirectories.
- Modules support `count`, `for_each`, `depends_on`, `providers` — not `lifecycle`.
- Don't put provider blocks in reusable modules; pass aliases with `providers`.
- CLI workspaces = multiple states, one config, shared creds; `default` undeletable; `terraform.workspace`.

### Flashcards (Day 6)
| Front | Back |
|---|---|
| Root module | Directory where Terraform runs |
| Public registry module address | `<NAMESPACE>/<NAME>/<PROVIDER>` |
| Private registry module address | `<HOST>/<ORG>/<NAME>/<PROVIDER>` |
| Git module version pin | `?ref=v1.2.0` |
| Subdirectory in a package | `//path` |
| Reference module output | `module.NAME.OUTPUT` |
| Pass aliased provider to module | `providers = { aws = aws.west }` |
| Module meta-args | count, for_each, depends_on, providers |
| CLI workspace state path (local) | `terraform.tfstate.d/<ws>/terraform.tfstate` |
| Current workspace in HCL | `terraform.workspace` |
| Workspace that can't be deleted | `default` |

## N. Mastery decision
8–10 ✅ · 6–7 ➕ redo Lab 06 extension tasks · ≤5 🔁 re-teach C3–C6, C9.
