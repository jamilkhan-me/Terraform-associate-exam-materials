# Day 7 — HCP Terraform, Security, and Sensitive Data

**Objectives covered:** 4h, 8a, 8b, 8c, 8d (+ CI/CD and supply-chain practices)
**Assessment:** Day 7 quiz, then **[Mock Exam 1](../practice-exams/mock-exam-01.md)** (40 Q, 45 min)

> Version note: "Terraform Cloud" was renamed **HCP Terraform** (2024). **Terraform
> Enterprise** is the self-hosted distribution of the same platform. Feature availability
> by pricing tier changes often — this lesson teaches **what features do**, not which tier
> includes them. Treat any tier claim you meet with caution.

---

## A. Learning objectives

1. Explain what HCP Terraform provides over the CLI alone.
2. Describe organisations, projects, workspaces, teams, and how they relate.
3. Compare VCS-driven, CLI-driven, and API-driven workflows.
4. Configure the `cloud` block and authenticate with `terraform login`.
5. Explain remote vs local execution, remote state, run stages, and speculative plans.
6. Describe variables, variable sets, sensitive variables, and dynamic provider credentials.
7. Describe governance: Sentinel/OPA policies and enforcement levels, run tasks, private registry, cost estimation, drift detection/health assessments, audit.
8. Apply best practices for secrets: never in code, sensitive vars, state protection, Vault, ephemeral values.
9. Reason about provider/module source trust and CI/CD safety.

---

## B. Plain-English explanation

The CLI alone gives you a tool. **HCP Terraform** gives a team a **platform**: shared state,
locked and versioned; runs executed on managed workers (consistent environment, no
credentials on laptops); plans automatically posted to pull requests; approval gates;
policy checks that can block risky changes; a private module registry; and access control.


### 🧠 Mental models (from the original 15-day notes)

- **HCP Terraform = the same script run through a governed release pipeline.** Your `.tf`
  files and the plan/apply mental model don't change. What's added: a review gate between
  "here's what I'll do" and "done" (Sentinel/OPA), a shared audit trail, permission to pull
  the trigger, and short-lived credentials instead of a master key.
- **`sensitive = true` = a redacted photocopy.** The line shows `(sensitive value)` on screen,
  but the original document (state) still has the real text underneath.
- **Execution modes = where the work happens, not how it's triggered.** Remote: HCP's
  workers. Local: your machine, HCP only stores state. Agent: your own runner inside a
  private network that HCP can't reach. Workflows (VCS / CLI / API) are a separate question:
  *how a run starts*.

---

## C. Technical deep dive

### C1. Hierarchy

```
Organization  (billing, SSO, teams, org-wide settings, policy sets, private registry)
 └── Project  (group of workspaces; permissions & variable sets can be scoped here)
      └── Workspace  (one config + one state + variables + run history + permissions)
           └── Runs  (plan → [cost est.] → [policy check] → [run tasks] → apply)
```
- **Teams** get permissions on projects/workspaces (read, plan, write, admin, or custom).
- One workspace ≈ one state. Typical: `network-prod`, `network-dev`, `app-prod`, …
- **Projects** organise workspaces (e.g. by business unit or application) and simplify access management.

### C2. Workflows

| Workflow | Trigger | Where config comes from | Typical use |
|---|---|---|---|
| **VCS-driven** | Push/merge to linked repo branch; PR → **speculative plan** posted as a status check | Linked GitHub/GitLab/Bitbucket/Azure DevOps repo | Standard GitOps |
| **CLI-driven** | `terraform plan/apply` on your machine with a `cloud` block | Your local directory, uploaded | Developer iterating; CI pipelines you control |
| **API-driven** | API calls (upload config version, create run) | Uploaded by an external system | Custom orchestration |

