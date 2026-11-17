# Day 5 — Terraform State and State Management (HIGH PRIORITY)

**Objectives covered:** 2d, 6a, 6b, 6c, 6d, 7a, 7b
**Labs:** [Lab 08](../labs/lab-08/README.md), [Lab 09](../labs/lab-09/README.md), [Lab 10](../labs/lab-10/README.md)

> ⚠ **Safety first.** Every state command today is practised **only** inside lab
> directories with throw-away `terraform_data` resources. Never practise `state rm`,
> `state push`, or `force-unlock` against a real project's state.

---

## A. Learning objectives

1. Explain *why* Terraform needs state (4 reasons) and what's inside a state file.
2. Describe the local backend, remote backends, and the `cloud` block.
3. Configure a backend, including partial configuration; know backend-block restrictions.
4. Explain state locking: which operations lock, what happens on contention, `force-unlock`.
5. Explain state security: secrets in state, encryption, access control.
6. Use `state list/show/mv/rm/pull/push/replace-provider` and predict their effects.
7. Use `moved`, `removed`, and `import` blocks; compare with CLI equivalents.
8. Import existing infrastructure (CLI and config-driven, with config generation).
9. Detect and reconcile drift; recover from lost or damaged state.
10. Migrate state between backends.

---

## B. Plain-English explanation

State is Terraform's **memory**. Your config says "I want a bucket called `site`". AWS has
thousands of buckets. State is the note that says "*the* `aws_s3_bucket.site` in this
configuration is the real bucket `jk-site-prod`". Without that note Terraform can't tell
which real object belongs to which block — it would try to create everything again.

State lives in a **backend**. By default, a local file. In teams, a shared remote store
(S3, HCP Terraform, Azure Storage, GCS…) with **locking** so two people can't write at once.


### 🧠 Mental models (from the original 15-day notes)

- **State locking = "someone is editing" in a shared document.** Two people may both want to
  edit; the lock makes sure only one change commits at a time, so the second person waits or
  gets a clear message instead of their edit silently vanishing.
- **`state rm` vs `destroy` = tearing up the index card vs emptying the drawer.** `state rm`
  removes Terraform's record; the real object is untouched. `destroy` actually deletes it.
- **Classic import vs import block.** Classic `terraform import` hands you a card saying
  "drawer 3 is yours" but no list of what's inside; you write the config yourself. An `import`
  block with `-generate-config-out` also gives you a typed-up inventory to review.
- **How S3-native locking works (1.10+).** With `use_lockfile = true`, Terraform tries to
  create a `.tflock` object using an S3 *conditional write* that only succeeds if the object
  doesn't exist yet. If another run holds the lock, the write fails and you get a lock error.
  The lock object is deleted when the run finishes. No DynamoDB table is needed.

---

## C. Technical deep dive

### C1. Why state exists

| Purpose | Explanation |
|---|---|
| **Mapping** config → real objects | Address `aws_instance.web` ↔ ID `i-0abc…`. Providers need IDs to read/update/delete |
| **Metadata** | Dependencies (to destroy in the right order even after config is deleted), provider used, schema versions, `create_before_destroy` flags |
| **Performance** | Cached attributes; with `-refresh=false` Terraform can plan from state alone for huge configs |
| **Syncing** | Shared remote state = single source of truth for a team |

Terraform does **not** use tags or naming conventions to find your resources — only state.

### C2. What's in the state file (conceptual)

```json
{
  "version": 4,
  "terraform_version": "1.12.0",
  "serial": 7,
  "lineage": "3f1c2a9e-....",
  "outputs": { "bucket": { "value": "jk-site-prod", "type": "string" } },
  "resources": [
    {
      "mode": "managed",
      "type": "aws_s3_bucket",
      "name": "site",
      "provider": "provider[\"registry.terraform.io/hashicorp/aws\"]",
      "instances": [
        {
          "schema_version": 0,
          "attributes": { "id": "jk-site-prod", "bucket": "jk-site-prod", "arn": "..." },
          "sensitive_attributes": [],
          "dependencies": []
        }
      ]
    }
  ]
}
```
| Field | Meaning |
|---|---|
| `serial` | Increments on every write; used to detect stale writes |
| `lineage` | UUID set when state is first created; prevents pushing state from a *different* history |
| `mode` | `managed` (resource) or `data` |
| `instances` | One per count/for_each instance (`index_key`) |
| `sensitive_attributes` | Which attributes are sensitive — **values are still plaintext** |

