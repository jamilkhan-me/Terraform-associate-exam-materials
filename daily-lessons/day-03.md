# Day 3 — Terraform CLI and the Core Workflow

**Objectives covered:** 3a–3g, 7c (logging), plus supporting commands
**Labs:** revisit [Lab 01](../labs/lab-01/README.md) with flags; start [Lab 07](../labs/lab-07/README.md)

---

## A. Learning objectives

1. For every exam-relevant command: purpose, prerequisites, side effects, key flags.
2. Explain exactly what `init` does on first run, on re-run, and with `-upgrade`, `-reconfigure`, `-migrate-state`, `-backend=false`.
3. Distinguish `plan`, `plan -out`, `apply`, `apply PLANFILE`, `apply -refresh-only`, `plan -destroy`, `destroy`.
4. Explain why `terraform refresh` is deprecated and what replaced it.
5. Explain why `taint` is deprecated and what replaced it (`-replace`).
6. Use `fmt`, `validate`, `console`, `show`, `output`, `graph`, `providers`, `version`, `get`, `login`/`logout`, `force-unlock`, `workspace`, `test` (recognition).
7. Configure verbose logging with `TF_LOG` and related variables.

---

## B. Plain-English explanation

There are ~25 Terraform commands, but the exam cares about a dozen deeply. Group them:

```
SET UP          WRITE/CHECK       CHANGE                  INSPECT              MAINTAIN
init            fmt               plan                    show                 state *
get             validate          apply                   output               import
login/logout    console           destroy                 graph                force-unlock
providers lock  test                                      providers            workspace *
                                                          version
```

---

## C. Technical deep dive

### C1. `terraform init`

Run it: first time in a directory; after adding/changing providers, modules, or backend
config; after cloning a repo. It is **safe to run repeatedly** (idempotent).

What it does:
1. **Backend initialisation** — configures where state lives; may offer to migrate state.
2. **Child module installation** — downloads modules into `.terraform/modules/`.
3. **Provider installation** — resolves versions against constraints and the lock file,
   downloads into `.terraform/providers/`, verifies checksums.
4. **Writes/updates `.terraform.lock.hcl`** (providers only — modules are not locked).

| Flag | Effect |
|---|---|
| `-upgrade` | Ignore the lock file selection; pick the newest provider versions allowed by constraints; re-fetch modules to newest matching versions |
| `-reconfigure` | Reconfigure backend ignoring saved config; **does not migrate** existing state |
| `-migrate-state` | Reconfigure backend and copy state from old backend to new |
| `-backend=false` | Skip backend init (useful in CI just to `validate`) |
| `-backend-config=FILE or KEY=VALUE` | Supply partial backend settings (secrets, per-env bucket) |
| `-input=false` | Never prompt (CI) |
| `-get=false` | Skip module installation |
| `-lockfile=readonly` | Fail rather than modify the lock file |

Directory after init:
```
.
├── main.tf
├── .terraform/                 # DO NOT commit: providers, modules, backend metadata
│   ├── providers/registry.terraform.io/hashicorp/aws/5.x.y/linux_amd64/...
│   ├── modules/modules.json
│   └── terraform.tfstate       # backend config cache (NOT your resource state)
└── .terraform.lock.hcl         # DO commit
```

### C2. `terraform fmt`
- Rewrites `.tf` and `.tfvars` files in the **current directory** to canonical style
  (2-space indent, aligned `=`).
- `-recursive` (subdirectories), `-check` (exit non-zero if changes needed, don't write —
  CI), `-diff` (show changes), `-write=false`.
- Purely stylistic. No init needed. Never changes meaning.

### C3. `terraform validate`
- Checks syntax, valid references, argument names/types against **provider schemas**,
  required arguments, variable type defaults, etc.
- Needs providers installed (so `init` first; `init -backend=false` is enough).
- Does **not** access state, the backend, or remote APIs. Does not check that an AMI ID
  exists or that you have permissions.
- `-json` for machine-readable output.

### C4. `terraform plan`
- Steps: read state → **refresh** (query providers for current values) → compare to config →
  print proposed actions. Changes nothing (state included).
- Exit codes with `-detailed-exitcode`: `0` no changes, `1` error, `2` changes present (CI
  drift detection!).

| Flag | Effect |
|---|---|
| `-out=FILE` | Save the plan (binary, contains values — **may contain secrets**) |
| `-destroy` | Plan to destroy everything |
| `-refresh-only` | Plan only to update state to match reality |
| `-refresh=false` | Skip refresh (faster; trusts state; risky) |
| `-replace=ADDR` | Force replacement of a resource |
| `-target=ADDR` | Limit to a resource and its dependencies — **exceptional use only** |
| `-var`, `-var-file` | Input variables |
| `-lock=false`, `-lock-timeout=60s` | Locking behaviour |
| `-parallelism=N` | Concurrent operations (default 10) |
| `-generate-config-out=FILE` | With `import` blocks, write HCL for imported resources |