**Speculative plan** = plan-only run (can't be applied): on PRs in VCS workflow, and when you
run `terraform plan` in CLI-driven workflow.

### C3. Connecting the CLI (8d)

```hcl
terraform {
  cloud {
    organization = "jk-labs"
    # hostname = "app.terraform.io"   # default; set for Terraform Enterprise
    workspaces {
      name = "three-tier-prod"        # one specific workspace
      # tags = ["app:three-tier"]     # OR select from workspaces with these tags
      # project = "three-tier"
    }
  }
}
```
```bash
terraform login            # browser → generate user API token → saved in ~/.terraform.d/credentials.tfrc.json
terraform init             # connects; offers to migrate existing state
terraform plan             # streamed from HCP Terraform (remote execution)
```
- `cloud` block (1.1+) replaces using `backend "remote"`. Can't have both a `cloud` and `backend` block.
- `TF_TOKEN_app_terraform_io` env var can supply the token in CI.
- `TF_CLOUD_ORGANIZATION` / `TF_WORKSPACE` env vars can supply org/workspace.
- With `workspaces { tags = [...] }`, `terraform workspace select` chooses among matching workspaces.

### C4. Execution modes
| Mode | Where Terraform runs | State |
|---|---|---|
| **Remote** (default) | HCP-managed worker | HCP Terraform |
| **Local** | Your machine | HCP Terraform (used only as a state backend) |
| **Agent** | Self-hosted HCP Terraform agents inside your network | HCP Terraform |

Remote execution means: the run happens on an HCP worker, so **environment variables on
your laptop (e.g. `AWS_PROFILE`, `TF_VAR_x`) are not available** — set them as workspace
variables or variable sets. Files in the uploaded configuration directory (including
`*.auto.tfvars`) do travel with the upload. Credentials live in HCP Terraform, and the
Terraform version is set per workspace.

### C5. Run lifecycle

```
 Pending → Plan → (Cost estimation) → (Policy check) → (Run tasks) → [Confirm & Apply / auto-apply] → Apply → Applied
                                           │
                    hard-mandatory fail ───┘──► run stops, cannot apply
                    soft-mandatory fail ──────► stops unless authorised user overrides
                    advisory fail ────────────► warning only
```
- Workspaces can be set to **auto-apply** or require manual confirmation.
- Runs are queued per workspace (one at a time); state locked during runs.
- Run triggers: one workspace's successful apply can queue a run in another (e.g. network → app).

### C6. Variables (8a/8c)
- Two kinds per workspace: **Terraform variables** (map to `variable` blocks) and
  **environment variables** (e.g. `AWS_REGION`, `TF_LOG`, `TF_VAR_x`).
- Mark **sensitive** → write-only in the UI/API (can't be read back), redacted in logs.
- **Variable sets**: reusable groups applied to the org, specific projects, or workspaces
  (e.g. shared cloud credentials). Workspace-specific variables override variable-set values.
- Exact precedence rules between variable sets (including "priority" variable sets) and
  workspace variables are detailed and version-dependent; I am not confident enough to
  give you a full ordering. Exam-safe rule: **workspace-specific variables override
  ordinary variable-set values**.

### C7. Collaboration & governance (8b)

| Feature | What it does |
|---|---|
| Remote state + versions | Every apply stores a state version; roll back / inspect history |
| Team-based access | Permissions per project/workspace |
| **Sentinel** / **OPA** policies | Policy as code evaluated against plan (+ config/state data). Enforcement: **advisory**, **soft-mandatory**, **hard-mandatory** (Sentinel terms; OPA uses advisory/mandatory) |
| Policy sets | Groups of policies applied to org/projects/workspaces |
| **Run tasks** | Call external services (security scanners, cost tools) at run stages |
| **Cost estimation** | Estimates monthly cost change for supported resources, before apply |
| **Private registry** | Share internal modules & providers with versions |
| **No-code provisioning** | Deploy approved modules from the UI without writing HCL |
| **Drift detection / health assessments** | Scheduled checks for drift and `check` block results |
| **Dynamic provider credentials** | Workspace uses OIDC to get short-lived cloud creds (AWS/Azure/GCP/Vault) — no static keys |
| Audit trails | Who ran what, approvals, state versions |
| Notifications | Slack/email/webhook on run events |
| SSO, MFA | Org-level identity |

### C8. Secrets & sensitive data (4h)

Layers of defence:
1. **Never hard-code** secrets in `.tf` or committed `.tfvars`. Add `*.tfvars` with secrets to `.gitignore`.
2. Supply via env vars (`TF_VAR_db_password`), HCP Terraform sensitive variables, or a secrets manager.
3. Mark variables/outputs `sensitive = true` (display redaction only).
4. **Protect state & plan files** (encrypted backend, least privilege) — secrets in state are plaintext.
5. Prefer **short-lived credentials**: OIDC (your GitHub Actions → AWS role), dynamic provider credentials, Vault.
6. Use **ephemeral** variables/resources (1.10+) and **write-only arguments** (1.11+, e.g. `password_wo` with `password_wo_version`) to keep secrets out of state where providers support them.
7. Generate secrets in the service where possible (e.g. RDS-managed master password in Secrets Manager).

**Vault with Terraform**
```hcl
provider "vault" {}   # address/token via VAULT_ADDR / VAULT_TOKEN, or auth method

data "vault_kv_secret_v2" "db" {
  mount = "secret"
  name  = "three-tier/db"
}

resource "aws_db_instance" "main" {
  password = data.vault_kv_secret_v2.db.data["password"]   # ⚠ ends up in state
}
```
- Vault's **dynamic secrets** engines (e.g. AWS secrets engine) issue short-lived credentials:
  `data "vault_aws_access_credentials"` → feed into the AWS provider, so no long-lived keys exist.
- Reading a secret via a **data source** still stores it in state. With newer Terraform and
  Vault provider versions, an **ephemeral resource** (`ephemeral "vault_kv_secret_v2" ...`)
  avoids persisting it (version-dependent; recognition level).

### C9. Supply chain & trust
- Use providers from trusted namespaces; check tier (Official/Partner/Community).
- Pin provider versions and **commit the lock file** (hash verification).
- Pin modules to versions/tags; review third-party module code; prefer a private registry of vetted modules.
- `terraform providers mirror` / network mirrors for air-gapped or controlled environments.

### C10. CI/CD and operational controls
- Plan on PR, apply on merge; apply **the saved plan** that was reviewed.
- `-input=false`, `-no-color`, `-lock-timeout`; fail on `fmt -check` and `validate`.
- Least-privilege deploy roles; separate roles per environment.
- Protect prod with approvals (HCP manual apply / GitHub environments).
- Drift detection job (`plan -detailed-exitcode`).
- Avoid `-target` and `-auto-approve` on unreviewed plans.

---

## D. Why it matters
HCP Terraform is a full domain (8) of the 004 exam. Security-of-state and secrets questions
appear in several domains. You already practise much of C10 in GitHub Actions — today you
map it to HCP Terraform vocabulary.

---

## E. Reference — HCP Terraform vs CLI-only

| Need | CLI + S3 backend | HCP Terraform |
|---|---|---|
| Shared state & locking | S3 + lockfile/DynamoDB | Built-in, versioned |
| Where runs execute | Your laptop/CI | Remote workers (or agents/local) |
| PR plan comments | You build it | VCS integration, speculative plans |
| Policy as code | Third-party tools in CI | Sentinel/OPA built-in |
| Secrets for runs | CI secrets / OIDC | Sensitive vars, variable sets, dynamic credentials |
| Private module sharing | Git tags | Private registry |
| Access control | IAM on bucket | Teams × projects/workspaces |

---

## F. Worked example — migrating the static-site project to HCP Terraform

1. Create org `jk-labs`, project `static-site`, workspace `static-site-prod` (CLI-driven).
2. Add `cloud` block (C3) replacing the `backend "s3"` block.
3. `terraform login`; `terraform init` → "Do you wish to migrate state?" → yes.
4. In workspace: configure **dynamic provider credentials** for AWS (OIDC trust to an IAM role) or add env vars from a variable set.
5. Set `domain_name` Terraform variable; mark any secrets sensitive.
6. `terraform plan` → streamed remote run, expect **No changes** (state migrated correctly).
7. Attach policy set: hard-mandatory "S3 buckets must block public access".
8. Later switch to VCS-driven: link repo; PRs now get speculative plans.

---

## G. Visual — VCS-driven run

```
 Developer ──push branch──► GitHub ──PR opened──► HCP Terraform: speculative plan ──► status on PR
                                    ──merge to main──► HCP Terraform run:
                                         plan → cost estimate → policy check → (approve) → apply
                                                                    │
                                                         state version saved, notifications sent
```

---

## H. Common misconceptions

| # | Misconception | Reality |
|---|---|---|
| 1 | "HCP Terraform workspaces = CLI workspaces." | HCP workspaces hold config link, vars, state, permissions, runs. |
| 2 | "Policies run before plan." | After plan (they evaluate the plan). |
| 3 | "Soft-mandatory can never be bypassed." | Authorised users can override; hard-mandatory cannot be overridden. |
| 4 | "Sensitive variables are hidden from state." | They're redacted in UI/logs; values used by resources still go into state. |
| 5 | "My laptop's env vars apply to remote runs." | Remote runs use workspace variables. |
| 6 | "Speculative plans can be applied." | Plan-only. |
| 7 | "Vault data source keeps the secret out of state." | It doesn't; ephemeral resources do (newer versions). |
| 8 | "Terraform Enterprise is a different language." | Same Terraform; self-hosted platform. |

---

## I. Exam traps
- "Which TWO are HCP Terraform features?" — watch for invented features ("automatic rollback of failed applies", "removes the need for state").
- `terraform login` stores a token — not cloud provider credentials.
- Cost estimation happens **before** apply (after plan).
- Policy enforcement level that allows override → **soft-mandatory**.
- Where to put shared AWS credentials for 30 workspaces → **variable set** (or dynamic credentials).

**More traps from the original notes**
- **Cost estimation** covers supported resources on the major clouds (AWS, Azure, GCP), not
  every provider, and runs after plan, before apply.
- **Agent mode** is for infrastructure with **no public network access**, not just "teams who
  prefer local execution" (that's Local mode).
- **HCP Terraform extends, not replaces, open-source Terraform.** Same language, same CLI.
- **Vault data sources still put the secret in state.** Vault solves "no secrets in `.tf`/Git";
  ephemeral resources and write-only arguments solve "no secrets in state".

---

## J. Active recall
1. Order of run stages?
2. Three Sentinel enforcement levels and what each does on failure?
3. What does the `cloud` block need at minimum?
4. Difference between remote and local execution mode?
5. What is a variable set?
6. Two ways to keep secrets out of state in modern Terraform?

<details><summary>Answers</summary>

1. Plan → cost estimation → policy check → (run tasks around these stages) → apply.
2. Advisory (warn), soft-mandatory (block unless overridden), hard-mandatory (block, no override).
3. `organization` and a `workspaces` selection (`name` or `tags`/`project`); hostname defaults to app.terraform.io.
4. Remote: Terraform runs on HCP workers; local: runs on your machine, HCP stores state only.
5. A reusable group of variables applied to multiple workspaces/projects/org.
6. Ephemeral values/resources; write-only arguments. (Also: let the service generate/manage the secret.)
</details>

---

## K. Practice exercises

**K1.** A security team wants to block any plan that opens port 22 to 0.0.0.0/0, with no
exceptions. Which feature and enforcement level?

**K2.** Developers run `terraform plan` locally with the `cloud` block. Where does the plan run and can they `apply` from it if the workspace is VCS-driven?

**K3.** You need AWS creds in 25 workspaces, rotated without touching each workspace. Options?

**K4.** True/False: `sensitive = true` on an output prevents it being written to state.

<details><summary>Answers</summary>

**K1.** Sentinel (or OPA) policy, **hard-mandatory**.
**K2.** Remotely (speculative plan streamed to the terminal). VCS-driven workspaces reject CLI `apply` — applies come from VCS merges.
**K3.** Dynamic provider credentials (OIDC, best); or a variable set with the credentials scoped to a project/org.
**K4.** False — outputs are stored in state; sensitive only redacts display.
</details>

> Optional real-cloud practice: [AWS lab A8 — HCP Terraform free tier](../labs/aws-optional/README.md#a8--hcp-terraform-cli-driven-workflow-day-7).

---

## L. Lesson assessment — mastery quiz

Closed book. Write every answer down **before** opening the answers, and give each a confidence (1 = guess, 2 = unsure, 3 = sure). Pass mark: **9/11**. Record the score in [SCORECARD.md](../SCORECARD.md) and log misses in [mistakes/error-log.md](../mistakes/error-log.md).

*These questions are the self-test questions from the original 15-day notes, corrected and regrouped by topic.*

1. Does `sensitive = true` encrypt the value in state?
2. What is the recommended way to provide real secrets instead of plaintext `.tfvars`?
3. What was HCP Terraform previously called?
4. Differentiate Remote, Local and Agent execution modes.
5. What do Sentinel and OPA provide, and when do they run?
6. What are the Sentinel enforcement levels and what does each do on failure?
7. What does the `cloud` block enable?
8. Security benefit of dynamic provider credentials over static workspace credentials?
9. What groups related workspaces for organization and shared access?
10. In a VCS-driven workflow, what triggers a speculative plan vs a real run?
11. Which clouds does cost estimation cover?

<details><summary>Answers</summary>

1. No. It only redacts CLI/UI output; state holds plain text.
2. A secrets manager such as Vault (via its provider), sensitive workspace variables, or CI secrets passed as `TF_VAR_`. Plus ephemeral values / write-only arguments to keep them out of state, and protect state either way.
3. Terraform Cloud. (Terraform Enterprise is the self-hosted edition.)
4. Remote: runs on HCP-managed workers (default). Local: runs on your machine, and HCP only stores state. Agent: runs on self-hosted agents inside your network.
5. Policy as code, evaluated after plan (and cost estimation) and before apply.
6. Advisory: warns and the run continues. Soft-mandatory: blocks unless an authorized user overrides. Hard-mandatory: blocks, no override.
7. The CLI-driven workflow: local `terraform plan/apply` run in an HCP Terraform workspace, which also stores state. Authenticate first with `terraform login`.
8. Each run gets short-lived OIDC credentials that expire quickly; a leaked static key stays valid until someone rotates it.
9. A project.
10. Opening or updating a pull request → speculative plan (can't be applied). Merging to the tracked branch → a real run (applied after confirmation, or automatically if auto-apply is on).
11. Supported resources on AWS, Azure and GCP.
</details>

## M. Summary
- HCP Terraform: org → project → workspace → runs; teams for access.
- Workflows: VCS (speculative plans on PRs), CLI (`cloud` block + `terraform login`), API.
- Execution: remote (default), local, agent.
- Runs: plan → cost → policy → apply; policies advisory/soft/hard.
- Variables (Terraform/env, sensitive), variable sets, dynamic credentials.
- Secrets: not in code; sensitive ≠ encrypted; protect state; Vault; ephemeral/write-only.

### Flashcards (Day 7)
| Front | Back |
|---|---|
| HCP Terraform hierarchy | Organization → Project → Workspace → Runs |
| Speculative plan | Plan-only run (PRs, CLI plan); can't be applied |
| `cloud` block min | organization + workspaces (name or tags) |
| Token from `terraform login` | `~/.terraform.d/credentials.tfrc.json` |
| Policy check timing | After plan (and cost estimation), before apply |
| Override allowed | Soft-mandatory |
| Shared vars across workspaces | Variable sets |
| No static cloud keys | Dynamic provider credentials (OIDC) |
| Run on private network | HCP Terraform agents |
| Self-hosted HCP Terraform | Terraform Enterprise |

## N. Mastery decision
8–10 ✅ then Mock 1 · 6–7 ➕ review C5–C8 then Mock 1 · ≤5 🔁 re-teach before Mock 1.
