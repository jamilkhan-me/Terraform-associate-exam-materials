# Day 8 — Advanced Troubleshooting and Mixed Scenarios

**Objectives covered:** all, with emphasis on 3d, 4b, 4f, 6d, 7b, 7c
**Labs:** [Lab 12](../labs/lab-12/README.md) (broken configs), finish [Lab 07](../labs/lab-07/README.md)

---

## A. Learning objectives

1. Classify an error by **phase**: init, validate, plan, apply, state/backend.
2. Read a plan precisely: action symbols, `(known after apply)`, `# forces replacement`, drift notices, summary line.
3. Diagnose provider, reference, type, dependency, module, variable, backend, and locking errors.
4. Choose the **safest** corrective action and reject plausible-but-dangerous ones.
5. Combine concepts across domains in multi-step scenarios.

---

## B. Plain-English explanation

Troubleshooting is mostly answering two questions:
1. **When** did it fail? (Each phase can only fail for certain reasons.)
2. **Which of the three worlds** disagrees? (Config, state, reality.)

Then pick the least destructive action that restores agreement.

---

## C. Technical deep dive

### C1. Phase map

```
 init ──────────► validate ─────────► plan ──────────────────► apply ──────────► (state)
 ▲ provider       ▲ syntax            ▲ credentials/API        ▲ API errors          ▲ lock
 │ not found      │ undeclared ref    │ refresh failures       │ quotas, perms       │ lineage
 │ version        │ wrong types       │ data source not found  │ name conflicts      │ backend
 │ conflict       │ missing args      │ for_each unknown keys  │ timeouts            │ changed
 │ module source  │ unsupported arg   │ cycle                  │ provisioner fail    │ stale plan
 │ backend auth   │ duplicate block   │ prevent_destroy        │ eventual consistency│
 │ lockfile       │                   │ validation/precond.    │ postcondition fail  │
```

### C2. Error catalogue