Plan symbols:
```
  +   create
  -   destroy
  ~   update in-place
 -/+  destroy then create (replace)          # default replacement order
 +/-  create then destroy (replace)          # with create_before_destroy
 <=   read (data source, deferred to apply)
  # forces replacement   ← annotation on the attribute causing it
```

### C5. `terraform apply`
- Without a plan file: makes a fresh plan, shows it, prompts for `yes`, executes.
- With a plan file `terraform apply tfplan`: **no prompt**, executes exactly that plan;
  refuses if the state has changed since the plan was created ("Saved plan is stale").
- `-auto-approve` skips the prompt (CI only, ideally after a reviewed plan).
- Accepts all plan flags (`-replace`, `-target`, `-var`, `-refresh-only`, `-destroy`).
- **Partial failure**: resources already created stay in state; the failed one is
  reported; re-running apply continues. Terraform does **not** roll back.
- A resource whose creation succeeded but a **creation-time provisioner** failed is marked
  **tainted** → replaced on next apply.

### C6. `terraform destroy`
- Alias of `terraform apply -destroy`. Prompts; destroys everything **tracked in state**
  for this configuration/workspace in reverse dependency order.
- Preview with `terraform plan -destroy`.
- Blocked by `lifecycle { prevent_destroy = true }` (error, nothing destroyed).
- Does not touch objects that aren't in state.
- To destroy one resource: remove it from config and apply (preferred), or `destroy -target=ADDR` (exceptional).

### C7. Refresh, then and now
| Old | Now | Notes |
|---|---|---|
| `terraform refresh` | `terraform apply -refresh-only` | `refresh` still exists but is **deprecated**: it overwrites state with no review. `-refresh-only` shows what changed and asks for approval. |
| `terraform plan -refresh-only` | — | Preview what refresh would record |
| `terraform taint ADDR` | `terraform apply -replace=ADDR` | `taint` deprecated (0.15.2+): marks in state; `-replace` shows it in the plan first |
| `terraform untaint ADDR` | still exists | remove taint mark |

Refresh-only **only changes state**, never infrastructure. If reality drifted, refresh-only
accepts reality into state; the next normal plan will then propose to change
infrastructure back to match configuration — unless you update the configuration too.

### C8. Inspection commands
| Command | Does |
|---|---|
| `terraform show` | Human-readable current state; `terraform show tfplan` shows a saved plan; `-json` for machine output |
| `terraform output` | Root outputs from **state**: `-json`, `-raw NAME` (no quotes, for scripts) |
| `terraform state list` / `state show ADDR` | Addresses / one resource's attributes (Day 5) |
| `terraform graph` | DOT-format dependency graph (`| dot -Tpng > g.png` with Graphviz) |
| `terraform providers` | Tree of providers required by config & modules, and those in state |
| `terraform providers lock -platform=linux_amd64 -platform=darwin_arm64` | Pre-populate lock file hashes for several OS/arch |
| `terraform providers mirror DIR` | Copy providers to a local mirror (air-gapped) |
| `terraform providers schema -json` | Dump provider schemas |
| `terraform version` | CLI version + provider versions; warns if outdated |
| `terraform console` | Interactive expression REPL using current state & config; read-only |

### C9. Other commands
| Command | Does |
|---|---|
| `terraform get` | Download/update **modules only** (`-update`). `init` does this too |
| `terraform login [host]` | Obtain API token for HCP Terraform/TFE; saves to `~/.terraform.d/credentials.tfrc.json` |
| `terraform logout` | Remove stored token |
| `terraform force-unlock LOCK_ID` | Remove a stuck state lock (dangerous if someone is mid-run) |
| `terraform workspace new/select/list/show/delete` | CLI workspaces (Day 6) |
| `terraform import ADDR ID` | CLI import (Day 5) |
| `terraform test` | Run `*.tftest.hcl` test files (1.6+; recognition only) |
| `terraform metadata functions` | List functions (rare) |

Global option: `-chdir=DIR` — run as if in DIR: `terraform -chdir=envs/prod plan`. It must
come **before** the subcommand.

### C10. Logging (objective 7c)
| Variable | Purpose |
|---|---|
| `TF_LOG` | `TRACE` (most verbose) · `DEBUG` · `INFO` · `WARN` · `ERROR` · `JSON` (trace-level, JSON format). Unset = off |
| `TF_LOG_PATH` | Write logs to a file (still requires `TF_LOG` to be set) |
| `TF_LOG_CORE` | Log level for Terraform Core only |
| `TF_LOG_PROVIDER` | Log level for providers only |
| `crash.log` | Written when Terraform itself panics; attach to bug reports |

