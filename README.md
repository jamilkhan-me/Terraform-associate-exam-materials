# Terraform Associate — 10-Day Bootcamp

A self-contained, offline course to prepare for the **HashiCorp Certified: Terraform
Associate** exam (assumed version **004** — see [EXAM_OBJECTIVES.md](EXAM_OBJECTIVES.md)).

Everything you need is in this folder. No external tutorials, docs, or question banks.

---

## How to use this workspace

```
1. Open PROGRESS.md            → see where you are and the next action
2. Open daily-lessons/day-NN.md → study the day's lesson (answers are in collapsed <details>)
3. Do the day's lab(s) in labs/ → starter files in starter/, solutions in SOLUTION.md
4. Answer quiz questions in chat → your instructor marks them and updates the trackers
5. Log mistakes in mistakes/error-log.md (the instructor does this for you)
6. Before the exam             → QUICK_REVISION.md + flashcards/weak-topics.md
```

### Answer-hiding rules
- Lesson active-recall answers are inside collapsed `<details>` blocks. Answer **before** expanding.
- Exam questions are in `practice-exams/*.md`; **all** answers are in
  `practice-exams/answer-keys.md`. Do not open the key until you have submitted.
- Lab solutions live in each lab's `SOLUTION.md`, separate from the task list.

---

## Map of the workspace

| Path | Purpose |
|---|---|
| [EXAM_OBJECTIVES.md](EXAM_OBJECTIVES.md) | Assumed exam version, objective map, uncertainties |
| [STUDY_PLAN.md](STUDY_PLAN.md) | The 10-day schedule with time blocks |
| [PROGRESS.md](PROGRESS.md) | **Single source of truth** for progress, weak areas, next action |
| [SCORECARD.md](SCORECARD.md) | Every quiz/mock score and per-domain performance |
| [DAILY_CHECKLIST.md](DAILY_CHECKLIST.md) | The routine to follow each day |
| [QUICK_REVISION.md](QUICK_REVISION.md) | Final revision sheet (last 24 hours) |
| [GLOSSARY.md](GLOSSARY.md) | Every term you must be able to define |
| `daily-lessons/` | Day 1–10 lessons (structure A–N for each topic) |
| `labs/` | 12 hands-on labs, runnable offline once the Terraform CLI is installed |
| `practice-exams/` | Diagnostic, three mock exams, answer keys |
| `flashcards/` | Flashcards for active recall + a live weak-topic list |
| `mistakes/error-log.md` | Every mistake, the rule behind it, and a re-test question |

---

## Lab environment

**Terraform CLI was not installed in the environment where this course was generated**,
so labs have not been executed here. They are designed to run on your machine:

- Install Terraform **1.5 or newer** (1.12+ preferred, to match the assumed exam version).
- Labs use only the **built-in** `terraform` provider (`terraform_data`,
  `terraform_remote_state`) plus `local-exec` provisioners — **no provider downloads, no
  cloud account, no cost**.
- Where a topic genuinely needs a cloud provider (e.g. importing a real S3 bucket), the lab
  is **conceptual** with realistic mock output, and states that clearly.
- Labs never touch your existing AWS projects or state files. Run them only inside
  `labs/lab-NN/starter/`.

Check your version:

```bash
terraform version
```

---

## Readiness targets (study targets — not official pass marks)

- ≥ **85%** on fresh, unseen mock exams
- No exam domain consistently below **80%**
- Error-log re-test questions answered correctly

Meeting these is evidence of readiness, **not** a guarantee of passing.
