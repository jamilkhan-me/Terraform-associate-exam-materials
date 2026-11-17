# Exam Objectives — Target Version and Coverage Map

> **Read this first.** This file states which exam the material targets, what is known,
> and where uncertainty remains. It merges the exam snapshots from both original resources.
> When the merge was done (Nov 2026), HashiCorp's site could not be reached from the
> authoring environment, so **check format details against your booking confirmation**.

---

## 1. Exam snapshot

| Item | Value | Source / confidence |
|---|---|---|
| Exam | **HashiCorp Certified: Terraform Associate (004)** | ✅ Confirmed by your booking (2026-10-25) |
| Previous version | 003, retired when 004 launched (around January 2026) | Medium |
| Terraform version the exam targets | **1.12** | Both resources agree; the 15-day notes say verified on HashiCorp's page (Aug 2026) |
| Objective list (8 domains, 34 sub-objectives, 1a–8d) | Section 2 below | **High**: identical in both resources, and the 15-day notes checked it against HashiCorp's exam content list (Aug 2026) |
| Duration | **60 minutes** | High (both agree) |
| Number of questions | Roughly **57–60** | Medium (the resources say ~57 and ~60) |
| Question formats | Multiple choice, multiple select, true/false | Medium–High. No hands-on/terminal tasks |
| Delivery | Online, remotely proctored (webcam, microphone, photo ID) | High |
| Price | **$70.50 USD + tax** | Medium (from the 15-day notes) — check your booking |
| Credential validity | **2 years** | Medium–High |
| Passing score | Commonly quoted as ~70%. Treat as unconfirmed | Low: aim for ≥ 85% on mocks instead |
| Prerequisites | None formal | High |

The material targets 004 only; 003 differences in section 4 are kept for context.

### Remaining uncertainties
1. **Exact objective wording.** Topics and numbering in section 2 agree across both original
   resources; minor wording differences from HashiCorp's page are possible.
2. **Question count / passing score.** HashiCorp does not publish a fixed passing
   percentage. Never trust any "you need X%" claim — including from me.
3. **Question formats.** Older versions reportedly included occasional fill-in-the-blank
   (type a command). I am not certain whether 004 does. Our mocks include a few
   "type the command" items as cheap insurance.
4. **Newest language features** (ephemeral values, write-only arguments, `import` with
   `for_each`, `removed` blocks, `terraform test`). These exist in Terraform 1.5–1.12.
   How deeply 004 tests them is uncertain; the course covers them at *recognition* depth
   unless they map clearly to an objective.
5. **HCP Terraform tiers/pricing.** Feature-to-tier mapping changes frequently. The course
   teaches *what features do*, and avoids claims about *which paid tier* includes them.

---

## 2. Objective map (004)

Legend for "Where taught": `D#` = daily lesson, `L##` = lab.

### Domain 1 — Infrastructure as Code (IaC) with Terraform
| # | Objective | Where taught |
|---|---|---|
| 1a | Explain what IaC is | D1 |
| 1b | Describe the advantages of IaC patterns | D1 |
| 1c | Explain how Terraform manages multi-cloud, hybrid cloud, and service-agnostic workflows | D1, D4 |

### Domain 2 — Terraform fundamentals
| # | Objective | Where taught |
|---|---|---|
| 2a | Install and version Terraform providers | D1, D4, L04 |
| 2b | Describe how Terraform uses providers (plugin architecture) | D1, D4 |
| 2c | Write Terraform configuration using multiple providers (incl. aliases) | D4 |
| 2d | Explain how Terraform uses and manages state | D1, D5 |

### Domain 3 — Core Terraform workflow
| # | Objective | Where taught |
|---|---|---|
| 3a | Describe the Terraform workflow (Write → Plan → Apply) | D1, D3 |
| 3b | Initialize a working directory (`terraform init`) | D3, L01 |
| 3c | Validate a configuration (`terraform validate`) | D3, L01 |
| 3d | Generate and review an execution plan (`terraform plan`) | D3, L07 |
| 3e | Apply changes (`terraform apply`) | D3 |
| 3f | Destroy infrastructure (`terraform destroy`) | D3 |
| 3g | Apply formatting and style (`terraform fmt`) | D3, L01 |