When to use: provider API errors you can't explain (see the raw HTTP request/response at
DEBUG/TRACE), auth issues, slow runs, plugin crashes. Logs can contain **secrets** — handle
carefully.

```bash
export TF_LOG=DEBUG
export TF_LOG_PATH=./terraform-debug.log
terraform plan
unset TF_LOG TF_LOG_PATH
```

Other useful env vars: `TF_VAR_name`, `TF_INPUT=0`, `TF_CLI_ARGS` / `TF_CLI_ARGS_plan`
(extra flags), `TF_DATA_DIR` (relocate `.terraform`), `TF_WORKSPACE` (select workspace),
`TF_PLUGIN_CACHE_DIR` (share provider downloads).

---

## D. Why it matters

Your GitHub Actions pipeline is a sequence of these commands: `fmt -check` → `init -input=false`
→ `validate` → `plan -out=tfplan` (on PR) → `apply tfplan` (on merge). Knowing which flags
prompt, which write state, and which are safe in CI prevents outages. The exam has many
"which command" questions where two options look almost right.

---

## E. Command decision table

| I want to… | Command |
|---|---|
| Download a newly added provider | `terraform init` |
| Move to a newer provider version allowed by my constraints | `terraform init -upgrade` |
| Check formatting in CI without changing files | `terraform fmt -check -recursive` |
| Check for typos/undeclared references | `terraform validate` |
| Preview changes | `terraform plan` |
| Guarantee what I reviewed is what gets applied | `plan -out=tfplan` then `apply tfplan` |
| Detect drift in a nightly job | `terraform plan -detailed-exitcode` (exit 2 = changes) or `plan -refresh-only` |
| Accept out-of-band changes into state | `terraform apply -refresh-only` |
| Recreate a broken VM | `terraform apply -replace=aws_instance.web` |
| Preview tearing everything down | `terraform plan -destroy` |
| Read an output in a script | `terraform output -raw alb_dns` |
| Try out a function | `terraform console` |
| See which providers modules need | `terraform providers` |
| Unblock a stuck lock | `terraform force-unlock LOCK_ID` |
| Debug a provider auth error | `TF_LOG=DEBUG terraform plan` |
| Lock file for Mac devs + Linux CI | `terraform providers lock -platform=darwin_arm64 -platform=linux_amd64` |

---

## F. Worked example — a CI pipeline traced

```yaml
# conceptual GitHub Actions steps
- run: terraform fmt -check -recursive        # 1 non-zero exit if any file is unformatted
- run: terraform init -input=false             # 2 backend + providers (lock file honoured)
- run: terraform validate                      # 3 static checks
- run: terraform plan -input=false -out=tfplan # 4 refresh + diff, saved
- run: terraform show -no-color tfplan > plan.txt   # 5 human-readable for PR comment
# on merge to main, same commit:
- run: terraform apply -input=false tfplan     # 6 no prompt; fails if stale
```
Why `-input=false`? So a missing variable fails fast instead of hanging for a prompt.
Why save the plan? So exactly what was reviewed is applied, not a re-computed plan that
may differ if someone changed infra in between.

---

## G. Visual — what each command touches

```
                CONFIG   LOCKFILE   .terraform/   STATE        REAL INFRA
init              R         RW          W          (backend)       -
fmt              RW          -          -            -             -
validate          R          R          R            -             -
plan              R          R          R            R          R (refresh)
apply             R          R          R           RW            RW
apply -refresh-only R        R          R           RW          R
destroy           R          R          R           RW            RW
show              -          -          -            R             -
output            -          -          -            R             -
console           R          -          R            R             -
state rm/mv       -          -          -           RW             -
force-unlock      -          -          -       lock only         -
```

---

## H. Common misconceptions

| # | Misconception | Reality |
|---|---|---|
| 1 | "`validate` checks my AWS credentials." | It never contacts APIs. |
| 2 | "`plan` updates state with refreshed values." | Only `apply` (incl. `-refresh-only`) persists state. |
| 3 | "`apply tfplan` asks for confirmation." | Saved plans apply without prompting. |
| 4 | "`init -upgrade` upgrades Terraform itself." | It upgrades providers/modules within constraints. |
| 5 | "`fmt` fixes syntax errors." | It can't format unparseable files; it errors. |
| 6 | "`destroy` removes resources from config." | It changes infra + state; config files are untouched. |
| 7 | "`-target` is a normal way to work." | For exceptional recovery only; leaves config and state out of sync with the full plan. |
| 8 | "`terraform refresh` is the recommended drift fix." | Deprecated; use `apply -refresh-only`. |
| 9 | "`TF_LOG_PATH` alone enables logging." | You must also set `TF_LOG`. |
| 10 | "`.terraform/` should be committed." | Commit the lock file; ignore `.terraform/`. |

