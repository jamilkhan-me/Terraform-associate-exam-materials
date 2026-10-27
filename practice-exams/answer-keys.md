# Answer Keys

> ⚠ **Spoilers.** Only open the section for an assessment you have already submitted.
> Sections: [Diagnostic](#diagnostic-test) · [Mock 1](#mock-exam-01) · [Mock 2](#mock-exam-02) · [Mock 3](#mock-exam-03)

Domain tags: D1 IaC · D2 Fundamentals · D3 Workflow/CLI · D4 Configuration · D5 Modules ·
D6 State · D7 Maintain · D8 HCP Terraform

---

## Diagnostic Test

| Q | Answer | Domain | Q | Answer | Domain | Q | Answer | Domain |
|---|---|---|---|---|---|---|---|---|
| 1 | C | D1 | 11 | B | D4 | 21 | A | D6 |
| 2 | A, C | D1 | 12 | C | D4 | 22 | D | D6 |
| 3 | A, C | D3 | 13 | A | D4 | 23 | B | D6 |
| 4 | A | D2 | 14 | D | D4 | 24 | C | D6 |
| 5 | D | D2 | 15 | B | D4 | 25 | A | D7 |
| 6 | B | D3 | 16 | C | D4 | 26 | D | D7 |
| 7 | C | D3 | 17 | A | D4 | 27 | B | D7 |
| 8 | B (False) | D3 | 18 | D | D5 | 28 | A, B | D8 |
| 9 | A | D3 | 19 | B | D5 | 29 | C | D8 |
| 10 | D | D4 | 20 | C | D5 | 30 | A | D6 (CLI workspaces) |

Domain counts: D1 2 (Q1–2) · D2 2 (Q4–5) · D3 5 (Q3, Q6–9) · D4 8 (Q10–17) · D5 3 (Q18–20) ·
D6 5 (Q21–24, Q30) · D7 3 (Q25–27) · D8 2 (Q28–29) = 30.

### Explanations
(Referenced by option content.)

**Q1 — "describe the desired end state; Terraform works out the actions".** Declarative =
*what*, not *how*. Terraform builds a dependency graph, diffs desired configuration against
state (refreshed from reality), and computes actions. "Ordered list of API calls" is
imperative scripting; "logs into servers and runs scripts" describes configuration
management; "you must specify the order" is false — order is inferred from references.

**Q2 — version control/peer review, and reproducible environments.** Terraform *uses* provider
APIs (doesn't remove them); nothing guarantees deployments never fail; Terraform specifically
*needs* stored state.

**Q3 — installs providers; initialises the backend.** `init` also installs modules and writes
the lock file. It never creates resources (`apply`), never formats (`fmt`), and doesn't test
credentials (credential errors usually surface at plan).

**Q4 — `.terraform.lock.hcl`.** Provider versions + hashes; commit it. State records
resources, not provider selections for future runs. `versions.tf` is only a conventional
filename for *constraints* (ranges); the lock file pins the selection.

**Q5 — map configuration to real-world objects and track metadata.** State is not a
credential store (though it may *contain* secrets — a risk, not a purpose), not a plugin
cache, not a command history.

**Q6 — `terraform plan`.** A dry run showing proposed changes. `validate` checks correctness
but shows no changes; `apply -auto-approve` changes things; `fmt` only formats.

**Q7 — syntax and internal consistency, no remote calls.** Uses installed provider schemas;
never calls cloud APIs or reads state. Needs `init` (providers), but `init -backend=false` is
enough.

**Q8 — False.** `fmt` adjusts whitespace/alignment/indentation; it never reorders arguments or
changes meaning.

**Q9 — applies the saved plan without prompting.** The plan was the review. If state changed
since the plan, Terraform rejects it as stale instead of re-planning.

**Q10 — data blocks read existing objects; Terraform doesn't manage their lifecycle.** A missing
object usually causes an error — data sources never create anything. Data sources exist for
every provider, not just AWS.

**Q11 — `data.aws_ami.ubuntu.id`.** Data source addresses are `data.<TYPE>.<NAME>`.
`aws_ami.ubuntu.id` would point to a *managed* resource.

**Q12 — `us-west-2`.** Precedence lowest→highest: default → `TF_VAR_` env → `terraform.tfvars` →
`terraform.tfvars.json` → `*.auto.tfvars(.json)` (lexical) → `-var`/`-var-file` on the CLI (in
order; last wins). Trap: env vars *feel* strong but are near the bottom.

**Q13 — `u[1]` changes from bravo to charlie, and `u[2]` is destroyed.** `count` instances are
identified by **index**; removing index 1 shifts `charlie` down. Depending on the provider
schema, the `name` change may be in-place or a replacement — either way, the wrong objects are
touched. That's why `for_each` (stable string keys) is preferred for distinct items.

**Q14 — the reference creates an implicit dependency.** File order is irrelevant: all `.tf` files
in a directory form one configuration. No alphabetical ordering; `depends_on` isn't needed when
a reference exists.

**Q15 — redacted in CLI output, but plain text in state.** `sensitive` only affects display. The
"never written to state" behaviour describes **ephemeral** values (Terraform 1.10+), a different
feature.

**Q16 — a `validation` block inside the `variable` block.** Postconditions validate results, not
raw inputs (and outputs only support preconditions). `ignore_changes` and a failing provisioner
are unrelated.

**Q17 — `merge()`.** Later keys win. `concat` joins lists, `join` makes a string, `lookup` reads one key.

**Q18 — registry modules (public or private).** Git sources pin with `?ref=`; local paths aren't
versioned.

**Q19 — the root must pass it explicitly, and the child must declare the variable.** Modules are
encapsulated; there are no globals or automatic inheritance.

**Q20 — `module.network.vpc_id`.** `module.<NAME>.<OUTPUT>`.

**Q21 — `terraform.tfstate` in the working directory.** Default `local` backend (non-default CLI
workspaces go to `terraform.tfstate.d/`). `.terraform/terraform.tfstate` caches *backend
configuration* metadata, not your resource state.

**Q22 — `terraform force-unlock LOCK_ID`.** Only when sure nobody else holds the lock. There is no
`terraform state unlock` or `init -unlock`.

**Q23 — `terraform apply -refresh-only`.** Updates state to match reality and proposes no
infrastructure changes. The older `terraform refresh` is deprecated in favour of it. Note: the
*next* normal plan will propose reverting the manual change unless the configuration is updated.

**Q24 — removed from state only; the bucket still exists and is unmanaged.** If the block remains
in config, the next plan proposes **creating** a new bucket (likely colliding).

**Q25 — `terraform plan -generate-config-out=generated.tf`.** Generates HCL for import targets
without a resource block; review/edit it. Import never recreates objects and isn't HCP-only.

**Q26 — `TF_LOG`** (`TRACE | DEBUG | INFO | WARN | ERROR | JSON`). Pair with `TF_LOG_PATH`;
`TF_LOG_CORE` / `TF_LOG_PROVIDER` scope it.

**Q27 — `terraform state show <address>`.** `state list` lists addresses; `terraform show` has no
`-resource` flag; `output` reads outputs.

**Q28 — remote state with locking/history; policy as code.** Providers are still required; remote
execution happens on HCP-managed workers (or agents), not your laptop; nothing rewrites invalid HCL.

**Q29 — after the plan, before the apply.** Run order: plan → (cost estimation) → policy check →
apply. Policies evaluate the plan.

**Q30 — each non-default workspace has its own state under `terraform.tfstate.d/<name>/`.** All
workspaces share configuration, `default` can't be deleted, and workspaces share backend and
credentials, so they're **not** strong isolation — a key reason for separate configurations or
state backends for prod vs non-prod.

---

## Mock Exam 01

| Q | Ans | Dom | Q | Ans | Dom | Q | Ans | Dom | Q | Ans | Dom |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | C | D1 | 11 | C | D3 | 21 | D | D4 | 31 | A | D5 |
| 2 | D | D1 | 12 | D | D3 | 22 | A | D4 | 32 | B | D6 |
| 3 | A, C | D1 | 13 | A, B | D3 | 23 | B | D4 | 33 | C | D6 |
| 4 | A | D2 | 14 | A | D3 | 24 | C | D4 | 34 | D | D6 |
| 5 | B | D2 | 15 | B | D3 | 25 | D | D4 | 35 | A, B | D6 |
| 6 | C | D2 | 16 | C | D4 | 26 | A, C | D4 | 36 | A | D6 |
| 7 | A, C | D2 | 17 | D | D4 | 27 | A | D5 | 37 | B | D7 |
| 8 | D | D2 | 18 | A | D4 | 28 | B | D5 | 38 | C | D7 |
| 9 | A | D3 | 19 | B | D4 | 29 | C | D5 | 39 | D | D8 |
| 10 | B | D3 | 20 | C | D4 | 30 | D | D5 | 40 | A | D8 |

Domain counts: D1 3 · D2 5 · D3 7 · D4 11 · D5 5 · D6 5 · D7 2 · D8 2 = 40.

### Explanations
(Explanations refer to options by content, so they stay valid if option order changes.)

1. **C — reality no longer matches config/state.** Drift comes from console edits, other tools, or deletions, and is detected by refresh during plan. Provider version differences, stale plan files, and unpinned modules are different problems.
2. **D — provisioning infrastructure through provider APIs.** Patching packages on long-running servers is configuration management (Ansible/Chef/Puppet); log collection and image building are other tool categories.
3. **A, C.** One workflow/language; many providers with cross-references. Resource types are provider-specific and never auto-translated between clouds.
4. **A — empty default configuration.** Provider blocks are optional when no settings are required. Providers that need settings (e.g. region) may then fail or fall back to environment variables.
5. **B — `registry.terraform.io/hashicorp/<local name>`.** That's why third-party providers must always declare `source`.
6. **C — `provider = aws.west`.** A bare reference in the resource. `alias` is set in the provider block; `providers = {}` is the *module* argument.
7. **A, C.** Commit it; `init -upgrade` re-selects versions and rewrites it. It doesn't record modules or state, and has nothing to do with the CLI version.
8. **D — state maps resources to real objects.** Tags don't replace state; state doesn't store `.tf` files; local state exists without HCP Terraform.
9. **A — `terraform init`.** Provider installation is `init`'s job. `get` only handles modules; `validate` needs providers already installed.
10. **B — `terraform show release.tfplan`.** `output` reads state outputs; `state show` takes a resource address; there's no `plan -in`.
11. **C — `-detailed-exitcode`.** 0 = no changes, 1 = error, 2 = changes. `-check` is an `fmt` flag.
12. **D — updates state to match reality, never changes infrastructure.** Reverting drift is what a normal apply does.
13. **A, B.** `destroy` ≡ `apply -destroy`; `plan -destroy` previews. `state rm` never destroys; `terraform delete` doesn't exist.
14. **A — current directory only** unless `-recursive`. `fmt` doesn't validate or require init.
15. **B — 4.67.0.** `~> 4.60` = `>= 4.60, < 5.0`; `-upgrade` picks the newest allowed. Plain `init` would keep the locked 4.61.0.
16. **C — `["0-a", "1-b", "2-c"]`.** With two symbols over a list, the first is the index and the second the value; `[...]` produces a list.
17. **D — `map(object({ cidr = string, azs = number }))`.**
18. **A — read during apply, dependants `(known after apply)`.** Data sources with unknown arguments are deferred (`<=` in the plan).
19. **B — `depends_on = [aws_iam_role_policy_attachment.logs]`.** Bare references to whole objects; quoted strings are invalid; file order is irrelevant.
20. **C — a list of the three private IPs**, in index order.
21. **D — `"large"` and `"m5.large"`.** For maps, key = map key, value = map value.
22. **A — 2.** `*.auto.tfvars` beats `terraform.tfvars`, which beats `TF_VAR_`.
23. **B — error during planning** ("Output refers to sensitive values").
24. **C — `dynamic "ingress"`.** `count` isn't valid on nested blocks; `for_each` on the resource would create several security groups.
25. **D — `create_before_destroy`.** `prevent_destroy` would only make the plan fail.
26. **A, C.** Validation and pre/postconditions are errors. `check` assertions are warnings.
27. **A — `module.web["blue"].url`.**
28. **B — `?ref=v1.4.0` in the Git URL.** `version` works only for registry sources.
29. **C — `terraform-aws-modules/vpc/aws`**, i.e. `<NAMESPACE>/<NAME>/<PROVIDER>`.
30. **D — `lifecycle`.** Modules support `count`, `for_each`, `depends_on`, `providers`.
31. **A — declare requirements, let the caller configure providers.** Provider blocks inside modules prevent `count`/`for_each`/`depends_on` on the module and complicate removal; backend blocks in child modules are ignored.
32. **B — `-backend-config`** (partial configuration). Variables can't be used in backend blocks; `-var`/`TF_VAR_` don't feed backends.
33. **C — automatic locking for write-capable operations on supporting backends.** Not every backend supports locking; `-lock=true` is already the default.
34. **D — `terraform init -migrate-state`.** `-reconfigure` would ignore the existing state.
35. **A, B — `moved` block or `terraform state mv`.** `-replace` forces recreation; `ignore_changes` doesn't affect addresses; import is for unmanaged objects.
36. **A — `terraform.tfstate.d/staging/terraform.tfstate`.**
37. **B — error: the address doesn't exist in configuration.** CLI import needs the block first; generating config is a feature of `import` blocks with `-generate-config-out`.
38. **C — `TRACE`.** TRACE > DEBUG > INFO > WARN > ERROR.
39. **D — VCS-driven workflow.**
40. **A — plan-only run that can't be applied** (PRs, and CLI `plan` against HCP Terraform workspaces).

---

## Mock Exam 02

| Q | Ans | Dom | Q | Ans | Dom | Q | Ans | Dom | Q | Ans | Dom |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | C | D1 | 16 | B | D3 | 31 | D | D4 | 46 | A | D6 |
| 2 | D | D1 | 17 | C | D3 | 32 | A, C | D4 | 47 | C | D6 |
| 3 | A, C | D1 | 18 | A | D3 | 33 | B | D4 | 48 | A, C | D6 |
| 4 | B | D1 | 19 | C | D3 | 34 | A | D4 | 49 | B | D7 |
| 5 | B | D2 | 20 | D | D3 | 35 | D | D4 | 50 | A | D7 |
| 6 | C | D2 | 21 | A | D3 | 36 | B | D5 | 51 | A, B | D7 |
| 7 | D | D2 | 22 | C | D4 | 37 | C | D5 | 52 | B | D7 |
| 8 | B | D2 | 23 | D | D4 | 38 | A | D5 | 53 | B | D8 |
| 9 | A | D2 | 24 | C | D4 | 39 | D | D5 | 54 | A | D8 |
| 10 | A, C | D2 | 25 | C | D4 | 40 | B | D5 | 55 | C | D8 |
| 11 | C | D2 | 26 | A | D4 | 41 | B | D5 | 56 | B | D8 |
| 12 | C | D3 | 27 | B | D4 | 42 | C | D6 | 57 | C | D8 |
| 13 | B | D3 | 28 | C | D4 | 43 | A | D6 | | | |
| 14 | A, C | D3 | 29 | B | D4 | 44 | B | D6 | | | |
| 15 | D | D3 | 30 | B | D4 | 45 | B | D6 | | | |

Domain counts: D1 4 · D2 7 · D3 10 · D4 14 · D5 6 · D6 7 · D7 4 · D8 5 = 57.

### Explanations

1. **C.** Version control + PR review. A is false (APIs are always used); D is an absolute promise.
2. **D.** Idempotency: no changes when nothing differs. A–C describe non-Terraform behaviour.
3. **A, C.** Multi-platform workflow and provider ecosystem. Terraform needs state (B); resources are provider-specific (D); credentials are still needed (E).
4. **B.** `ami` is ForceNew for `aws_instance` → replacement. Terraform favours replacing over in-place mutation of servers.
5. **B.** `.terraform/providers/...` in the working directory (unless a plugin cache or mirror is configured). `~/.terraform.d/plugins` is an optional local filesystem mirror location.
6. **C.** Partner = maintained by the technology company, verified by HashiCorp. Official = HashiCorp-maintained. Community = individuals/groups.
7. **D.** Only one default (un-aliased) configuration per provider is allowed; extra ones need `alias`.
8. **B.** Modules receive provider configurations through `providers = { <child name> = <parent ref> }`. Aliased configs are not inherited automatically (D).
9. **A.** Providers are separate executables; Core starts them and talks gRPC/RPC.
10. **A, C.** Encrypt and access-control state; restrict plan files too. Git (B) exposes secrets; `sensitive` (D) does not encrypt anything.
11. **C.** `lineage` is a unique ID per state history; `serial` (A) orders snapshots within one history.
12. **C.** Without a plan file, apply plans, shows, prompts.
13. **B.** `fmt -check` reports via exit code without writing.
14. **A, C.** Validate needs providers but not the backend; it checks references/types. It never calls APIs (B, E) or touches state (D).
15. **D.** `terraform console`.
16. **B.** `-replace` (0.15.2+) shows the replacement in the plan. `taint` (A) works but is deprecated and changes state before review. C would create a duplicate; D is a two-step targeted workaround.
17. **C.** `-reconfigure` ignores existing state; `-migrate-state` (A) copies it.
18. **A.** `-json` includes all outputs with their values (sensitive included, flagged). `-raw` (B) prints a single string output.
19. **C.** Saved plans are tied to the state they were computed from; Terraform rejects a stale plan.
20. **D.** DOT (Graphviz).
21. **A.** `-chdir` switches the working directory for that command only; it goes before the subcommand.
22. **C.** `keys()` returns keys in lexical order.
23. **D.** Missing key → default.
24. **C.** `coalesce` returns the first argument that isn't null **or an empty string**.
25. **C.** `one()` returns null for an empty list and the single element otherwise. B errors when count is 0; A is invalid when `count` is set (needs an index).
26. **A.** `-input=false` turns the prompt into an error: "No value for required variable".
27. **B.** `optional(number, 3)` supplies 3 when the attribute is omitted.
28. **C.** References create graph edges. File placement and names don't.
29. **B.** `depends_on` on a data source can postpone its read to apply time (Terraform can't be sure the dependency's changes won't affect the result), which spreads "known after apply" values downstream.
30. **B.** Map keys can be targeted in `ignore_changes`. A would ignore all tag changes, including ones you make deliberately.
31. **D.** `replace_triggered_by` replaces the resource when the referenced object changes. `depends_on` only orders operations.
32. **A, C.** `local-exec` runs locally; failed creation-time provisioner → tainted. Creation-time provisioners run only on create (B). Plans don't model provisioner effects (D). `remote-exec` runs on the remote resource (E).
33. **B.** `check` assertions produce warnings, not errors. Pre/postconditions and validation block the run.
34. **A.** Sensitive values are redacted as `(sensitive value)` in plan output; they are still stored in state (D is false).
35. **D.** `{ for … : key => value }` builds a map keyed by name.
36. **B.** The child uses its own default; root variables are never visible to children unless passed.
37. **C.** `<HOSTNAME>/<ORGANIZATION>/<NAME>/<PROVIDER>`.
38. **A.** `init -upgrade` re-checks modules and providers for newer versions allowed by constraints. A plain `init` keeps the installed 3.2.0 because it still satisfies `~> 3.2`.
39. **D.** `//` separates the package (repo) from the subdirectory; `?ref=` selects the tag.
40. **B.** Only root outputs are rendered. Child outputs are accessible to the parent as `module.x.y`.
41. **B.** Values flow between sibling modules through the root module's arguments.
42. **C.** A `removed` block with `destroy = false` is declarative and appears in the plan ("will no longer be managed by Terraform"). `state rm` (A) works but isn't reviewed in a plan. B destroys the bucket. D blocks destroys; it doesn't stop management.
43. **A.** Local filesystem, file locking on that machine only, no encryption, not shareable. It does support workspaces (D false).
44. **B.** "Variables may not be used here." Use `-backend-config` partial configuration.
45. **B.** `state pull` writes the current state to stdout. `state push` (A) uploads.
46. **A.** The lock prevents concurrent writes; the second job errors with "Error acquiring the state lock" unless `-lock-timeout` makes it wait.
47. **C.** Refresh finds the object gone and removes it from the in-memory state; config still declares it → create.
48. **A, C.** `terraform.workspace` + `workspace select`. Workspaces share backend config/credentials (B) and configuration (D).
49. **B.** "1 to import" with no other actions means config and reality match. C means a replacement (ForceNew mismatch) — stop and fix config.
50. **A.** `state list` accepts address filters. `state show` (C) shows one resource instance only.
51. **A, B.** `TF_LOG` enables logging; `TF_LOG_PATH` sends it to a file. C and D don't exist.
52. **B.** Each resource type documents its import ID (bucket name, instance ID, composite IDs, ARNs for some).
53. **B.** Soft-mandatory: can be overridden by authorised users. Hard-mandatory cannot. Advisory only warns.
54. **A.** Variable sets apply a shared group of variables to many workspaces/projects. (Dynamic provider credentials would also avoid static secrets, but that wasn't an option.)
55. **C.** The `cloud` block (Terraform 1.1+).
56. **B.** Projects organise workspaces and scope team access and variable sets.
57. **C.** Local execution mode: runs on your machine, HCP Terraform stores state.

---

## Mock Exam 03

| Q | Ans | Dom | Q | Ans | Dom | Q | Ans | Dom | Q | Ans | Dom |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | A | D1 | 16 | D | D3 | 31 | B | D4 | 46 | A | D6 |
| 2 | C | D1 | 17 | D | D3 | 32 | A | D4 | 47 | A | D6 |
| 3 | A, B | D1 | 18 | B | D3 | 33 | C | D4 | 48 | B | D6 |
| 4 | D | D1 | 19 | A | D3 | 34 | C | D4 | 49 | A | D7 |
| 5 | C | D2 | 20 | C | D3 | 35 | A | D4 | 50 | B | D7 |
| 6 | D | D2 | 21 | C | D3 | 36 | D | D5 | 51 | C | D7 |
| 7 | B | D2 | 22 | D | D4 | 37 | C | D5 | 52 | D | D7 |
| 8 | A | D2 | 23 | B | D4 | 38 | B | D5 | 53 | B | D8 |
| 9 | C | D2 | 24 | C | D4 | 39 | C | D5 | 54 | A | D8 |
| 10 | C | D2 | 25 | B | D4 | 40 | B | D5 | 55 | C | D8 |
| 11 | D | D2 | 26 | D | D4 | 41 | A | D5 | 56 | D | D8 |
| 12 | B | D3 | 27 | D | D4 | 42 | C | D6 | 57 | B | D8 |
| 13 | B | D3 | 28 | A | D4 | 43 | D | D6 | | | |
| 14 | A | D3 | 29 | C | D4 | 44 | D | D6 | | | |
| 15 | C | D3 | 30 | D | D4 | 45 | B | D6 | | | |

Domain counts: D1 4 · D2 7 · D3 10 · D4 14 · D5 6 · D6 7 · D7 4 · D8 5 = 57.

### Explanations
(Referenced by content so they stay valid if option order changes.)

1. **Consistent, repeatable environments.** Building every environment from the same code removes hand-made divergence.
2. **The desired end state.** Declarative: what, not how.
3. **SaaS DNS records and GitHub repositories/permissions.** Anything with an API and a provider. Physical kit with no API can't be managed; Terraform isn't limited to VMs.
4. **Terraform tracks resources in its own state, in a backend you choose.** CloudFormation's state is managed by the AWS service. Terraform needs the AWS provider plugin and works across many platforms.
5. **2.4.9.** `>= 2.0, < 2.5` — the comma means AND; 2.5.0 is excluded by `<`.
6. **The Terraform CLI must be 1.9.x.** `required_version` constrains the CLI only; `~> 1.9.0` = `>= 1.9.0, < 1.10.0`.
7. **`terraform providers`** prints the requirement tree per module (and providers recorded in state).
8. **The data source re-reads, and the instance changes.** Data sources are read on every plan (unless deferred). `ami` forces replacement for `aws_instance`. This is a classic surprise when using `most_recent = true` — pin AMIs or use `ignore_changes` where appropriate.
9. **Credentials from environment variables.** Provider configuration taken from the environment is not written to state. (Arguments set in resources are — including secrets.)
10. **Shared plugin cache** across working directories, saving downloads and disk.
11. **`terraform providers lock -platform=... -platform=...`, then commit.** Deleting or ignoring the lock file throws away reproducibility and checksum verification. `-lockfile=ignore` is not a valid mode (`-lockfile=readonly` exists).
12. **`init` → `validate` → `plan -out` → `apply tfplan`.** Init first; apply the saved, reviewed plan.
13. **Skips refresh and plans from state alone; may miss drift.** Useful for speed on very large configs, at a risk.
14. **Exceptional situations only.** Terraform itself warns that targeting is for exceptional use, not routine.
15. **Error, nothing destroyed.** `prevent_destroy` makes any plan that includes destroying that resource fail as a whole.
16. **5.1.0.** Plain `init` honours the lock file as long as the locked version satisfies the constraint. Only `-upgrade` would move to 5.9.0.
17. **`terraform version`** shows the CLI version and the provider versions selected in the working directory.
18. **`terraform get`** — modules only. `init` installs modules *and* providers and configures the backend.
19. **Creates the remaining 2.** No rollback in Terraform; successfully created objects are recorded in state.
20. **Destroys without prompting.** Any saved plan, including a destroy plan, applies without a prompt.
21. **`-auto-approve`.**
22. **`"dev-api"`.** The `%{ if }` directive picks the `else` branch; `-api` is appended.
23. **`["a", "b", "c"]`.** `flatten` removes one or more levels of nesting; empty lists contribute nothing.
24. **`{ env = "dev", team = "b" }`.** Later maps win for duplicate keys.
25. **9.** `length` works on strings (characters), lists, maps, and sets.
26. **`"b"`.** `element` wraps: index 4 mod 3 = 1.
27. **A set containing "a" and "b".** Sets remove duplicates and are unordered (strings iterate lexically).
28. **`["a", "1"]`.** Terraform converts the number to a string to satisfy `list(string)`. (A value that can't be converted, e.g. a map, would error.)
29. **`self.<attr>`** — available in postconditions, provisioners, and connection blocks.
30. **`setting`** — by default the iterator is named after the dynamic block's label.
31. **Error: keys can't be determined until apply.** Instance IDs are unknown at plan time. Use keys known in advance (e.g. the same keys used to create the instances with `for_each`).
32. **`values(aws_iam_user.u)[*].arn`.** A `for_each` resource is a map of objects; take its values, then splat (or use a `for` expression).
33. **In state (and saved plans), in plain text.** Data source results are persisted. Ephemeral resources (newer Terraform/Vault provider versions) or write-only arguments avoid this.
34. **`ephemeral = true`** (Terraform 1.10+). `sensitive` only redacts output.
35. **Renders a template file with variables.** Common for EC2 `user_data`.
36. **`module.api[0].endpoint`.** `count` makes the module a list of instances.
37. **`"../../modules/db"`.** Relative paths must start with `./` or `../`.
38. **Error — `version` is only valid for registry sources.** Local modules are versioned with the code that contains them.
39. **Missing required argument.** Variables with no default are required.
40. **Can't use `count`, `for_each`, or `depends_on` on the module call.** Terraform treats modules with their own provider configuration as legacy modules, which can't use those meta-arguments. Removing such a module also strands its resources without a provider configuration.
41. **Semantic-version Git tags** (e.g. `v1.4.0`) in the connected repository.
42. **`use_lockfile = true`.** S3-native locking was added in 1.10; DynamoDB-based locking was subsequently deprecated (version-specific detail).
43. **The previous state snapshot**, written before the most recent update.
44. **`terraform state replace-provider`.** Rewrites the provider source address recorded for resources in state.
45. **Root module outputs only.** That's why the producing configuration must declare outputs. Reading still requires access to the whole state.
46. **`moved` from the old root address to the new module address.** The direction is `from` old `to` new. `removed` would stop managing it; import expects a real-world ID, not a reference.
47. **Orphaned.** `-force` deletes the workspace's state, not the infrastructure. You'd have to import or clean up manually.
48. **`terraform plan` shows no changes.** Proves the new backend has the same state that matches reality. Never delete the old state until verified.
49. **`for_each` over the map, `to = aws_subnet.this[each.key]`, `id = each.value`.** `import` blocks support `for_each` (1.7+), not `count`. Option D is invented syntax.
50. **`terraform state show 'aws_subnet.this["b"]'`.** Quote the address in the shell; keys are strings in brackets.
51. **`TF_LOG_PROVIDER`.** `TF_LOG_CORE` covers Core only. `TF_LOG` covers both.
52. **`crash.log`.** Written when Terraform panics. (Never share state files in bug reports — they contain secrets.)
53. **Integrate external services at run stages.** Run tasks can be advisory or mandatory. They complement, rather than replace, Sentinel/OPA policies.
54. **Short-lived credentials via OIDC workload identity.** No static keys stored in the workspace.
55. **Refused.** VCS-connected workspaces only apply runs triggered through VCS (CLI speculative plans are still allowed).
56. **Cost estimation** comes after plan and before policy checks.
57. **Self-hosted distribution of HCP Terraform.** Same Terraform language and CLI.