It's JSON, but **never edit it by hand** — use `terraform state` commands.

### C3. Backends

| Backend | Locking | Notes |
|---|---|---|
| `local` (default) | Yes (OS file lock on the local machine) | `terraform.tfstate` + `terraform.tfstate.backup`; not shareable |
| `s3` | Yes — DynamoDB table (classic) **or** native S3 lockfile `use_lockfile = true` (1.10+; DynamoDB locking deprecated later) | Enable bucket versioning + encryption |
| `azurerm` | Yes (blob lease) | |
| `gcs` | Yes | |
| `consul` | Yes | |
| `http` | Optional | Depends on the server |
| `pg`, `kubernetes`, `oss`, `cos` | Yes | |
| `remote` | via HCP Terraform | Legacy way to use HCP Terraform; prefer the `cloud` block |
| `cloud` block (1.1+) | Yes | HCP Terraform / Terraform Enterprise integration (not technically a backend block) |

Some deprecated/removed backends (artifactory, etcd, swift, manta) — don't worry about them.

```hcl
terraform {
  backend "s3" {
    bucket       = "jk-tfstate"
    key          = "three-tier/prod/terraform.tfstate"
    region       = "eu-west-2"
    encrypt      = true
    use_lockfile = true            # S3-native locking (Terraform 1.10+)
    # dynamodb_table = "tf-locks" # older approach
  }
}
```

**Backend block rules**
- Only **one** backend per configuration.
- **No variables, locals, or references** — values must be literals (because the backend is
  initialised before anything else is evaluated). Error: *"Variables may not be used here."*
- Use **partial configuration** to inject values at init:
  ```hcl
  terraform { backend "s3" {} }
  ```
  ```bash
  terraform init -backend-config=backend-prod.hcl
  terraform init -backend-config="key=app/prod.tfstate"
  ```
  Good for keeping secrets (e.g. access keys) out of code — though credentials should
  preferably come from env vars/roles.
- Changing the backend block requires `terraform init` again (`-migrate-state` or `-reconfigure`).
- Backend config (possibly including credentials) is cached in `.terraform/` and in plan files.

**Local backend**
```hcl
terraform {
  backend "local" {
    path = "state/dev.tfstate"     # custom path; default is terraform.tfstate
  }
}
```

### C4. State locking

```
 Engineer A: terraform apply ──► acquire lock ✔ ──► ...working... ──► release
 Engineer B: terraform apply ──► acquire lock ✘
             "Error acquiring the state lock ... Lock Info: ID: 9db..., Who: a@host, Operation: OperationTypeApply"
```
- Automatic for **all operations that could write state** (plan, apply, destroy, refresh,
  state mv/rm/push, import, etc.), on backends that support it.
- `-lock=false` disables (dangerous); `-lock-timeout=5m` waits instead of failing immediately.
- Stale lock after a crash → `terraform force-unlock LOCK_ID` (only when certain nothing is running). `force-unlock` only removes **the lock**; it doesn't touch resources.
- Without locking: two concurrent applies can both read serial 7, both write serial 8 →
  lost updates, orphaned resources, corrupted state.

### C5. State security
- State contains **every attribute** — DB passwords, private keys from `tls_private_key`,
  generated `random_password` results — **in plaintext**, even if marked `sensitive`.
- Therefore: remote backend with **encryption at rest** (S3 SSE-KMS), TLS in transit,
  **least-privilege access** to the state bucket/workspace, **versioning** for recovery,
  never commit state to Git (`.gitignore`: `*.tfstate`, `*.tfstate.*`, `.terraform/`).
- Plan files (`-out`) also contain sensitive values.
- Newer mitigation: **ephemeral** values/resources and **write-only arguments** (1.10/1.11+)
  keep certain secrets out of state and plan entirely.
- HCP Terraform encrypts state at rest and controls access per workspace/team.

### C6. `terraform state` subcommands

