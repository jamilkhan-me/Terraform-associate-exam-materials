# QUICK REVISION — Final Sheet

Read in the last 24 hours. Every section links to the detailed lesson.
Assumed exam: Terraform Associate **004** (see EXAM_OBJECTIVES.md for uncertainties).

---

## 1. The three worlds ([Day 1](daily-lessons/day-01.md))
```
CONFIG (.tf)  ──desired──►  PLAN  ◄──recorded── STATE ◄──refresh── REAL INFRA
```
| Command | Writes state | Changes infra |
|---|---|---|
| plan | ✗ | ✗ |
| apply / destroy | ✓ | ✓ |
| apply -refresh-only | ✓ | ✗ |
| state mv / rm / push | ✓ | ✗ |
| import (CLI) | ✓ | ✗ |

## 2. Workflow & CLI ([Day 3](daily-lessons/day-03.md))
- **Write → Plan → Apply**; `init` first (backend, modules, providers, lock file).
- `init -upgrade` (newer allowed versions) · `-migrate-state` (copy) · `-reconfigure` (no copy) · `-backend=false` · `-backend-config`.
- `fmt` (`-check`, `-recursive`) style only · `validate` offline, needs providers.
- `plan -out=f` → `apply f` (no prompt; stale rejected) · `-detailed-exitcode` 0/1/2 · `-refresh=false` · `-replace=ADDR` (replaces `taint`) · `-target` exceptional.
- `refresh` deprecated → `apply -refresh-only`. `destroy` = `apply -destroy`; preview `plan -destroy`.
- `show` (state or plan file) · `output -json/-raw` (reads state) · `console` · `graph` (DOT) · `providers` · `get` (modules only) · `version` · `login` · `force-unlock ID` · `-chdir=DIR`.
- Logs: `TF_LOG`=TRACE/DEBUG/INFO/WARN/ERROR/JSON, `TF_LOG_PATH`, `TF_LOG_CORE`, `TF_LOG_PROVIDER`; `crash.log`.

## 3. HCL ([Day 2](daily-lessons/day-02.md))
- Precedence: **default < TF_VAR_ < terraform.tfvars < .tfvars.json < *.auto.tfvars (lexical) < -var/-var-file (last wins)**. Other `.tfvars` need `-var-file`.
- Types: string number bool list set map object tuple any; `optional(T, default)`.
- `local.x` (block `locals`) · `var.x` · `data.T.N.a` · `module.M.out` · `each.key/value` · `count.index` · `self` · `path.module` · `terraform.workspace`.
- `[for …]` → list, `{for … : k => v}` → map, `...` groups. Splat `[*]` on lists; `values(x)[*]` on for_each maps.
- `dynamic "blk" { for_each = …; content { blk.value } }` — nested blocks only.
- Functions: merge (maps) · concat (lists) · flatten · lookup(m,k,d) · element (wraps) · coalesce · try/can · one · toset · keys/values (sorted) · join/split · format · jsonencode · templatefile · cidrsubnet. No user-defined functions.
- Outputs from sensitive values need `sensitive = true`.

## 4. Providers, resources, lifecycle ([Day 4](daily-lessons/day-04.md))
- `required_providers { aws = { source = "hashicorp/aws", version = "~> 5.40" } }`; omitted source → `hashicorp/<name>`.
- `~> 5.40` = ≥5.40 <6.0 · `~> 5.40.0` = ≥5.40.0 <5.41.0.
- Lock file: providers only, versions + hashes, **commit it**; `providers lock -platform`.
- Aliases: `provider = aws.west` (resource) · `providers = { aws = aws.west }` (module).
- `count` = index (shift risk) · `for_each` = map/set of strings, keys known at plan.
- Lifecycle (literals only): `create_before_destroy` (+/-, propagates to dependencies) · `prevent_destroy` · `ignore_changes` · `replace_triggered_by` · pre/postconditions.
- Errors: validation, precondition, postcondition. Warnings: `check`.
- Provisioners: local-exec / remote-exec / file; on create only (or `when = destroy`); failure → tainted; last resort; `terraform_data` replaces `null_resource`.
- Update vs replace decided by **provider schema** → `# forces replacement`.