---

## I. Exam traps
- **`terraform get` vs `init`** — `get` handles modules only.
- **`-reconfigure` vs `-migrate-state`** — reconfigure abandons old state location without copying.
- **`terraform show` vs `terraform state show`** — whole state/plan vs single resource.
- **`terraform output` reads state** — after changing an output block you must `apply` before `terraform output` reflects it.
- **"Which command formats code?"** — `fmt`. Not `validate`, not `lint`.
- `destroy` = `apply -destroy`, *not* `plan -destroy` (that's a preview).

---

## J. Active recall
1. Four things `init` does?
2. What is the difference between `-reconfigure` and `-migrate-state`?
3. Which flag replaces `taint`?
4. What do exit codes 0/1/2 mean with `-detailed-exitcode`?
5. Most verbose `TF_LOG` level?
6. Which command shows the dependency graph and in what format?

<details><summary>Answers</summary>

1. Initialise backend, install modules, install providers, write/update the lock file.
2. `-reconfigure` sets up the new backend and ignores existing state (no copy); `-migrate-state` copies state from old to new backend.
3. `-replace=ADDRESS` on plan/apply.
4. 0 = success, no changes; 1 = error; 2 = success, changes present.
5. `TRACE`.
6. `terraform graph`, DOT (Graphviz) format.
</details>

---

## K. Practice exercises — command selection (answer each with a command)

1. A new teammate cloned the repo; `plan` says providers aren't installed.
2. The AWS provider released 5.80; your constraint is `~> 5.40` and the lock file pins 5.42.
3. You want to know what `cidrsubnet("10.1.0.0/16", 8, 10)` returns.
4. CI must fail if any file isn't canonically formatted, including modules in subfolders.
5. An EC2 instance's disk is corrupted; config is fine; you want a fresh instance.
6. You need the value of output `bucket_arn` without quotes in a shell script.
7. You want to run Terraform in `./envs/dev` from the repo root.
8. Plan is slow because of 2,000 resources and you just want a quick preview, accepting stale state risk.
9. You suspect a provider is sending a malformed request.
10. Remove an accidental lock left by a crashed CI runner (lock ID `a1b2`).

<details><summary>Answers</summary>

1. `terraform init`
2. `terraform init -upgrade` (gets 5.80, allowed by `~> 5.40`, updates lock file)
3. `terraform console` then type the expression
4. `terraform fmt -check -recursive`
5. `terraform apply -replace=aws_instance.web`
6. `terraform output -raw bucket_arn`
7. `terraform -chdir=envs/dev plan`
8. `terraform plan -refresh=false`
9. `TF_LOG=DEBUG` (or `TRACE`) with `TF_LOG_PATH`, then `terraform plan`
10. `terraform force-unlock a1b2` — after confirming no run is active
</details>

---

## L. Lesson assessment
30-scenario command-selection drill in chat (rapid answers), then 8 multiple-choice
questions. Pass mark: **≥ 85%** on the drill, **7/8** on MCQs.

## M. Summary
- `init` (backend, modules, providers, lock) · `fmt` style · `validate` static · `plan` diff · `apply` change · `destroy` = `apply -destroy`.
- Saved plans apply without prompting; stale plans are rejected.
- `refresh` → `apply -refresh-only`; `taint` → `-replace`.
- `-target` exceptional; `-refresh=false` risky; `-detailed-exitcode` for drift CI.
- `TF_LOG` levels TRACE > DEBUG > INFO > WARN > ERROR; `TF_LOG_PATH` for file.

### Flashcards (Day 3)
| Front | Back |
|---|---|
| `init -upgrade` | Newest provider/module versions allowed by constraints; updates lock |
| `-reconfigure` vs `-migrate-state` | Ignore old state vs copy old state to new backend |
| `fmt -check` | Exit non-zero if formatting needed; writes nothing |
| `validate` needs | Initialised providers (no backend/API access) |
| `apply PLANFILE` prompts? | No |
| Deprecated `refresh` → | `apply -refresh-only` |
| Deprecated `taint` → | `apply -replace=ADDR` |
| `destroy` equivalent | `apply -destroy` |
| `plan -detailed-exitcode` | 0 none · 1 error · 2 changes |
| Global flag to change directory | `-chdir=DIR` before subcommand |
| Provider lock for many OS | `terraform providers lock -platform=...` |
| Token location after `terraform login` | `~/.terraform.d/credentials.tfrc.json` |

## N. Mastery decision
≥85% drill and ≥7/8 ✅ · otherwise ➕ second drill with fresh scenarios · <60% 🔁 re-teach C1, C4–C7.