| # | Message (abridged) | Phase | Cause | Safe fix |
|---|---|---|---|---|
| 1 | `Failed to query available provider packages` | init | No network/registry access, wrong source, typo | Check `source`, network/mirror |
| 2 | `Could not retrieve the list of available versions… no available releases match the given constraints` | init | Conflicting constraints (root vs module) | Align constraints; `terraform providers` shows who requires what |
| 3 | `the cached package … does not match any of the checksums recorded in the dependency lock file` / `Inconsistent dependency lock file` | init/plan | Lock file vs installed/changed constraints, or platform hash missing | `terraform init` / `init -upgrade`; `providers lock -platform=…` |
| 4 | `Module not installed` | validate/plan | New module | `terraform init` |
| 5 | `Reference to undeclared resource / input variable` | validate | Typo or missing declaration | Declare / fix name |
| 6 | `Unsupported argument` / `An argument named "x" is not expected here` | validate | Wrong arg name for resource or module | Check schema / child variables |
| 7 | `Missing required argument` | validate | Required arg missing | Add it |
| 8 | `Inappropriate value for attribute "x": string required` | validate/plan | Type mismatch | Convert / fix type |
| 9 | `Invalid for_each argument … unknown values` | plan | Keys depend on apply-time values | Use static keys |
| 10 | `Cycle: a, b` | plan/validate | Mutual references | Break the cycle (separate rule resources, refactor) |
| 11 | `No valid credential sources found` / `ExpiredToken` | plan | Provider auth | Fix creds/env/role; `TF_LOG=DEBUG` |
| 12 | `Error acquiring the state lock` | any locking op | Concurrent run / stale lock | Wait, `-lock-timeout`, verify then `force-unlock` |
| 13 | `Backend initialization required` / `Backend configuration changed` | plan | Backend block edited | `init -migrate-state` or `-reconfigure` |
| 14 | `Saved plan is stale` | apply | State changed after plan | Re-plan |
| 15 | `Instance cannot be destroyed` | plan | `prevent_destroy` | Rethink change; deliberate removal of protection |
| 16 | `Resource precondition failed` / `postcondition failed` | plan/apply | Custom condition | Fix input/data |
| 17 | `Invalid value for variable` | plan | `validation` | Supply valid value |
| 18 | `Error: creating … AlreadyExists / BucketAlreadyOwnedByYou` | apply | Object exists outside state | **Import** it (don't delete it) |
| 19 | `Output refers to sensitive values` | plan | Missing `sensitive = true` | Mark output sensitive |
| 20 | `Provider configuration not present` | plan | Resource in state whose provider config was removed (e.g. removed module with own provider) | Restore provider config, then remove resource |
| 21 | `Variables may not be used here` | init | Var in backend block | Partial config |
| 22 | `Unsupported Terraform Core version` | init | `required_version` excludes CLI | Install suitable version |

### C3. Reading plans like an examiner

```
Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create
  ~ update in-place
  - destroy
-/+ destroy and then create replacement

Note: Objects have changed outside of Terraform           ← DRIFT detected during refresh
  # aws_security_group.web has changed
  ~ tags = { "Owner" = "ops" -> null ... }

Terraform will perform the following actions:

  # aws_instance.web must be replaced
-/+ resource "aws_instance" "web" {
      ~ ami        = "ami-111" -> "ami-222" # forces replacement
      ~ id         = "i-0abc" -> (known after apply)
      ~ public_ip  = "3.1.1.1" -> (known after apply)
        tags       = { "Name" = "web" }
    }

  # aws_security_group.web will be updated in-place
  ~ resource "aws_security_group" "web" {
      ~ tags = { + "Owner" = "ops" }                     ← revert drift to match config
    }

Plan: 1 to add, 1 to change, 1 to destroy.
```
Reading rules:
- A replacement counts as **1 add + 1 destroy** in the summary.
- `(known after apply)` = value computed by provider; anything depending on it is also unknown.
- "Objects have changed outside of Terraform" is **informational** — what changed in reality; the action list says what Terraform will *do*.
- `# (N unchanged attributes hidden)` — normal.
- `must be replaced` + `# forces replacement` shows **which attribute** forced it.
- `will be read during apply` / `<= data` — a data source depends on unknown values.

### C4. Safest-action reasoning

Ranking from safest to riskiest when state/reality disagree:

```
 1. Read-only investigation:  plan, state list/show, show, TF_LOG, console
 2. Reviewed config change:   edit .tf, moved/removed/import blocks → plan → apply
 3. State-only, reversible:   apply -refresh-only, state mv (with backup)
 4. State-only, risky:        state rm, force-unlock (verify first!)
 5. Dangerous:                state push, -target applies, -lock=false, manual state edits
 6. Destructive:              destroy, -replace on stateful resources (DBs)
```
Exam heuristic: when asked "what should you do **first**" or "**safest**", choose the
least-destructive option that actually solves the stated problem.

### C5. Mixed scenarios (worked)

**S1. "Terraform wants to destroy and recreate our RDS instance after we refactored into a module."**
Diagnosis: address changed (`aws_db_instance.main` → `module.db.aws_db_instance.this`).
Fix: `moved` block. Wrong answers: `-target`, `ignore_changes`, `prevent_destroy` (would
just make the plan fail — it's a safety net, not a fix).

**S2. "Apply failed halfway: 6 of 10 resources created."**
State already includes the 6. Fix the cause and re-run `apply` — it creates the remaining 4.
Wrong: `destroy` and start over; manually editing state.

**S3. "`terraform plan` works on my laptop but CI says provider version doesn't match lock file."**
CI probably has a different platform and the lock file lacks its hash, or someone changed a
constraint without updating the lock. Fix: `terraform providers lock -platform=linux_amd64 …`
and commit; or `init -upgrade` deliberately and commit.

**S4. "Plan shows a resource will be created, but we know it exists."**
Either state lost track (deleted out of band, `state rm`, new workspace/backend key) or
it was created outside Terraform. Check `terraform workspace show`, backend key, `state list`.
Fix: correct workspace/backend, or import.

**S5. "Every plan shows a change to the `tags` attribute, then apply, then the same change again."**
Something external rewrites the value (another tool, provider normalisation, `timestamp()`
in config). Fix: remove non-deterministic functions, align value formatting, or `ignore_changes`.

**S6. "Two engineers applied at the same time; now resources are duplicated."**
Backend without locking or `-lock=false` used. Fix: identify duplicates, import/remove
appropriately; move to a locking backend; never disable locks.

**S7. "We removed a module whose resources must be deleted, but plan errors `Provider configuration not present`."**
The module contained its own provider block (anti-pattern). Fix: restore the module/provider
block, run `destroy -target=module.x` (or remove resources first), then delete the module.

### C6. Debugging toolkit
```bash
terraform validate -json
terraform plan -no-color > plan.txt
terraform show -json tfplan | jq '.resource_changes[] | {addr: .address, actions: .change.actions}'
terraform state list | grep db
terraform console          # evaluate the suspicious expression
TF_LOG=DEBUG TF_LOG_PATH=debug.log terraform plan
terraform providers        # who requires which provider/version
terraform graph | dot -Tsvg > graph.svg
```

---

## D. Why it matters
The exam's hardest questions combine two or three concepts and offer several "true but
wrong" fixes. Real incidents are the same.

## E. Quick reference — error → first command
| Symptom | First command |
|---|---|
| Unexplained provider error | `TF_LOG=DEBUG terraform plan` |
| "Will be created" but exists | `terraform workspace show`, `terraform state list` |
| Unexpected destroy | Read `# forces replacement` / check address changes → `moved` |
| Lock error | read lock info → wait → `force-unlock` |
| Type error | `terraform console` → `type(expr)` |
| Constraint conflict | `terraform providers` |

## F. Worked example — find all five bugs
```hcl
terraform {
  backend "local" {
    path = var.state_path
  }
}

variable "names" {
  type    = list(string)
  default = ["a", "b"]
}

resource "terraform_data" "item" {
  for_each = var.names
  input    = each.value
}

output "ids" {
  value = terraform_data.item[*].id
}

resource "terraform_data" "x" {
  input = terraform_data.y.output
}
resource "terraform_data" "y" {
  input = terraform_data.x.output
}
```
<details><summary>Answers</summary>

1. `var.state_path` in backend → "Variables may not be used here"; use a literal or `-backend-config`.
2. `for_each = var.names` is a list → `toset(var.names)`.
3. `terraform_data.item[*].id` — splat on a for_each map doesn't give the list you expect; use `[for i in terraform_data.item : i.id]` or `values(terraform_data.item)[*].id`.
4. `x` ↔ `y` reference each other → **Cycle**.
5. (Design) `state_path` variable also never declared — "Reference to undeclared input variable" would be next once (1) is reported.
</details>

## G. Visual — triage flowchart
```
 Error appears
   │
   ├─ during init?  → source/version/network/backend/lockfile
   ├─ during validate? → names, types, args, references
   ├─ during plan?  → credentials, data sources, for_each/count unknowns, conditions, cycle, lock
   ├─ during apply? → API: permissions, quotas, conflicts → fix & re-apply (state keeps progress)
   └─ unexpected plan contents?
         ├─ create but exists → wrong workspace/backend? state lost? → import
         ├─ destroy/replace unexpected → address changed? (moved) ForceNew attr? (read plan)
         └─ perpetual diff → non-deterministic expr / external writer → fix or ignore_changes
```

## H. Common misconceptions
| # | Misconception | Reality |
|---|---|---|
| 1 | "A failed apply is rolled back." | No rollback; partial state is kept. |
| 2 | "`-target` is the standard fix for a stuck plan." | Exceptional only; fix root cause. |
| 3 | "`ignore_changes` fixes renamed addresses." | Address changes need `moved`. |
| 4 | "`validate` would have caught the API permission error." | Validate never calls APIs. |
| 5 | "Delete the lock file to fix provider errors." | Regenerate deliberately; it protects reproducibility. |
| 6 | "Drift notice means Terraform will change those things." | It reports reality changes; the action list is what will happen. |

## I. Exam traps
- "Which is the FIRST thing to do?" — investigation (plan/logs) often beats action.
- An option that "works" but is destructive (destroy & recreate DB) is rarely correct when a non-destructive option exists.
- "Apply failed; what is the state of the resources that succeeded?" → recorded in state, exist.

## J. Active recall
1. Name three errors only possible at init.
2. What does a replacement count as in the plan summary?
3. What causes "Invalid for_each argument … unknown values"?
4. Safest fix for an unexpected destroy after a rename?

<details><summary>Answers</summary>

1. Provider not found/version constraint unsatisfiable, module source not found, backend init/auth error (also required_version mismatch).
2. One add and one destroy.
3. for_each keys depending on values only known after apply.
4. A `moved` block (then plan shows a move, not destroy/create).
</details>

## K. Practice — mixed gauntlet (write your answers first)
1. `terraform apply` → `Error: creating S3 Bucket (jk-logs): BucketAlreadyOwnedByYou`. Config has `aws_s3_bucket.logs`. What happened and what do you do?
2. After `terraform init -upgrade`, plan shows lots of attribute changes nobody made. Why might that be, and what's the safe response?
3. Plan says `module.app.aws_lb.this` will be destroyed; the module call was renamed `module "application"`. Fix?
4. `terraform plan` hangs, then says lock acquisition failed after 0s. Teammate's apply is running. Correct action?
5. You set `TF_LOG_PATH=log.txt` but no file appears. Why?

<details><summary>Answers</summary>

1. Bucket exists (created before, or state lost). Import it: `import { to = aws_s3_bucket.logs id = "jk-logs" }` → plan → apply.
2. The new provider version may normalise attributes differently or change defaults. Review the plan carefully; pin back to the previous version (edit constraint, `init -upgrade`) if unsure; read the provider's upgrade notes before applying.
3. `moved { from = module.app  to = module.application }` (whole-module move).
4. Wait for the teammate to finish (or use `-lock-timeout`); never force-unlock an active lock.
5. `TF_LOG` must also be set.
</details>

## L. Lesson assessment
Error-diagnosis gauntlet, 11 items, closed book: the 5 K questions above (answered *before*
opening the answers) plus the 6 broken configurations in [Lab 12](../labs/lab-12/README.md), each diagnosed
and fixed without opening `SOLUTION.md`. Pass **9/11**. Log every miss in
[mistakes/error-log.md](../mistakes/error-log.md).

## M. Summary
- Locate the phase; locate the disagreeing world (config/state/reality).
- Read plans: symbols, forces replacement, known after apply, drift notes, summary math.
- Prefer investigation → reviewed config change → state-only operations → destructive actions.

### Flashcards (Day 8)
| Front | Back |
|---|---|
| Failed apply recovery | Fix cause, re-run apply (no rollback) |
| "AlreadyExists" on create | Import the existing object |
| Unexpected destroy after rename | `moved` block |
| Replace in summary | 1 add + 1 destroy |
| Perpetual diff causes | timestamp()/uuid(), external writer, normalisation |
| Who requires which provider | `terraform providers` |

## N. Mastery decision
12–15 ✅ · 9–11 ➕ redo Lab 12 · ≤8 🔁 revisit Day 5 and Day 3 weak sections.
