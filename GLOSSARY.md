# Glossary

Terms you should be able to define in one sentence. Lesson references in brackets.

| Term | Definition |
|---|---|
| **Address (resource address)** | String identifying a resource instance in config/state, e.g. `module.net.aws_subnet.private["a"]` [D4, D5] |
| **Agent (HCP Terraform)** | Self-hosted process that executes HCP Terraform runs inside a private network [D7] |
| **Alias (provider)** | Name for an additional configuration of the same provider; referenced as `aws.alias` [D4] |
| **Apply** | Executes a plan: makes API calls and writes the results to state [D3] |
| **Argument** | A `name = value` assignment inside a block that you set [D2] |
| **Attribute** | A value a resource/data source exposes for reference; some are known only after apply [D2] |
| **Backend** | Where state is stored and how operations lock it (local, s3, azurerm, gcs, …) [D5] |
| **Block** | HCL container with a type, optional labels, and a body [D2] |
| **Check block** | Top-level assertion block that reports **warnings** on failure (1.5+) [D4] |
| **`cloud` block** | `terraform { cloud { … } }` — connects a configuration to HCP Terraform/TFE (1.1+) [D7] |
| **Configuration** | The set of `.tf` files in a directory (the root module plus called modules) [D1] |
| **Configuration aliases** | `configuration_aliases` in a module's `required_providers`, declaring aliased provider configs it expects [D6] |
| **Cost estimation** | HCP Terraform stage estimating monthly cost changes after plan [D7] |
| **`count`** | Meta-argument creating N indexed instances [D4] |
| **`create_before_destroy`** | Lifecycle option to create a replacement before destroying the old object [D4] |
| **Data source** | `data` block that reads information; never creates/updates/destroys [D1, D4] |
| **Declarative** | Describing the desired end state rather than steps [D1] |
| **Dependency graph** | DAG of resources built from references and `depends_on`; drives ordering and parallelism [D2] |
| **`depends_on`** | Meta-argument declaring hidden dependencies on whole objects [D2] |
| **Drift** | Real infrastructure differing from what config/state describe [D4, D5] |
| **Dynamic block** | Generates repeated nested blocks from a collection [D2] |
| **Dynamic provider credentials** | HCP Terraform feature issuing short-lived cloud credentials via OIDC per run [D7] |
| **Ephemeral (values/resources)** | 1.10+ values not persisted in state or plan files [D2, D7] |
| **Execution mode** | Where HCP Terraform runs execute: remote, local, or agent [D7] |
| **`for_each`** | Meta-argument creating one instance per map key / set element [D4] |
| **ForceNew** | Provider-schema property: changing the attribute forces replacement [D4] |
| **HCL** | HashiCorp Configuration Language [D2] |
| **HCP Terraform** | HashiCorp's SaaS platform for Terraform (formerly Terraform Cloud) [D7] |
| **Idempotent** | Re-running produces no further changes [D1] |
| **Implicit dependency** | Dependency inferred from a reference [D2] |
| **Import** | Bringing an existing object under Terraform management (block or CLI) [D5] |
| **Input variable** | Module parameter declared with `variable` [D2] |
| **Lifecycle** | Meta-argument block customising create/replace/destroy behaviour and conditions [D4] |
| **Lineage** | Unique ID of a state's history [D5] |
| **Local value** | Named expression in `locals`, referenced as `local.x` [D2] |
| **Lock file** | `.terraform.lock.hcl` — selected provider versions + hashes [D4] |
| **Locking (state)** | Mechanism preventing concurrent state writes [D5] |
| **Meta-argument** | Argument handled by Terraform itself: `count`, `for_each`, `provider(s)`, `depends_on`, `lifecycle` [D4] |
| **Module** | A directory of `.tf` files; root or child [D6] |
| **`moved` block** | Declarative address change recorded in config (1.1+) [D5] |
| **OPA** | Open Policy Agent — alternative policy-as-code engine supported by HCP Terraform [D7] |
| **Output value** | Value exported by a module (`output` block) [D2] |
| **Partial backend configuration** | Supplying backend settings at `init` with `-backend-config` [D5] |
| **Plan** | Proposed set of actions computed from config vs (refreshed) state [D3] |
| **Policy set** | Group of Sentinel/OPA policies applied to workspaces/projects [D7] |
| **Postcondition / precondition** | Custom conditions in `lifecycle` (and preconditions in outputs) that **error** on failure [D4] |
| **`prevent_destroy`** | Lifecycle option making plans that destroy the resource fail [D4] |
| **Project (HCP Terraform)** | Group of workspaces for organisation and access control [D7] |
| **Provider** | Plugin that exposes resource types/data sources for an API [D1, D4] |
| **Provisioner** | Script run on create/destroy (local-exec, remote-exec, file) — last resort [D4] |
| **Refresh** | Reading real object state through providers to update Terraform's view [D3, D5] |
| **Registry** | Terraform Registry (public) or private registry for providers and modules [D4, D6] |
| **`removed` block** | Declarative "stop managing", optionally without destroying (1.7+) [D5] |
| **`replace_triggered_by`** | Lifecycle option forcing replacement when referenced objects change [D4] |
| **Root module** | The working directory's configuration [D6] |
| **Run (HCP Terraform)** | One execution of plan (and possibly apply) in a workspace [D7] |
| **Run task** | Integration calling an external service at run stages [D7] |
| **Run trigger** | Successful apply in one workspace queues a run in another [D7] |
| **Sensitive** | Marking that redacts values in output; values still stored in state [D2] |
| **Sentinel** | HashiCorp policy-as-code language; levels advisory/soft-mandatory/hard-mandatory [D7] |
| **Serial** | State write counter [D5] |
| **Speculative plan** | Plan-only run that cannot be applied [D7] |
| **Splat** | `[*]` expression collecting an attribute across a list [D2] |
| **State** | Terraform's record mapping configuration to real objects [D1, D5] |
| **Taint** | Mark forcing replacement; set by failed provisioners; `taint` command deprecated for `-replace` [D3, D4] |
| **`terraform_data`** | Built-in managed resource storing values/triggering replacement (1.4+) [Labs] |
| **`terraform_remote_state`** | Built-in data source reading another state's root outputs [D5] |
| **Terraform Enterprise** | Self-hosted HCP Terraform [D7] |
| **Variable set** | HCP Terraform group of variables shared across workspaces/projects [D7] |
| **VCS-driven workflow** | HCP Terraform workflow triggered by repository events [D7] |
| **Workspace (CLI)** | Named alternate state for the same configuration [D6] |
| **Workspace (HCP Terraform)** | Unit with its own config source, state, variables, permissions, and runs [D7] |
| **Write-only argument** | Provider argument (1.11+) accepted during apply but never stored in state [D7] |