## 5. State ([Day 5](daily-lessons/day-05.md))
- Purposes: mapping, metadata, performance, sync. JSON; never hand-edit; secrets in plaintext.
- Local default `terraform.tfstate` (+ `.backup`). One backend per config. **No variables in backend** → `-backend-config`.
- Locking automatic on write ops (supporting backends); `-lock-timeout`; `force-unlock`. S3: `use_lockfile = true` (1.10+) or DynamoDB (older).
- `state list/show` (read) · `mv` (re-address) · `rm` (forget) · `pull`/`push` · `replace-provider`.
- Blocks: `moved` (rename) · `removed { lifecycle { destroy = false } }` (forget) · `import { to, id }` (+`for_each` 1.7+).
- Import: `plan -generate-config-out=f`; CLI `terraform import ADDR ID` needs block; always plan after.
- Drift: changed → plan reverts; deleted → plan creates; unmanaged new → invisible (import).
- Migration: edit backend → `init -migrate-state` → `plan` shows no changes.
- `terraform_remote_state` → root outputs only.

## 6. Modules & workspaces ([Day 6](daily-lessons/day-06.md))
- Sources: `./local` · `ns/name/provider` (+`version`) · `host/org/name/provider` · `git::url?ref=` · `//subdir` · http/s3/gcs.
- Scope: inputs in, outputs out; no globals; `module.M.out`, `module.M["k"].out`, `module.M[0].out`.
- Module meta-args: count, for_each, depends_on, providers (no lifecycle). No provider blocks in reusable modules.
- CLI workspaces: same config, separate state; `terraform.tfstate.d/<ws>/`; `default` undeletable; shared creds → weak isolation.

## 7. HCP Terraform & security ([Day 7](daily-lessons/day-07.md))
- Org → Project → Workspace → Runs; teams with permissions.
- Workflows: VCS (speculative plans on PRs), CLI (`cloud` block + `terraform login`), API.
- Execution: remote (default), local (state only in HCP), agent.
- Run: plan → cost estimation → policy check (Sentinel/OPA) → apply. Advisory / soft-mandatory (override) / hard-mandatory (no override). Run tasks for external checks.
- Variable sets; sensitive vars write-only; dynamic provider credentials (OIDC); private registry; health assessments (drift + checks); Terraform Enterprise = self-hosted.
- Secrets: never in code; sensitive ≠ encrypted; protect state/plans; Vault (data sources still persist); ephemeral & write-only (newer).

---

## 8. Frequently confused pairs
| A | B | Difference |
|---|---|---|
| provider | provisioner | API plugin vs script runner |
| resource | data source | manage vs read |
| `local` | `locals` | reference vs block |
| `state rm` | `destroy` | forget vs delete |
| `state mv` | `moved` | immediate CLI vs reviewed in plan |
| `-migrate-state` | `-reconfigure` | copy vs don't copy |
| `refresh` | `apply -refresh-only` | deprecated, unreviewed vs reviewed |
| `taint` | `-replace` | deprecated vs recommended |
| `terraform show` | `terraform state show` | whole state/plan vs one resource |
| `init` | `get` | everything vs modules only |
| `validate` | `plan` | static vs refresh+diff |
| `sensitive` | `ephemeral` | hidden in output vs not persisted |
| precondition | check | error vs warning |
| count | for_each | index vs key |
| CLI workspace | HCP workspace | alternate state vs full unit (config+vars+perms+runs) |
| soft-mandatory | hard-mandatory | overridable vs not |
| lock file | state file | provider versions vs resource mapping |

## 9. Top misconceptions (all FALSE)
- Plan saves refreshed state. · Sensitive encrypts state. · Lock file pins modules.
- `state rm` deletes the resource. · Backends accept variables. · for_each accepts lists.
- Child modules see root variables. · `check` blocks fail the run. · Saved plans prompt.
- `prevent_destroy` stops console deletion. · Failed applies roll back. · Data sources create things.
- `default` workspace can be deleted. · Terraform code runs on any cloud unchanged.

## 10. Final weak-topic checklist
Tick only when you can explain it aloud without notes:
- [ ] Variable precedence, including auto.tfvars ordering
- [ ] count vs for_each index shift; migrating with `moved`
- [ ] Every `state` subcommand's effect on infra (none)
- [ ] Import: block, generate-config, CLI prerequisites
- [ ] Backend restrictions, partial config, migration flags
- [ ] Locking and force-unlock safety
- [ ] Lifecycle options + custom conditions (error vs warning)
- [ ] Module sources, `version` scope, provider passing
- [ ] CLI workspaces vs HCP workspaces
- [ ] HCP run stages, policy levels, variable sets, execution modes
- [ ] Sensitive data handling end-to-end
- [ ] Personal items from `flashcards/weak-topics.md`