| Command | What it does | Changes infra? | Risk |
|---|---|---|---|
| `state list [ADDR]` | List resource addresses in state (filterable: `state list module.vpc`) | No | None |
| `state show ADDR` | All attributes of one instance | No | Shows sensitive values |
| `state mv SRC DST` | Rename/move an object's address in state (rename, into/out of module, between count/for_each keys) | No | Wrong mapping → next plan destroys/creates |
| `state rm ADDR` | Forget an object (it keeps existing) | No | If block remains, next plan **creates** a duplicate |
| `state pull` | Print current (remote) state to stdout | No | Contains secrets |
| `state push FILE` | Overwrite remote state with a local file | No | **Very dangerous**; guarded by lineage/serial checks; `-force` bypasses |
| `state replace-provider FROM TO` | Change provider source for resources in state (e.g. after a provider moved namespace) | No | Low if correct |

All of them write a backup when they modify state (e.g. `terraform.tfstate.<timestamp>.backup` for local state; `-backup=PATH` to control). Plus `terraform show` (whole state) and
`terraform output`.

```bash
terraform state list
terraform state show 'aws_subnet.private["a"]'
terraform state mv aws_instance.web aws_instance.app
terraform state mv aws_vpc.main module.network.aws_vpc.this
terraform state rm aws_s3_bucket.legacy
terraform state pull > backup-$(date +%F).tfstate
```

### C7. Declarative alternatives (preferred — reviewable in plans and PRs)

**`moved` block (1.1+)** — rename without destroy:
```hcl
moved {
  from = aws_instance.web
  to   = aws_instance.app
}
moved {
  from = aws_iam_user.u[0]
  to   = aws_iam_user.u["alice"]      # count → for_each migration
}
moved {
  from = aws_vpc.main
  to   = module.network.aws_vpc.this  # refactor into module
}
```
Plan shows `# aws_instance.web has moved to aws_instance.app` with no destroy. Keep `moved`
blocks for a while (module consumers may still be on old addresses), then remove.

**`removed` block (1.7+)** — stop managing without destroying:
```hcl
removed {
  from = aws_s3_bucket.legacy
  lifecycle {
    destroy = false          # forget, don't delete (like state rm, but via plan)
  }
}
```
(Delete the `resource` block itself; the `removed` block replaces it.)

**`import` block (1.5+)** — see C8.

| Goal | CLI (immediate, unreviewed) | Config block (planned, reviewable) |
|---|---|---|
| Rename address | `state mv` | `moved` |
| Forget object | `state rm` | `removed { lifecycle { destroy = false } }` |
| Adopt existing object | `terraform import` | `import { }` |
| Force recreate | `taint` (deprecated) | `-replace` flag (CLI) / `replace_triggered_by` (config) |

### C8. Importing existing infrastructure (7a)

Scenario: the 3-tier app's RDS instance was created by hand during a hotfix. You want
Terraform to manage it **without recreating** it.

