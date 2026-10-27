# Lab 12 — Troubleshooting Broken Configurations

## 1. Objective
Diagnose and fix intentionally broken configurations quickly: identify the **phase** that
reports each error (init / validate / plan), read the message, and apply the minimal fix.

## 2. Prerequisites
Terraform ≥ 1.5. Day 8 lesson (error catalogue).

## 3. Directory structure
```
lab-12/starter/
├── broken-01/   syntax (3 errors)
├── broken-02/   references (4 errors)
├── broken-03/   types (3 errors)
├── broken-04/   dependencies (2 errors)
├── broken-05/   modules (4 errors)
└── broken-06/   mixed: backend, meta-args, lifecycle, sensitive (4 errors)
```

## 4. Starter files
Each folder's `main.tf` header states how many errors it contains.

## 5. Tasks
For **each** folder:
1. **Read first, run second.** Spend 2 minutes listing every error you can see by eye. Write the expected error message.
2. Run `terraform init` then `terraform validate` (then `terraform plan` if validate passes). Terraform often reports only some errors at once — fix, re-run, repeat.
3. For each error record: *phase · message (abridged) · root cause · fix*.
4. Stop when `terraform plan` succeeds (broken-02 needs the remote state file to exist — decide how to handle that: e.g. replace the data source with a variable for this exercise, or create the referenced state).

Target times: 5 minutes per folder. Track your score: errors found by eye **before** running.

## 6. Expected observations
- Syntax errors stop everything before validation of semantics.
- Terraform reports errors in batches; some only appear after others are fixed.
- Backend errors appear at `init`; meta-argument conflicts at `validate`.

## 7. Hints
<details><summary>Hint 1 (broken-01)</summary>Look at quotes, braces, and whether <code>lifecycle</code> is a block or an argument.</details>
<details><summary>Hint 2 (broken-02)</summary>Check every prefix: <code>var.</code>, <code>local.</code>, <code>data.</code>, and every attribute name of <code>terraform_data</code>.</details>
<details><summary>Hint 3 (broken-05)</summary>Local module sources must start with <code>./</code> or <code>../</code>; <code>version</code> is registry-only.</details>

## 8. Solution
[SOLUTION.md](SOLUTION.md)

## 9. Common errors
This lab *is* the common errors list — see Day 8, section C2.

## 10. Exam concepts reinforced
HCL syntax (4), references (4b), types (4d), dependencies (4f), modules (5c), backend restrictions (6c), lifecycle literals, sensitive outputs (4h), meta-argument rules.
