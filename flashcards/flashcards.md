# Master Flashcard Deck

How to use: cover the **Back** column (or fold the screen), say the answer aloud, then check.
Mark cards you miss in [weak-topics.md](weak-topics.md). Aim for 3 correct recalls on
separate days before retiring a card.

---

## Domain 1 — IaC concepts
| # | Front | Back |
|---|---|---|
| 1.1 | Infrastructure as Code | Managing infrastructure via versioned, reviewable, repeatable definition files instead of manual steps |
| 1.2 | Declarative vs imperative | Declarative: describe end state (Terraform). Imperative: describe steps (scripts) |
| 1.3 | Idempotent | Re-applying the same config to the same infra makes no changes |
| 1.4 | Four IaC benefits | Version control/review, consistency/reproducibility, automation/speed, self-documentation (also reuse, drift detection) |
| 1.5 | Is HCL cloud-portable? | No — resource types are provider-specific; the workflow is portable |
| 1.6 | Terraform vs config management | Terraform provisions infra via APIs (immutable-leaning); CM tools configure software on servers (mutable) |
| 1.7 | Hybrid/multi-cloud with Terraform | Multiple providers in one config; cross-provider references; one workflow |

## Domain 2 — Fundamentals
| # | Front | Back |
|---|---|---|
| 2.1 | Terraform Core vs provider | Core: parsing, graph, state, plan. Provider: plugin calling a specific API, separate process over RPC |
| 2.2 | Provider source address format | `[hostname/]namespace/type` — default host `registry.terraform.io` |
| 2.3 | Source assumed if omitted | `hashicorp/<local name>` |
| 2.4 | Provider tiers | Official, Partner, Community |
| 2.5 | Where init installs providers | `.terraform/providers/` in the working dir |
| 2.6 | Lock file name & contents | `.terraform.lock.hcl` — provider versions, constraints, hashes |
| 2.7 | Lock file records modules? | No |
| 2.8 | Commit lock file? | Yes |
| 2.9 | `~> 3.1` | `>= 3.1, < 4.0` |
| 2.10 | `~> 3.1.0` | `>= 3.1.0, < 3.2.0` |
| 2.11 | `required_version` constrains | Terraform CLI version |
| 2.12 | Second config of same provider | `alias = "x"`; use with `provider = aws.x` |
| 2.13 | Provider block required? | No — empty default config used if none needed |
| 2.14 | Four purposes of state | Mapping to real objects, metadata, performance, team sync |
| 2.15 | `serial` | Increments per state write |
| 2.16 | `lineage` | UUID of a state's history; blocks pushing unrelated state |
| 2.17 | Share provider downloads across dirs | `TF_PLUGIN_CACHE_DIR` |
| 2.18 | Lock hashes for several OSes | `terraform providers lock -platform=…` |

## Domain 3 — Workflow & CLI
| # | Front | Back |
|---|---|---|
| 3.1 | Core workflow | Write → Plan → Apply (init first) |
| 3.2 | `init` does | Backend, modules, providers, lock file |
| 3.3 | `init -upgrade` | Newest provider/module versions allowed by constraints |
| 3.4 | `init -migrate-state` | Copy state to new backend |
| 3.5 | `init -reconfigure` | Use new backend config; don't copy state |
| 3.6 | `init -backend=false` | Skip backend (e.g. validate-only CI) |
| 3.7 | `fmt -check` / `-recursive` | Exit non-zero if unformatted / include subdirs |
| 3.8 | `validate` contacts APIs? | No; needs providers installed |
| 3.9 | Plan persists refreshed state? | No |
| 3.10 | `plan -out=f` then `apply f` | Applies exactly that plan, no prompt; rejected if stale |
| 3.11 | `-detailed-exitcode` | 0 none, 1 error, 2 changes |
| 3.12 | `-refresh=false` | Skip refresh; faster; may miss drift |
| 3.13 | `apply -refresh-only` | Update state to reality; no infra changes |
| 3.14 | `terraform refresh` status | Deprecated alias for refresh-only without review |
| 3.15 | `taint` replacement | `apply -replace=ADDR` |
| 3.16 | `destroy` ≡ | `apply -destroy`; preview with `plan -destroy` |
| 3.17 | `-target` | Exceptional use only |
| 3.18 | `terraform console` | Interactive expression evaluation |
| 3.19 | `terraform graph` output | DOT format |
| 3.20 | `terraform providers` | Provider requirements tree |
| 3.21 | `terraform get` | Modules only |
| 3.22 | `terraform output -raw x` | String value without quotes |
| 3.23 | `-chdir=DIR` | Run as if in DIR; before subcommand |
| 3.24 | `terraform login` token file | `~/.terraform.d/credentials.tfrc.json` |
| 3.25 | Default parallelism | 10 |
| 3.26 | Partial apply failure | No rollback; created resources stay in state; re-apply continues |