**Config-driven (1.5+, recommended)**
```hcl
import {
  to = aws_db_instance.main
  id = "three-tier-prod-db"          # provider-specific import ID — check each resource's docs
}
```
```bash
terraform plan -generate-config-out=generated.tf   # writes a resource block for you
# review/clean generated.tf (remove computed/conflicting args, add variables)
terraform plan                                     # expect: "1 to import, 0 to add, 0 to change"
terraform apply
```
- `import` blocks can use `for_each` (1.7+) to import many.
- After a successful import, the `import` block can be removed (or left; it's idempotent).
- Generated config is a starting point; **review it**.

**CLI (all versions)**
```bash
# resource block must ALREADY exist in config
terraform import aws_db_instance.main three-tier-prod-db
terraform plan     # adjust config until no changes
```
- `terraform import` writes to state immediately — no plan, no generated config.
- One resource per command. Module address works: `terraform import module.db.aws_db_instance.this id`.

Import never creates or changes the real object. If config differs from reality, the
**next plan** proposes updates (or replacement!) — always plan after importing.

The import **ID format is provider-specific** (bucket name for S3, `i-…` for EC2,
`sg-…`, or composite like `role-name/policy-arn` for attachments).

### C9. Drift and refresh (6d)

| Situation | What `plan` shows | Typical fix |
|---|---|---|
| Attribute changed outside Terraform | "Objects have changed outside of Terraform" + update to revert | apply (enforce) / edit config (accept) / ignore_changes |
| Object deleted outside Terraform | refresh drops it from state → plan to **create** | apply recreates; or remove from config |
| Object created outside Terraform | Nothing — Terraform doesn't know about it | `import` it |
| You want state to record reality without changing infra | — | `terraform apply -refresh-only` |

### C10. Scenarios

**Lost local state** (laptop died, no backup)
1. Don't apply! The plan would create duplicates/collide.
2. Recreate state by importing each resource (import blocks + `for_each` help), or restore from a backup / versioned bucket.
3. Lesson: remote backend with versioning.

**Accidental `state rm`** — object still exists, unmanaged. Fix: `import` it back (or restore the backup file written by the command).

**Rename a resource** — `moved` block (or `state mv`). Renaming the block *without* either →
plan shows destroy old + create new.

**Moving into a module** — `moved { from = aws_vpc.main  to = module.network.aws_vpc.this }`.

**Concurrent runs** — locking prevents the second; if a crash leaves a lock, verify, then `force-unlock`.

**Corrupted remote state** — restore an earlier version (S3 versioning / HCP Terraform state
versions) via `state push` of a pulled-and-verified good copy, carefully.

### C11. State migration (backend change)

```bash
# 1. edit backend block (e.g. local → s3)
# 2.
terraform init -migrate-state
#   "Do you want to copy existing state to the new backend?"  yes
# 3. verify
terraform state list
terraform plan        # expect: No changes
# 4. remove local terraform.tfstate* only after verification
```
- `-migrate-state` copies; `-reconfigure` starts fresh at the new location (no copy).
- With workspaces, all workspaces' states are migrated.
- Going back to local: remove the backend block, `init -migrate-state`.
- Moving to HCP Terraform: add a `cloud` block, `terraform login`, `terraform init` (offers migration).

### C12. `terraform_remote_state` and sharing outputs

```hcl
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "jk-tfstate"
    key    = "network/terraform.tfstate"
    region = "eu-west-2"
  }
}
# use: data.terraform_remote_state.network.outputs.vpc_id
```
- Reads only **root-level outputs** of another state.
- Requires read access to the **entire** state snapshot (security concern). Alternatives:
  provider data sources (`aws_vpc` by tag), SSM parameters, or HCP Terraform's
  `tfe_outputs` data source.

---

## D. Why it matters

State mistakes are the #1 way Terraform users destroy production. The exam has many state
scenarios: what each `state` command does to real infra (nothing!), backend restrictions,
locking, import steps, and drift handling. Your S3 + CloudFront project almost certainly
used an S3 backend — today you learn exactly what it's doing.

---

## E. Reference — error messages you should recognise

| Message (abridged) | Meaning / fix |
|---|---|
| `Error acquiring the state lock` | Another run holds it; wait, or `force-unlock` if stale |
| `Backend configuration changed` | Run `terraform init` (`-migrate-state` / `-reconfigure`) |
| `Variables may not be used here` (in backend) | Use partial config `-backend-config` |
| `Resource already managed by Terraform` (import) | Address already in state |
| `Cannot import non-existent remote object` | Wrong ID / region / account |
| `Saved plan is stale` | State changed since plan; re-plan |
| `state snapshot was created by Terraform vX, which is newer` | Upgrade CLI; state format versions only move forward |
| `Failed to push: lineage mismatch` | You're pushing state from another configuration's history |

---

## F. Worked example — refactor without destroying

Start:
```hcl
resource "terraform_data" "web" { input = "v1" }
```
Goal: rename to `app` and move into a for_each map keyed `"blue"`.

```hcl
resource "terraform_data" "app" {
  for_each = { blue = "v1" }
  input    = each.value
}

moved {
  from = terraform_data.web
  to   = terraform_data.app["blue"]
}
```
Plan:
```
  # terraform_data.web has moved to terraform_data.app["blue"]
    resource "terraform_data" "app" {
        id     = "..."
        # (2 unchanged attributes hidden)
    }

Plan: 0 to add, 0 to change, 0 to destroy.
```
Without the `moved` block: `1 to add, 0 to change, 1 to destroy`.

---

## G. Visual — state architecture in a team

```
 dev laptop ─┐                                  ┌──────────────────────────────┐
             │ terraform plan/apply             │   S3 bucket (versioned, KMS) │
 CI runner ──┼─────────────────────────────────►│   key: app/prod.tfstate      │
             │      1. acquire lock ───────────►│   lockfile / DynamoDB item   │
 teammate ───┘      2. read state               └──────────────────────────────┘
                    3. refresh via providers ───► AWS APIs
                    4. write state (serial+1)
                    5. release lock
```

---

## H. Common misconceptions

| # | Misconception | Reality |
|---|---|---|
| 1 | "`state rm` deletes the resource." | It only forgets it. |
| 2 | "`state mv` renames the cloud resource." | It only changes the Terraform address in state. |
| 3 | "`sensitive` keeps secrets out of state." | Plaintext in state. Ephemeral/write-only features do that. |
| 4 | "Backends can use variables." | No — literals or `-backend-config`. |
| 5 | "`terraform import` generates config." | CLI import doesn't; `plan -generate-config-out` with import blocks does. |
| 6 | "Import means Terraform will now leave it alone." | Next plan reconciles to config — may modify/replace it. |
| 7 | "All backends support locking." | Most do; some don't (e.g. some `http` servers). |
| 8 | "`force-unlock` fixes a broken apply." | It removes a lock only. |
| 9 | "`-reconfigure` moves my state." | It doesn't copy; `-migrate-state` does. |
| 10 | "Terraform finds my resources by tag." | Only via state. |

---

## I. Exam traps
- "Rename resource without destroying — which TWO?" → `moved` block, `terraform state mv`.
- "Stop managing but keep it" → `state rm` or `removed` + `destroy = false`. *Not* `destroy`.
- "Where is state stored by default?" → `terraform.tfstate` in working dir.
- "Which is true about remote state?" → enables team collaboration + locking; doesn't remove secrets.
- `terraform_remote_state` reads **outputs**, not arbitrary resource attributes.
- Data sources are recorded in state too (mode `data`).

**More traps from the original notes**
- **The local backend does lock, but only on that one machine** (an OS file lock). It doesn't
  protect teammates on other machines, and it's a single point of failure. (The original notes
  said "no locking at all", which is not quite right.)
