# Weak Topics — Live Deck

Populated from the diagnostic, quizzes, mocks, and the error log. A topic leaves this list
after **3 correct recalls on separate days**.

| Topic | Source of evidence | Date added | Recall 1 | Recall 2 | Recall 3 | Status |
|---|---|---|---|---|---|---|
| _(awaiting diagnostic results)_ | | | | | | |

## Pre-seeded "high-risk" topics
These are areas where candidates with hands-on AWS experience commonly have gaps. They are
**not** your confirmed weaknesses yet — the diagnostic will tell us.

| High-risk topic | Why it's risky | Lesson |
|---|---|---|
| Variable precedence order | Counter-intuitive (env vars are weak) | Day 2 C2 |
| `count` index shift vs `for_each` | Works fine until a list changes | Day 4 C5 |
| `state rm` vs `destroy` vs `removed` | Similar names, opposite consequences | Day 5 C6–C7 |
| `-migrate-state` vs `-reconfigure` | One copies, one doesn't | Day 3 C1, Day 5 C11 |
| `sensitive` vs `ephemeral` | Sensitive is display-only | Day 2 C2, Day 7 C8 |
| Lock file scope | Providers only; not modules | Day 4 C2 |
| CLI vs HCP Terraform workspaces | Same word, different concept | Day 6 C10 |
| Sentinel enforcement levels | Soft vs hard override rules | Day 7 C7 |
| `check` vs pre/postconditions | Warning vs error | Day 4 C7 |
| `version` argument scope for modules | Registry only | Day 6 C3 |
