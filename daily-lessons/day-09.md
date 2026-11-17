# Day 9 — Full Mock Exam and Weakness Remediation

**Assessment:** [Mock Exam 2](../practice-exams/mock-exam-02.md) — 57 questions, 60 minutes, closed book.
**Then:** targeted remediation using the blocks below (pick your weakest 5 from your Mock 2 marking in SCORECARD.md).

> Format note: 57 Q / 60 min approximates the exam format I believe applies (see
> EXAM_OBJECTIVES.md). It is a simulation, not an official specification.

---

## A. Learning objectives
1. Perform under time pressure (~63 seconds per question).
2. Classify every mistake: **knowledge gap**, **confused similar concepts**, **misread**, **guess**.
3. Close the five weakest objectives with focused re-teaching and re-testing.

## B. Exam technique (read before starting the mock)

**Pacing plan (60 min)**
```
 0–25 min   Q1–Q28   first pass; flag anything > 90 s
25–50 min   Q29–Q57  first pass
50–58 min   flagged questions
58–60 min   check every question has an answer (no penalty for guessing, as far as I know)
```

**Per-question routine**
1. Read the **ask** first: ONE / TWO / NOT / FIRST / SAFEST / BEST.
2. Identify the **world**: config, state, plan, or reality?
3. Predict an answer **before** reading options.
4. Eliminate options with absolutes or invented features.
5. For multi-select, evaluate each option independently as true/false.

**Classic distractor patterns**
| Pattern | Example |
|---|---|
| Real command, wrong job | `terraform validate` offered for "detect drift" |
| Deprecated but working | `terraform refresh` vs `apply -refresh-only` — choose the recommended one unless asked about the deprecated one |
| Invented flag | `terraform state unlock`, `terraform plan -import` |
| Right concept, wrong scope | "sensitive encrypts state" |
| Absolute words | "always", "guarantees", "never needs" |
| CLI vs HCP workspace swap | features of one attributed to the other |

---

## C. Remediation blocks
Each block: 5-minute re-teach summary → 3 fresh check questions (answers hidden).

### R1. Variable precedence and var files
Lowest→highest: default · `TF_VAR_` · `terraform.tfvars` · `terraform.tfvars.json` · `*.auto.tfvars(.json)` (lexical) · `-var`/`-var-file` (CLI order, last wins). Non-auto files need `-var-file`.

1. `a.auto.tfvars` sets x=1, `b.auto.tfvars` sets x=2. Value?
2. `terraform.tfvars` x=3, `TF_VAR_x=4`. Value?
3. `-var x=5 -var-file=f.tfvars` where f sets x=6. Value?
<details><summary>Answers</summary>1. 2 (b after a lexically) · 2. 3 · 3. 6 (last on command line wins)</details>

### R2. count vs for_each
Index shift with `count`; stable keys with `for_each`; `toset()` lists; keys must be known at plan.

1. `for_each = ["a","b"]` → error or OK?
2. Reference the `arn` of key "b" in `aws_iam_user.u`.
3. Convert `count`-based `x[0]` to `for_each` key "web" without destroy?
<details><summary>Answers</summary>1. Error (list) — use `toset()` · 2. `aws_iam_user.u["b"].arn` · 3. `moved { from = x[0]  to = x["web"] }` (with full type prefix)</details>

### R3. State commands vs infrastructure
`state rm/mv/push/replace-provider` and `force-unlock` never touch real infrastructure.

1. Stop managing a bucket but keep it — two methods?
2. After `state rm` with block still in config, plan shows?
3. Which command shows one resource's attributes?
<details><summary>Answers</summary>1. `terraform state rm` / `removed { lifecycle { destroy = false } }` · 2. create · 3. `terraform state show ADDR`</details>

### R4. Import
Import block + `plan -generate-config-out` (1.5+), or `terraform import ADDR ID` (needs existing block). Always plan after.

1. Does CLI import write HCL?
2. Which flag generates config?
3. Can an import change the real resource?
<details><summary>Answers</summary>1. No · 2. `-generate-config-out=FILE` on plan · 3. Import itself no; a subsequent apply may, if config differs</details>

### R5. Backends and locking
One backend, no variables (partial config), `init -migrate-state` vs `-reconfigure`, lock on write ops, `force-unlock`.

1. Inject bucket name per env at init?
2. Change backends and copy state?
3. Which operations lock?
<details><summary>Answers</summary>1. `terraform init -backend-config=...` · 2. `terraform init -migrate-state` · 3. All that may write state: plan, apply, destroy, refresh, import, state-modifying commands</details>

### R6. Modules
Sources, `version` only for registry, `?ref=` for Git, scope, outputs, provider passing.

1. Module from Git tag v2.0.0?
2. Child needs `aws.east`?
3. Can root reference `module.m.aws_s3_bucket.b.arn`?
<details><summary>Answers</summary>1. `source = "git::https://host/repo.git?ref=v2.0.0"` · 2. `providers = { aws = aws.east }` (child declares `configuration_aliases` if it uses an aliased name) · 3. No — expose an output</details>

### R7. Lifecycle and custom conditions
CBD, prevent_destroy, ignore_changes, replace_triggered_by, pre/postconditions (error), check (warning), validation (error, variable).

1. Warn but don't block when health endpoint fails?
2. Block plan if an AMI isn't x86_64?
3. Stop reverting autoscaler changes?
<details><summary>Answers</summary>1. `check` block · 2. `precondition` in lifecycle · 3. `ignore_changes`</details>

### R8. CLI workflow details
`apply PLANFILE` no prompt; `-refresh-only`; `-replace`; `fmt -check`; `validate` offline; `init -upgrade`.

1. Recreate one resource?
2. CI format check?
3. Which command updates the lock file to newer allowed versions?
<details><summary>Answers</summary>1. `terraform apply -replace=ADDR` · 2. `terraform fmt -check -recursive` · 3. `terraform init -upgrade`</details>

### R9. HCP Terraform
Org → project → workspace; VCS/CLI/API; remote/local/agent; plan → cost → policy → apply; advisory/soft/hard; variable sets; dynamic creds; private registry.

1. Override allowed for which enforcement level?
2. Reusable credentials across 20 workspaces?
3. What is created on a PR in VCS-driven workflow?
<details><summary>Answers</summary>1. Soft-mandatory · 2. Variable set (or dynamic credentials) · 3. A speculative plan</details>

### R10. Sensitive data
`sensitive` = display only; state plaintext; protect state; Vault; ephemeral/write-only.

1. Is `sensitive = true` output stored in state?
2. Two ways to keep a password out of state?
3. Where should DB passwords be supplied from in CI?
<details><summary>Answers</summary>1. Yes · 2. Ephemeral values/resources; write-only arguments (also service-managed secrets) · 3. Secret store / CI secret → `TF_VAR_`, HCP sensitive variable, or Vault — never committed files</details>

---

## D–N condensed (for this assessment day)
- **D. Why:** time pressure exposes shaky knowledge that untimed study hides.
- **H. Misconceptions:** review the misconception tables from Days 1–8 for your weak domains.
- **K. Practice:** after remediation, answer the questions in [Mock Exam 4](../practice-exams/mock-exam-04.md) tagged with your weakest domains (check the domain column in the answer key), plus the matching flashcard section.
- **L. Assessment:** after remediation, a 15-question targeted retest; ≥ 13/15 to close each weak topic.
- **M. Summary:** record all updates in SCORECARD.md and weak-topics.md.
- **N. Mastery decision:** Mock 2 ≥ 85% and no domain < 80% → Day 10 as planned. 75–84% → extra remediation tonight. < 75% → honest discussion of exam date.
