# Terraform Associate (004) — Complete Study Course

One self-contained resource for the **HashiCorp Certified: Terraform Associate (004)** exam.
It combines two earlier resources into a single path, so you don't need to switch between
them:

- **This repository's 10-day bootcamp:** structured lessons, 12 offline labs, a diagnostic,
  three mock exams, flashcards and trackers. This is the backbone.
- **The original 15-day notes** ([Terraform-learning-resources](https://github.com/jamilkhan-me/Terraform-learning-resources)):
  explanations, analogies, gotchas, ~95 self-test questions, two practice exams, AWS
  hands-on labs, a cheat sheet and a progress tracker. All of it is merged in here and
  corrected (see [What changed in the merge](#what-changed-in-the-merge)).

You can treat the old repository as retired.

---

## Start here

```
1. EXAM_OBJECTIVES.md      → the exam format and the 34 objectives (5 min)
2. STUDY_PLAN.md           → pick 10 days (default, ~4 h/day) or relaxed 15 days (~2 h/day)
3. practice-exams/diagnostic-test.md → take it BEFORE studying; mark it; fill SCORECARD.md
4. Each day: daily-lessons/day-NN.md → labs → mastery quiz (section L) → update PROGRESS.md
5. Mocks 1–3 on Days 7, 9, 10. Mocks 4–5 on optional Days 11–12.
6. Last 24 hours: QUICK_REVISION.md + flashcards/weak-topics.md. Nothing new.
```

Track progress in [PROGRESS.md](PROGRESS.md), or open [tracker.html](tracker.html) in a
browser for clickable checklists and score bars (saved in that browser only).

### How each lesson is laid out
Every `day-NN.md` follows the same order: **A** objectives · **B** plain-English explanation +
🧠 mental models · **C** technical deep dive · **D** why it matters · **E** reference ·
**F** worked example · **G** visual · **H** misconceptions · **I** exam traps ·
**J** active recall · **K** practice (+ optional AWS lab) · **L** mastery quiz ·
**M** summary + flashcards · **N** what to do next based on your score.

### Rules that make it work
- **Answer before you look.** Answers are in collapsed `<details>` blocks; mock answers are
  only in [practice-exams/answer-keys.md](practice-exams/answer-keys.md).
- **Give a confidence (1–3) for every answer.** Confident-and-wrong answers are the
  dangerous misconceptions; fix those first.
- **Log every miss** in [mistakes/error-log.md](mistakes/error-log.md). A topic you miss twice
  goes into [flashcards/weak-topics.md](flashcards/weak-topics.md).

---

## Map

| Path | What it is |
|---|---|
| [EXAM_OBJECTIVES.md](EXAM_OBJECTIVES.md) | Exam snapshot, the objective map (where each one is taught), uncertainties |
| [STUDY_PLAN.md](STUDY_PLAN.md) | 10 + 2 day plan with time blocks; relaxed 15-day pacing |
| [DAILY_CHECKLIST.md](DAILY_CHECKLIST.md) | The routine for every study day |
| [PROGRESS.md](PROGRESS.md) · [SCORECARD.md](SCORECARD.md) · [tracker.html](tracker.html) | Where you are, and every score by domain |
| `daily-lessons/` | Days 1–10 |
| `labs/` | 12 offline labs (`lab-01`–`lab-12`, no cloud account needed) + [8 optional AWS labs](labs/aws-optional/README.md) |
| `practice-exams/` | Diagnostic (30 Q), Mocks 1–5 (40 / 57 / 57 / 50 / 46 Q), answer keys with explanations |
| `flashcards/` | Master deck by domain + your live weak-topic deck |
| [QUICK_REVISION.md](QUICK_REVISION.md) | Final sheet: the 10 most-missed facts, every domain, confused pairs |
| [GLOSSARY.md](GLOSSARY.md) | Every term you should be able to define |
| `mistakes/error-log.md` | Your mistakes, the rule behind each, and re-test questions |

## Lab environment
- Install Terraform **1.12.x** (matches the exam; 1.5+ works for the offline labs).
- Offline labs use only the built-in `terraform` provider (`terraform_data`,
  `terraform_remote_state`) and `local-exec`: no downloads, no account, no cost.
- AWS labs need a sandbox AWS account and cost almost nothing **if you `terraform destroy`
  every session**.
- The labs were written from documented behaviour and haven't been run in an automated
  environment; small output-wording differences between versions are normal.

## Readiness targets
Not official pass marks, just evidence you're ready: **≥ 85%** on fresh mocks, no domain
consistently below **80%**, and every error-log item re-tested correctly. Day 10 has an honest
readiness rubric. Use it before deciding whether to sit the exam or take the extension days.

---

## What changed in the merge

<details><summary>Where the original 15-day notes went</summary>

| Original | Now |
|---|---|
| Day 1–13 explanations and analogies | "🧠 Mental models" in section B of Days 1–7 |
| Day 1–13 gotchas | "More traps from the original notes" in section I of Days 1–7 |
| Self-test Q1–Q95 | Mastery quizzes (section L) of Days 1–7, regrouped by topic |
| AWS hands-on (Days 1–13) | [labs/aws-optional](labs/aws-optional/README.md) A1–A8, linked from each lesson |
| Day 14 practice exam (50 Q) | [Mock Exam 4](practice-exams/mock-exam-04.md) |
| Day 15 practice exam (46 Q) | [Mock Exam 5](practice-exams/mock-exam-05.md) |
| Master cheat sheet | [QUICK_REVISION.md](QUICK_REVISION.md) section 0 and the existing sections |
| Exam snapshot / blueprint | [EXAM_OBJECTIVES.md](EXAM_OBJECTIVES.md) section 1 |
| Exam-day checklist | Day 10 lesson + EXAM_OBJECTIVES |
| `terraform_004_tracker.html` | [tracker.html](tracker.html), rebuilt for this plan |
</details>

<details><summary>Errors corrected in the original notes (worth knowing: each one is a likely exam question)</summary>

1. **`~>` constraints.** The notes said `~> 1.4` allows only 1.4.x and `~> 2.3` blocks 2.4.0.
   Wrong: `~> 1.4` = `>= 1.4, < 2.0`; `~> 2.3` = `>= 2.3, < 3.0`. Only the three-part form
   (`~> 2.3.0`) stops at the patch level. Practice Exam 1 Q3 had the wrong answer key.
2. **Providers in modules.** The notes said child modules never inherit provider configuration.
   Default (un-aliased) providers **are** inherited automatically; only aliased ones must be
   passed with `providers = { ... }`.
3. **Local backend locking.** The notes said "no locking at all". It locks on its own machine
   (OS file lock); it just can't protect a team.
4. **Plan exit code 2** only exists with `-detailed-exitcode`. A plain successful plan exits 0.
5. **Data sources in plans.** The notes said they always appear as `<=`. Usually they are read
   during plan and show no action; `<=` appears only when the read is deferred to apply.
6. **S3 native locking.** The notes said bucket versioning is *required*; it's strongly
   recommended (for recovery), and Terraform 1.10+ is required.
7. **Practice exam answer pattern.** In the original Practice Exam 1, the correct answer was B
   for almost every question. Options are now shuffled (A–D evenly spread), and four filler
   questions (e.g. "what language is Terraform written in?") were replaced with real exam topics
   (`moved`, `removed`, saved plans, aliased providers in modules).
8. Sentinel's **soft-mandatory** level (missing from the notes) was added; `variable` blocks also
   accept `ephemeral` (1.10+).
</details>