- **S3 native locking needs Terraform 1.10+**; enable bucket **versioning** anyway, so you can
  recover old state versions. The DynamoDB pattern is still valid but on its way out.
- **Bare `terraform refresh` is deprecated**; the recommended form is
  `plan/apply -refresh-only`.

---

## J. Active recall
1. Four purposes of state.
2. What do `serial` and `lineage` protect against?
3. Write a `moved` block renaming `aws_s3_bucket.a` to `aws_s3_bucket.b`.
4. Two ways to adopt an existing bucket into state.
5. Why can't the backend block use `var.bucket`?
6. Command to copy state when switching from local to S3?

<details><summary>Answers</summary>

1. Mapping to real objects, metadata (deps etc.), performance (caching), team sync.
2. `serial`: stale/out-of-order writes; `lineage`: mixing states of different histories.
3. `moved { from = aws_s3_bucket.a  to = aws_s3_bucket.b }`
4. `import` block + plan/apply; `terraform import ADDR ID`.
5. The backend is initialised before variables are evaluated; use partial configuration.
6. `terraform init -migrate-state`.
</details>

---

## K. Practice exercises

**K1.** A colleague ran `terraform state rm aws_db_instance.main` "to fix an error" and then
`terraform apply`. The config still contains the resource block. What happened?

**K2.** You split a monolith config: networking moves to a new configuration with its own
state. How do you move `aws_vpc.main` without destroying it? (Two configs, two states.)

**K3.** Order these for a safe import: (a) write resource block / generate config, (b)
apply, (c) add import block, (d) plan and confirm "1 to import, 0 to change", (e) remove
import block.

**K4.** CI fails: `Error acquiring the state lock`, lock created 3 hours ago by a runner that
was cancelled. What do you check before acting, and what do you run?

**K5.** True/False: running `terraform plan` with a remote S3 backend writes the refreshed
state back to S3.

<details><summary>Answers</summary>

**K1.** State forgot the DB; plan proposed **creating** a new `aws_db_instance.main` →
apply either created a second DB, or failed because the identifier already exists. Fix:
`state rm`/destroy any duplicate as appropriate, then import the original.

**K2.** Options: (1) in the new config add `import` block for the VPC; in the old config
add `removed { from = aws_vpc.main lifecycle { destroy = false } }`; apply both. (2) CLI:
`terraform import` in new, `terraform state rm` in old. (`state mv -state-out` between
local files exists but is legacy and awkward with remote backends.)

**K3.** c → a → d → b → e (adding the import block first lets `-generate-config-out` write the block).

**K4.** Confirm no runner/person is actually running (CI dashboard, lock info "Who/Operation/Created"); then `terraform force-unlock <ID>`; then `plan` to check state integrity.