## Domain 4 — Configuration
| # | Front | Back |
|---|---|---|
| 4.1 | Argument vs attribute | Argument: you set it. Attribute: resource exposes it |
| 4.2 | Data source reference | `data.TYPE.NAME.ATTR` |
| 4.3 | Variable precedence | default < TF_VAR < terraform.tfvars < tfvars.json < *.auto.tfvars < CLI -var/-var-file (last wins) |
| 4.4 | Auto-loaded var files | `terraform.tfvars(.json)`, `*.auto.tfvars(.json)` |
| 4.5 | Required variable | No default; prompt or error with `-input=false` |
| 4.6 | `sensitive = true` | Redacted in output; plaintext in state |
| 4.7 | `ephemeral = true` (1.10+) | Not stored in state/plan |
| 4.8 | Output from sensitive value | Must set `sensitive = true` or error |
| 4.9 | `local` vs `locals` | Reference vs declaration block |
| 4.10 | `optional(T, default)` | Optional object attribute with default (1.3+) |
| 4.11 | list vs set vs tuple | ordered/dupes; unordered/unique; fixed-length mixed types |
| 4.12 | `[for x in l : f(x)]` vs `{for ...: k => v}` | list vs map result |
| 4.13 | `...` in for-map | Group duplicate keys into lists |
| 4.14 | Splat `x[*].id` | List of attribute across instances (count/lists) |
| 4.15 | `dynamic` block | Repeated nested blocks; iterator = block label |
| 4.16 | `merge` / `concat` / `flatten` | maps / lists / nested lists → flat |
| 4.17 | `lookup(m,k,d)` | value or default |
| 4.18 | `element(l,i)` | wraps with modulo |
| 4.19 | `coalesce` | first non-null, non-empty |
| 4.20 | `can` / `try` | bool success / first non-erroring value |
| 4.21 | `one(list)` | null if empty, element if one, error if more |
| 4.22 | `cidrsubnet("10.0.0.0/16",8,2)` | `10.0.2.0/24` |
| 4.23 | `count` vs `for_each` | index (shift risk) vs string keys (map/set) |
| 4.24 | for_each over list | error → `toset()` |
| 4.25 | for_each keys unknown | error at plan; use static keys |
| 4.26 | Implicit dependency | Created by references |
| 4.27 | `depends_on` value | List of whole resources/modules |
| 4.28 | create_before_destroy | New first (`+/-`); propagates to dependencies |
| 4.29 | prevent_destroy | Any plan destroying it errors |
| 4.30 | ignore_changes | Ignore drift/changes in listed attrs |
| 4.31 | replace_triggered_by | Replace when referenced object changes |
| 4.32 | Lifecycle with variables? | No — literals only |
| 4.33 | validation / pre / post / check | error / error / error / warning |
| 4.34 | `self` usable in | postconditions, provisioners, connection |
| 4.35 | Provisioner types | local-exec, remote-exec, file |
| 4.36 | Failed creation provisioner | Resource tainted |
| 4.37 | `null_resource` successor | `terraform_data` |
| 4.38 | Who decides update vs replace | Provider schema (ForceNew); plan shows `# forces replacement` |
| 4.39 | Vault data source secret | Stored in state |
| 4.40 | Write-only arguments | `*_wo` args (1.11+) not persisted |

