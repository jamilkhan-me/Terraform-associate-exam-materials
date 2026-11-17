# Error Log

Record every mistake from quizzes, labs and mocks here, including lucky guesses. Re-test open
items at the start of each session until you answer them correctly.

Classification: **K** knowledge gap · **C** confused similar concepts · **M** misread question · **G** guess

## Template
```
### E-NNN · <date> · <assessment & question>
- Question/task:
- Your answer:            (confidence: 1/2/3)
- Correct answer:
- Why yours was wrong:
- Underlying concept:
- Rule / memory aid:
- Classification: K / C / M / G
- Verification question:  (answer hidden below)
- Status: open | re-tested ✓ (date)
```

## Entries
_None yet — the diagnostic test will populate this log._

### Known traps from the original notes (pre-loaded; these were wrong in the 15-day notes)
- `~> 2.3` allows 2.4.0 (it's `>= 2.3, < 3.0`). Only `~> 2.3.0` stops at 2.3.x.
- Child modules **do** inherit default (un-aliased) providers; only aliased ones need `providers = {}`.
- The local backend **does** lock, but only on its own machine.
- Plan exit code 2 ("changes present") only happens with `-detailed-exitcode`.