### Domain 4 — Terraform configuration
| # | Objective | Where taught |
|---|---|---|
| 4a | Use and differentiate `resource` and `data` blocks | D1, D4, L03 |
| 4b | Refer to resource attributes and create cross-resource references | D2, L02 |
| 4c | Use variables and outputs | D2, L02 |
| 4d | Understand and use complex types | D2, L02, L05 |
| 4e | Write dynamic configuration using expressions and functions | D2, L05 |
| 4f | Define resource dependencies (implicit/explicit) | D2, D4, L04 |
| 4g | Validate configuration using custom conditions (validation, pre/postconditions, `check`) | D2, D4, L04 |
| 4h | Best practices for sensitive data, incl. secrets management with Vault | D7 |

### Domain 5 — Terraform modules
| # | Objective | Where taught |
|---|---|---|
| 5a | Explain how Terraform sources modules | D6 |
| 5b | Describe variable scope within modules | D6, L06 |
| 5c | Use modules in configuration | D6, L06 |
| 5d | Manage module versions | D6 |

### Domain 6 — Terraform state management
| # | Objective | Where taught |
|---|---|---|
| 6a | Describe the local backend | D5, L10 |
| 6b | Describe state locking | D5 |
| 6c | Configure remote state using the `backend` block | D5, L10 |
| 6d | Manage resource drift and Terraform state | D5, D8, L08 |

### Domain 7 — Maintain infrastructure with Terraform
| # | Objective | Where taught |
|---|---|---|
| 7a | Import existing infrastructure | D5, L09 |
| 7b | Use the CLI to inspect state | D5, L08 |
| 7c | Describe when and how to use verbose logging (`TF_LOG`) | D3, D8 |

### Domain 8 — HCP Terraform
| # | Objective | Where taught |
|---|---|---|
| 8a | Use HCP Terraform to create infrastructure | D7 |
| 8b | HCP Terraform collaboration and governance features | D7 |
| 8c | Organize and use HCP Terraform workspaces and projects | D7 |
| 8d | Configure and use HCP Terraform integration (`cloud` block, `terraform login`) | D7 |

---

## 3. Topics the course covers beyond the strict list (and why)

| Topic | Why it is covered |
|---|---|
| CLI workspaces (`terraform workspace`) | Frequently confused with HCP Terraform workspaces; 003 objective; plausible distractor material |
| `count` vs `for_each` | Underpins 4e/4f and resource addressing in state commands |
| `moved` / `removed` blocks, `state mv/rm` | Core of 6d / 7b scenarios |
| Provisioners | 003 objective; still a common "which is a last resort" question |
| `.terraform.lock.hcl` | Part of 2a (provider versioning) |
| Ephemeral values / write-only args | Part of modern sensitive-data story (4h); recognition depth |

---

## 4. 003 → 004 differences (as I understand them)

| 003 domain | Where it went in 004 |
|---|---|
| 1 Understand IaC concepts | Domain 1 |
| 2 Purpose of Terraform (vs other IaC) | Domain 1 |
| 3 Terraform basics (providers, provisioners) | Domain 2 (provisioners de-emphasised) |
| 4 Use Terraform outside the core workflow (import, state, logging) | Domain 7 |
| 5 Interact with Terraform modules | Domain 5 |
| 6 Use the core Terraform workflow | Domain 3 |
| 7 Implement and maintain state | Domain 6 |
| 8 Read, generate, and modify configuration | Domain 4 (adds custom conditions, Vault) |
| 9 Understand Terraform Cloud capabilities | Domain 8 (renamed HCP Terraform; projects added) |

---

## 5. Domain weighting used for mock exams (approximation, not official)

HashiCorp does not publish per-domain weights to my knowledge. Mocks use this
distribution, reflecting how much testable surface area each domain has:

| Domain | Share of a 57-question mock |
|---|---|
| 1 IaC | ~4 |
| 2 Fundamentals / providers / state concept | ~7 |
| 3 Core workflow / CLI | ~10 |
| 4 Configuration (HCL) | ~14 |
| 5 Modules | ~6 |
| 6 State management | ~7 |
| 7 Maintain (import/inspect/logging) | ~4 |
| 8 HCP Terraform | ~5 |