## Domain 5 — Modules
| # | Front | Back |
|---|---|---|
| 5.1 | Root module | Directory where Terraform runs |
| 5.2 | Local source | Must start with `./` or `../` |
| 5.3 | Public registry source | `NAMESPACE/NAME/PROVIDER` |
| 5.4 | Private registry source | `HOST/ORG/NAME/PROVIDER` |
| 5.5 | `version` arg works for | Registry sources only |
| 5.6 | Git ref | `?ref=v1.2.0` |
| 5.7 | Subdirectory | `//path` |
| 5.8 | Child sees root vars? | Only if passed as arguments |
| 5.9 | Reference output | `module.NAME.OUTPUT` (`module.NAME[KEY].OUTPUT`) |
| 5.10 | Reference child internals? | No |
| 5.11 | Module meta-args | count, for_each, depends_on, providers |
| 5.12 | Pass alias to module | `providers = { aws = aws.x }` |
| 5.13 | Provider blocks in modules | Avoid; legacy modules can't use count/for_each/depends_on |
| 5.14 | Upgrade modules | Change version, `init -upgrade`, review plan |
| 5.15 | Registry versions from | semver Git tags |

## Domain 6 — State management
| # | Front | Back |
|---|---|---|
| 6.1 | Default backend | local, `terraform.tfstate` |
| 6.2 | Backend count | One per configuration |
| 6.3 | Variables in backend | Not allowed; use `-backend-config` |
| 6.4 | Locking | Automatic on write ops for supporting backends |
| 6.5 | Stale lock | `terraform force-unlock ID` |
| 6.6 | S3 native locking | `use_lockfile = true` (1.10+) |
| 6.7 | `state list/show` | Read only |
| 6.8 | `state mv` | Re-address in state; no infra change |
| 6.9 | `state rm` | Forget; object keeps running |
| 6.10 | `state pull` / `push` | Download to stdout / overwrite remote (dangerous) |
| 6.11 | `state replace-provider` | Change provider source in state |
| 6.12 | `moved` | Declarative rename |
| 6.13 | `removed` + destroy=false | Declarative forget |
| 6.14 | Drift: deleted object | Plan proposes create |
| 6.15 | CLI workspace state path | `terraform.tfstate.d/<ws>/` |
| 6.16 | `default` workspace | Cannot be deleted |
| 6.17 | `terraform_remote_state` | Reads root outputs of another state |
| 6.18 | Local backup file | `terraform.tfstate.backup` |

## Domain 7 — Maintain
| # | Front | Back |
|---|---|---|
| 7.1 | Import block | `import { to = ADDR  id = "ID" }` (1.5+) |
| 7.2 | Generate config | `plan -generate-config-out=FILE` |
| 7.3 | CLI import prerequisite | Resource block exists |
| 7.4 | Import for_each | 1.7+ |
| 7.5 | Import ID format | Provider/resource-specific |
| 7.6 | Clean import plan | `N to import, 0 add, 0 change, 0 destroy` |
| 7.7 | Log levels | TRACE, DEBUG, INFO, WARN, ERROR (+JSON) |
| 7.8 | Log to file | `TF_LOG` + `TF_LOG_PATH` |
| 7.9 | Scope logs | `TF_LOG_CORE`, `TF_LOG_PROVIDER` |
| 7.10 | Crash file | `crash.log` |

## Domain 8 — HCP Terraform
| # | Front | Back |
|---|---|---|
| 8.1 | Hierarchy | Org → Project → Workspace → Runs |
| 8.2 | Workflows | VCS-driven, CLI-driven, API-driven |
| 8.3 | Execution modes | Remote, Local, Agent |
| 8.4 | Speculative plan | Plan-only, can't apply (PRs, CLI plan) |
| 8.5 | Run order | Plan → cost estimation → policy check → apply |
| 8.6 | Sentinel levels | advisory (warn), soft-mandatory (override), hard-mandatory (no override) |
| 8.7 | Variable sets | Shared variables across workspaces/projects/org |
| 8.8 | Dynamic provider credentials | OIDC short-lived creds per run |
| 8.9 | Run tasks | External service checks at run stages |
| 8.10 | `cloud` block | Connect CLI config to HCP Terraform (1.1+) |
| 8.11 | Terraform Enterprise | Self-hosted HCP Terraform |
| 8.12 | VCS workspace + CLI apply | Refused |
| 8.13 | Private registry | Share internal modules/providers |
| 8.14 | Health assessments | Drift detection + check block evaluation on schedule |