**K5.** False — plan refreshes in memory only.
</details>

> Optional real-cloud practice: [AWS lab A6 — remote S3 backend, drift and state commands](../labs/aws-optional/README.md#a6--remote-state-drift-and-state-commands-day-5) and [A7 — import](../labs/aws-optional/README.md#a7--import-logging-and-cli-workspaces-days-5-6).

---

## L. Lesson assessment — mastery quiz

Closed book. Write every answer down **before** opening the answers, and give each a confidence (1 = guess, 2 = unsure, 3 = sure). Pass mark: **9/11**. Record the score in [SCORECARD.md](../SCORECARD.md) and log misses in [mistakes/error-log.md](../mistakes/error-log.md).

*These questions are the self-test questions from the original 15-day notes, corrected and regrouped by topic.*

1. What problem does state locking solve, and what goes wrong without it?
2. What must you run after editing the `backend` block?
3. From Terraform 1.10, what lets the S3 backend lock without DynamoDB, and which argument enables it?
4. What should be enabled on the state bucket itself, and why?
5. How does `terraform apply -refresh-only` differ from a normal apply?
6. Which command renames a resource in state without recreating it, and what's the config equivalent?
7. Does `terraform state rm` delete the real resource?
8. Why is the local backend risky for a team of five?
9. Is bare `terraform refresh` the recommended way to sync drift?
10. Does classic `terraform import` generate `.tf` configuration?
11. What is the config-generating alternative?

<details><summary>Answers</summary>

1. It stops two operations writing state at the same time. Without it, both can read the same serial and the last write silently overwrites the other, leaving lost updates or orphaned resources.
2. `terraform init`, which offers to migrate state; or explicitly `-migrate-state` / `-reconfigure`.
3. S3 conditional writes create a lock object; enable with `use_lockfile = true`.
4. Versioning, so earlier state versions can be recovered. Server-side encryption too, because state holds secrets.
5. It updates state to match real infrastructure without changing infrastructure. A normal apply changes infrastructure to match config.
6. `terraform state mv`; the config equivalent is a `moved` block.
7. No. Terraform just forgets it. If the block is still in config, the next plan proposes creating a duplicate.
8. State lives on one machine: no shared source of truth, no locking across machines, and a lost or corrupted file loses Terraform's record.
9. No. It's deprecated; use `terraform plan -refresh-only` to preview and `apply -refresh-only` to accept.
10. No. It only writes state, and the resource block must already exist.
11. An `import { to = ADDR  id = "..." }` block plus `terraform plan -generate-config-out=FILE` (1.5+).
</details>

## M. Summary
- State = mapping + metadata + performance + sync. JSON, never hand-edit.
- Local backend default; remote backends for teams; one backend; no variables; partial config via `-backend-config`.
- Locking prevents concurrent writes; `force-unlock` removes stale locks only.
- Secrets are plaintext in state → encrypt, restrict, version, never commit.
- `state list/show` read; `mv/rm/push/replace-provider` modify state only, never infra.
- Prefer `moved`, `removed`, `import` blocks (reviewed in plan).
- Import: block + `-generate-config-out`, or CLI `import` (block must exist). Always plan after.
- Migration: `init -migrate-state`; verify with `plan` = no changes.

### Flashcards (Day 5)
| Front | Back |
|---|---|
| State purposes | mapping, metadata, performance, sync |
| `serial` / `lineage` | write counter / unique state history ID |
| Backend block variables? | Not allowed → `-backend-config` partial config |
| `state rm` effect on infra | none — object becomes unmanaged |
| `state mv` effect on infra | none — address change only |
| Rename without destroy (config) | `moved` block |
| Forget without destroy (config) | `removed { lifecycle { destroy = false } }` |
| Generate config for imports | `terraform plan -generate-config-out=FILE` |
| CLI import prerequisite | resource block must already exist |
| Copy state to new backend | `terraform init -migrate-state` |
| Stale lock | `terraform force-unlock LOCK_ID` |
| S3 native locking arg | `use_lockfile = true` (1.10+) |
| `terraform_remote_state` reads | root outputs of another state |

## N. Mastery decision
10–12 ✅ · 8–9 ➕ redo K + Lab 08 part 3 · ≤7 🔁 re-teach C6–C11 next morning.
