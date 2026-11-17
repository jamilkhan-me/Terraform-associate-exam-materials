# Study Plan

One path: **10 core days** plus **2 extension days** (Mocks 4 and 5) if your readiness check on
Day 10 says "borderline", or if you have time before the exam. Sit the exam on or just after
the last day you use. Daily load: **3.5–5 hours** (adjust, but don't skip assessments).
Short on daily hours? See the [relaxed 15-day pacing](#relaxed-pacing-15-days) at the bottom.

Each day follows [DAILY_CHECKLIST.md](DAILY_CHECKLIST.md): recall test → lesson → lab →
quiz → marking → tracker update. A day is only "complete" once its mastery assessment
(section L of the lesson) is passed, or the weak part has been re-studied.

---

## Overview

| Day | Theme | Objectives | Labs | Assessment |
|---|---|---|---|---|
| 1 | Diagnostic + Terraform fundamentals | 1a–1c, 2a–2b, 2d, 3a, 4a | L01 | Diagnostic (30 Q) + Day 1 quiz |
| 2 | HCL, variables, expressions, dependencies | 4b–4g | L02, L05 (part) | Day 2 quiz + predict-the-output |
| 3 | CLI and core workflow | 3a–3g, 7c | L01 revisit, L07 (part) | CLI command-selection drill |
| 4 | Providers, resources, data sources, lifecycle | 2a–2c, 4a, 4f, 4g | L03, L04, L05 | Behaviour-prediction quiz |
| 5 | **State** (high priority) | 2d, 6a–6d, 7a–7b | L08, L09, L10 | State scenario quiz |
| 6 | Modules + workspaces | 5a–5d, (CLI workspaces) | L06, L11 | Module/workspace quiz |
| 7 | HCP Terraform, security, sensitive data | 4h, 8a–8d | — (conceptual) | Day 7 quiz + **Mock Exam 1** (40 Q, 45 min) |
| 8 | Troubleshooting + mixed scenarios | All, esp. 6d, 7c | L07, L12 | Error-diagnosis gauntlet |
| 9 | Full mock + remediation | All | Targeted re-labs | **Mock Exam 2** (57 Q, 60 min) |
| 10 | Final assessment + readiness | All | — | **Mock Exam 3** (57 Q, 60 min) + rapid-fire |
| 11 *(ext.)* | Second fresh check | All, weak domains | Matching AWS lab (optional) | **Mock Exam 4** (50 Q, 50 min) |
| 12 *(ext.)* | Final check + rest | All | — | **Mock Exam 5** (46 Q, 46 min) + QUICK_REVISION |

---

## Day-by-day detail

### Day 1 — Diagnostic and fundamentals (≈4 h)
| Block | Time | Activity |
|---|---|---|
| 1 | 35 min | **Diagnostic test** (30 Q, closed book, record confidence 1–3 per question) |
| 2 | 30 min | Marking + explanation of every miss |
| 3 | 75 min | [day-01.md](daily-lessons/day-01.md): IaC, declarative model, architecture, providers/resources/data sources, config vs state vs reality |
| 4 | 45 min | [Lab 01](labs/lab-01/README.md): first configuration, full workflow |
| 5 | 20 min | Day 1 mastery quiz; tracker update |

### Day 2 — HCL, variables, expressions, dependencies (≈4.5 h)
| Block | Time | Activity |
|---|---|---|
| 1 | 15 min | Recall test on Day 1 |
| 2 | 100 min | [day-02.md](daily-lessons/day-02.md): blocks/arguments/attributes, variables & precedence, types, locals, outputs, expressions, functions, `for`, `dynamic`, conditions, dependency graph |
| 3 | 60 min | [Lab 02](labs/lab-02/README.md): variables, locals, outputs, validation, precedence |
| 4 | 30 min | Predict-the-output drill |
| 5 | 20 min | Mastery quiz; tracker update |

### Day 3 — CLI and core workflow (≈4 h)
| Block | Time | Activity |
|---|---|---|
| 1 | 15 min | Recall test on Days 1–2 |
| 2 | 90 min | [day-03.md](daily-lessons/day-03.md): every command, flags, side effects, refresh-only, `-replace`, `TF_LOG` |
| 3 | 45 min | Re-run Lab 01 with flags (`-out`, `-refresh-only`, `-destroy`, `fmt -check`), start [Lab 07](labs/lab-07/README.md) |
| 4 | 30 min | Command-selection drill (30 scenarios) |
| 5 | 20 min | Mastery quiz |

### Day 4 — Providers, resources, data sources, lifecycle (≈4.5 h)
| Block | Time | Activity |
|---|---|---|
| 1 | 15 min | Recall test |
| 2 | 90 min | [day-04.md](daily-lessons/day-04.md): `required_providers`, constraints, lock file, aliases, `count` vs `for_each`, lifecycle, provisioners, custom conditions, drift, replace vs update |
| 3 | 90 min | [Lab 03](labs/lab-03/README.md), [Lab 04](labs/lab-04/README.md), [Lab 05](labs/lab-05/README.md) |
| 4 | 20 min | Mastery quiz |

### Day 5 — State (≈5 h, highest priority)
| Block | Time | Activity |
|---|---|---|
| 1 | 15 min | Recall test |
| 2 | 100 min | [day-05.md](daily-lessons/day-05.md): purpose of state, structure, backends, locking, security, every `state` subcommand, `moved`/`removed`, import, drift, migration |
| 3 | 120 min | [Lab 08](labs/lab-08/README.md), [Lab 09](labs/lab-09/README.md), [Lab 10](labs/lab-10/README.md) |
| 4 | 25 min | State scenario quiz (lost state, rename, rm vs destroy, concurrency) |

### Day 6 — Modules and workspaces (≈4 h)
| Block | Time | Activity |
|---|---|---|
| 1 | 15 min | Recall test (heavy on state) |
| 2 | 80 min | [day-06.md](daily-lessons/day-06.md) |
| 3 | 90 min | [Lab 06](labs/lab-06/README.md), [Lab 11](labs/lab-11/README.md) |
| 4 | 20 min | Mastery quiz |

### Day 7 — HCP Terraform, security, sensitive data (≈4.5 h)
| Block | Time | Activity |
|---|---|---|
| 1 | 15 min | Recall test |
| 2 | 90 min | [day-07.md](daily-lessons/day-07.md) |
| 3 | 20 min | Day 7 quiz |
| 4 | 45 min | **[Mock Exam 1](practice-exams/mock-exam-01.md)** — 40 Q, 45 min, closed book |
| 5 | 40 min | Marking, error log, weak-topic update |

### Day 8 — Troubleshooting and mixed scenarios (≈4 h)
| Block | Time | Activity |
|---|---|---|
| 1 | 20 min | Re-test every error-log item so far |
| 2 | 60 min | [day-08.md](daily-lessons/day-08.md): error catalogue, plan reading, safest-action reasoning |
| 3 | 90 min | [Lab 12](labs/lab-12/README.md) (broken configs), finish [Lab 07](labs/lab-07/README.md) |
| 4 | 30 min | Mixed-scenario gauntlet |

### Day 9 — Full mock and remediation (≈4 h)
| Block | Time | Activity |
|---|---|---|
| 1 | 60 min | **[Mock Exam 2](practice-exams/mock-exam-02.md)** — 57 Q, 60 min, exam conditions |
| 2 | 60 min | Marking: classify each miss (knowledge gap / confusion / misread / guess) |
| 3 | 90 min | [day-09.md](daily-lessons/day-09.md) remediation blocks for the weakest 5 topics |
| 4 | 30 min | Flashcards: weak-topics deck |

### Day 10 — Final assessment (≈4 h)
| Block | Time | Activity |
|---|---|---|
| 1 | 60 min | **[Mock Exam 3](practice-exams/mock-exam-03.md)** — 57 Q, 60 min |
| 2 | 45 min | Marking; compare Diagnostic → Mock 2 → Mock 3 |
| 3 | 30 min | Rapid-fire CLI/HCL quiz + misconceptions test ([day-10.md](daily-lessons/day-10.md)) |
| 4 | 30 min | [QUICK_REVISION.md](QUICK_REVISION.md) |
| 5 | 15 min | Honest readiness assessment |

---

## Adaptation rules
- Diagnostic domain < 50% → that day's lesson gets +30 min and the extra lab.
- Any end-of-day quiz < 80% → re-teach weak concept next morning before new material.
- Same mistake twice → it moves to `flashcards/weak-topics.md` and appears in every
  subsequent recall test until answered correctly three times.
- Mock 2 < 75% → Day 10 becomes remediation + a shorter final check; consider whether
  the exam date is realistic (honest conversation, not false confidence).
- Day 10 readiness rubric shows **borderline** anywhere → use the extension days: Day 11 remediate
  the weak domains first, then sit Mock 4; Day 12 sit Mock 5 and stop studying by the evening.

---

### Day 11 — Extension: Mock 4 and remediation (≈3.5 h, optional)
| Block | Time | Activity |
|---|---|---|
| 1 | 90 min | Re-study the 2–3 weakest domains from Mock 3: lesson sections C, H, I + the matching remediation block in [day-09.md](daily-lessons/day-09.md) |
| 2 | 50 min | **[Mock Exam 4](practice-exams/mock-exam-04.md)** — 50 Q, 50 min, closed book |
| 3 | 40 min | Mark, log misses, update weak topics |
| 4 | 30 min | Optional: one [AWS lab](labs/aws-optional/README.md) for your weakest hands-on topic |

### Day 12 — Extension: Mock 5 and wind-down (≈2.5 h, optional)
| Block | Time | Activity |
|---|---|---|
| 1 | 46 min | **[Mock Exam 5](practice-exams/mock-exam-05.md)** — 46 Q, 46 min |
| 2 | 40 min | Mark; re-read explanations for every miss *and* every lucky guess |
| 3 | 30 min | [QUICK_REVISION.md](QUICK_REVISION.md) + [weak-topics](flashcards/weak-topics.md). No new material after this. |

---

## Relaxed pacing (15 days)

The original 15-day notes spread the material at ~2 hours a day. If that suits you better, follow
the same lessons in this order. Every assessment stays the same.

| Day | Do |
|---|---|
| 1 | Diagnostic test + Day 1 lesson (C1–C3, IaC) |
| 2 | Day 1 lesson (C4–C8) + Lab 01 + Day 1 quiz |
| 3 | Day 2 lesson (C1–C5: HCL, variables, types, outputs) + Lab 02 |
| 4 | Day 2 lesson (C6–C8: expressions, functions, dependencies) + Day 2 quiz |
| 5 | Day 3 lesson + Lab 07 + Day 3 quiz |
| 6 | Day 4 lesson (C1–C5) + Labs 03, 05 |
| 7 | Day 4 lesson (C6–C10) + Lab 04 + Day 4 quiz |
| 8 | Day 5 lesson (C1–C6) + Lab 08 |
| 9 | Day 5 lesson (C7–C12) + Labs 09, 10 + Day 5 quiz |
| 10 | Day 6 lesson + Labs 06, 11 + Day 6 quiz |
| 11 | Day 7 lesson + Day 7 quiz |
| 12 | Mock Exam 1 + Day 8 lesson + Lab 12 |
| 13 | Mock Exam 2 + Day 9 remediation |
| 14 | Mock Exam 3 + Day 10 rapid-fire and misconception test |
| 15 | Mock Exam 4 (Mock 5 the morning before the exam, if you like) + QUICK_REVISION |

