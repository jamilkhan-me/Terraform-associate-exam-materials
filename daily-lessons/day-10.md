# Day 10 — Final Assessment and Exam Readiness

**Assessment:** [Mock Exam 3](../practice-exams/mock-exam-03.md) — 57 fresh questions, 60 minutes, exam conditions.
Then: rapid-fire quiz, misconception test, [QUICK_REVISION.md](../QUICK_REVISION.md), readiness assessment.

---

## A. Learning objectives
1. Demonstrate exam-level performance on unseen questions.
2. Compare Diagnostic → Mock 1 → Mock 2 → Mock 3 by domain.
3. Eliminate remaining misconceptions with a rapid-fire test.
4. Produce an honest readiness judgement.

## B. Exam-day logistics (general guidance)
- Online proctored exams typically require a clean desk, ID, webcam, and a system check
  beforehand — follow the instructions in **your** booking confirmation (I can't verify the
  current proctoring rules).
- Sleep beats cramming. Final review: QUICK_REVISION.md + weak-topics flashcards only.

**Exam-day checklist (from the original notes)**
- [ ] Confirmation email and system requirements at hand; run the proctoring system check in advance
- [ ] Webcam, microphone and internet tested at least an hour before
- [ ] Government photo ID ready, with the name matching your registration exactly
- [ ] Desk clear: no second monitor, no phone in reach, no notes in view
- [ ] Every other application closed (proctoring software checks running processes)
- [ ] Log in 15 minutes early so check-in friction doesn't eat exam time
- [ ] Read every question to the **last clause**: "which is NOT", "select TWO", "without
      changing real infrastructure". Rushing the qualifier is the cheapest way to lose a mark you knew.

**Evening before:** one pass over [QUICK_REVISION.md](../QUICK_REVISION.md), retake only the
questions you missed in your worst mock, and reason through each one. No new topics.

---

## C. Rapid-fire CLI/HCL quiz (40 items, ~10 min)
Answer aloud or on paper; answers hidden below.

1. Command that downloads providers.
2. Flag to upgrade providers within constraints.
3. Command that rewrites files to canonical style.
4. Command that checks config without contacting APIs.
5. Save a plan to a file.
6. Apply a saved plan.
7. Replacement for `terraform refresh`.
8. Replacement for `terraform taint`.
9. Preview a destroy.
10. Read output `url` without quotes.
11. List resources in state.
12. Show one resource from state.
13. Rename in state (CLI).
14. Rename via config.
15. Forget a resource (CLI).
16. Forget via config.
17. Import via CLI.
18. Generate config for imports.
19. Remove a stuck lock.
20. Copy state to a new backend.
21. Switch backend without copying state.
22. Create a CLI workspace.
23. Variable for current workspace name in HCL.
24. Verbose logging env var + file env var.
25. Authenticate to HCP Terraform.
26. Block in config that connects to HCP Terraform.
27. Reference data source attribute.
28. Reference module output.
29. Reference for_each instance "a" of `aws_instance.w`.
30. Expression for an optional resource with `count`.
31. Function combining maps.
32. Function combining lists.
33. Function returning default for missing map key.
34. Convert list to set.
35. Pessimistic constraint allowing 2.x but not 3.0 starting at 2.1.
36. Lifecycle setting for zero-downtime replacement.
37. Lifecycle setting to ignore an attribute.
38. Meta-argument for hidden dependencies.
39. Block that warns but doesn't fail.
40. File that pins provider versions and hashes.

<details><summary>Answers</summary>

1 `terraform init` · 2 `init -upgrade` · 3 `terraform fmt` · 4 `terraform validate` ·
5 `plan -out=FILE` · 6 `apply FILE` · 7 `apply -refresh-only` · 8 `apply -replace=ADDR` ·
9 `plan -destroy` · 10 `output -raw url` · 11 `state list` · 12 `state show ADDR` ·
13 `state mv` · 14 `moved` block · 15 `state rm` · 16 `removed` block with `destroy = false` ·
17 `terraform import ADDR ID` · 18 `plan -generate-config-out=FILE` · 19 `force-unlock ID` ·
20 `init -migrate-state` · 21 `init -reconfigure` · 22 `workspace new NAME` ·
23 `terraform.workspace` · 24 `TF_LOG`, `TF_LOG_PATH` · 25 `terraform login` · 26 `cloud` ·
27 `data.TYPE.NAME.ATTR` · 28 `module.NAME.OUTPUT` · 29 `aws_instance.w["a"]` ·
30 `count = var.enabled ? 1 : 0` · 31 `merge` · 32 `concat` · 33 `lookup` · 34 `toset` ·
35 `~> 2.1` · 36 `create_before_destroy` · 37 `ignore_changes` · 38 `depends_on` ·
39 `check` · 40 `.terraform.lock.hcl`
</details>

---

## H. Misconception test — True or False (20 items)

1. `terraform plan` writes refreshed values to state.
2. `sensitive = true` keeps a value out of state.
3. The lock file records module versions.
4. `terraform state rm` deletes the real resource.
5. A backend block can reference `var.region`.
6. `for_each` accepts a list of strings directly.
7. Child modules automatically see root variables.
8. `version` in a module block works for registry sources only.
9. A `check` block failure stops the apply.
10. `terraform apply tfplan` prompts for approval.
11. `prevent_destroy` stops someone deleting the resource in the AWS console.
12. CLI workspaces share the same configuration.
13. The `default` workspace can be deleted.
14. Failed applies are rolled back automatically.
15. `terraform validate` requires providers to be installed.
16. `terraform import` (CLI) needs a matching resource block.
17. Hard-mandatory policy failures can be overridden by org owners.
18. Data sources can create resources if missing.
19. Provisioners are the recommended way to configure servers.
20. Terraform decides ForceNew attributes itself, independent of providers.

<details><summary>Answers</summary>

1 F · 2 F · 3 F · 4 F · 5 F · 6 F · 7 F · 8 T · 9 F · 10 F · 11 F · 12 T · 13 F · 14 F ·
15 T · 16 T · 17 F · 18 F · 19 F · 20 F
</details>

---

## L. Readiness rubric (honest assessment)

| Evidence | Strong | Borderline | Not yet |
|---|---|---|---|
| Mock 3 (fresh) | ≥ 85% | 75–84% | < 75% |
| Mock 2 → Mock 3 trend | stable/up | slight drop | large drop |
| Lowest domain | ≥ 80% | 70–79% | < 70% |
| "Sure" answers wrong | ≤ 2 | 3–5 | > 5 |
| Error-log re-tests | all correct | 1–2 open | 3+ open |
| Rapid-fire | ≥ 36/40 | 30–35 | < 30 |

Interpretation:
- **Strong** in all rows → knowledge appears sufficient; sit the exam as planned.
- **Borderline** anywhere → targeted 1–2 day extension on those domains is worth considering.
- **Not yet** in two or more rows → recommend rescheduling if your booking allows.

No score here guarantees a pass; the real exam's questions, weighting, and passing
standard are not known to me with certainty.

## M. Summary
Use [QUICK_REVISION.md](../QUICK_REVISION.md) as the final sheet. Re-read the "Frequently
confused" table and your personal weak-topics list the morning of the exam.

## N. Final decision
Recorded in PROGRESS.md with the comparison table Diagnostic → Mock 1 → Mock 2 → Mock 3.
