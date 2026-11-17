# Day 2 — HCL, Variables, Expressions, and Dependencies

**Objectives covered:** 4b, 4c, 4d, 4e, 4f, 4g (variable validation; rest on Day 4)
**Labs:** [Lab 02](../labs/lab-02/README.md), first half of [Lab 05](../labs/lab-05/README.md)

---

## A. Learning objectives

1. Name the parts of HCL: blocks, labels, arguments, attributes, expressions, identifiers.
2. Declare variables with `type`, `default`, `description`, `validation`, `sensitive`, `nullable`, `ephemeral`.
3. State the **full variable precedence order** from memory.
4. Use locals and outputs correctly, including sensitive outputs.
5. Use primitive and complex types: `list`, `set`, `map`, `object`, `tuple`, `optional()`.
6. Write and evaluate: string templates, conditionals, `for` expressions, splats, `dynamic` blocks.
7. Use common built-in functions and predict their output.
8. Explain implicit vs explicit dependencies and how Terraform orders operations.

---

## B. Plain-English explanation

HCL (HashiCorp Configuration Language) is a *configuration* language, not a programming
language: no loops with side effects, no user-defined functions (providers may supply
functions from 1.8), no mutable variables. You describe values and how they relate.

- **Variables** = function parameters of a module (inputs).
- **Locals** = named intermediate values inside a module (like `const` in a function).
- **Outputs** = return values of a module.
- **Expressions** compute values: references, operators, conditionals, `for`, functions.
- **Dependencies** are inferred from references: if B mentions A, A goes first.


### 🧠 Mental models (from the original 15-day notes)

- **A module is a function.** Variables are its parameters, outputs are its return values,
  locals are its private intermediate values.
- **Variable precedence = "who spoke last and loudest".** A `default` written weeks ago is a
  note on a whiteboard; a `-var` typed as you press Enter is someone standing next to you
  saying "use this instead". The more immediate and explicit the source, the more it wins.
- **List vs set = deli queue vs guest list.** A deli queue has an order and two people can hold
  the same number (list). A guest list has no "first" and being listed twice means nothing
  (set).
- **Implicit dependencies = a recipe.** "Add the beaten eggs" implies the eggs were beaten
  first; nobody writes "step 0: beat the eggs". `depends_on` is for the rare hidden
  prerequisite, like the oven needing to be preheated, that no ingredient mentions.
- **`terraform console` = a calculator next to your code.** Before trusting a `merge()` or a
  `for` expression in a resource, type it into the console and look at the result.

---

## C. Technical deep dive

### C1. Anatomy of HCL

```hcl
resource "aws_instance" "web" {       # block type "resource", two labels
  ami           = "ami-123"           # argument: name = expression
  instance_type = var.instance_type   # expression: reference to a variable

  root_block_device {                  # nested block (no "=")
    volume_size = 20
  }

  tags = {                             # argument whose value is a map (has "=")
    Name = "web"
  }
}
# aws_instance.web.public_ip          # attribute: value exported by the resource
```

| Term | Meaning |
|---|---|
| Block | Container: `type "label" "label" { ... }` |
| Argument | Assignment *inside* a block that you set: `name = value` |
| Attribute | Value exposed by a resource/data source for others to read (some only known after apply) |
| Nested block | Block inside a block, no `=` (e.g. `ingress {}`); may repeat |
| Identifier | Names: letters, digits, `_`, `-`; can't start with a digit |
| Comments | `#` and `//` single-line, `/* */` multi-line |

Map argument vs nested block: `tags = { ... }` (argument; one map) vs `ingress { ... }`
(block; can repeat). Using the wrong form gives "Unsupported block type" or "An argument
named X is not expected here — did you mean to define a block?".

### C2. Variables

```hcl
variable "instance_type" {
  description = "EC2 size"
  type        = string
  default     = "t3.micro"
  nullable    = false              # null not allowed; default used instead (default is true)
  sensitive   = false

  validation {
    condition     = can(regex("^t3\\.", var.instance_type))
    error_message = "Only t3 family is allowed."
  }
}
```

- No `default` → **required**; Terraform prompts interactively (or errors with `-input=false`).
- `type` constrains and **converts** where possible: `"5"` passed to `number` becomes `5`.
- `validation` runs at plan; `condition` must be true or plan fails with `error_message`.
  Since 1.9 conditions may reference other variables/objects; before that, only the
  variable itself (version-dependent detail).
- `sensitive = true` → redacted in CLI output; **still stored in plain text in state/plan**.
- `ephemeral = true` (1.10+) → value is not stored in state or plan files; can only be used
  in ephemeral contexts (e.g. provider config, write-only args, ephemeral resources).
  Recognition-level for the exam.

#### Ways to set a variable
| Method | Example |
|---|---|
| Default | `default = "t3.micro"` |
| Environment | `export TF_VAR_instance_type=t3.small` |
| `terraform.tfvars` / `terraform.tfvars.json` | auto-loaded |
| `*.auto.tfvars` / `*.auto.tfvars.json` | auto-loaded, lexical filename order |
| `-var-file=prod.tfvars` | explicit file (any name) |
| `-var='instance_type=t3.large'` | command line |
| Interactive prompt | only for required vars with no value |
| HCP Terraform workspace / variable set | Terraform or env variables stored remotely |

#### Precedence (lowest → highest; later wins)
```
1. default in variable block
2. TF_VAR_name environment variables
3. terraform.tfvars
4. terraform.tfvars.json
5. *.auto.tfvars / *.auto.tfvars.json   (processed in lexical order of filenames)
6. -var and -var-file on the command line, in the order given (last one wins)
```
Mnemonic: **"D-E-T-J-A-C"** — *Default, Env, Tfvars, Json, Auto, CLI*. Env is weak; CLI is king.

Note: a file named `prod.tfvars` is **not** auto-loaded. Only `terraform.tfvars(.json)` and `*.auto.tfvars(.json)` are.

### C3. Types

| Type | Literal | Notes |
|---|---|---|
| `string` | `"abc"` | heredoc `<<EOT ... EOT`, `<<-EOT` strips indentation |
| `number` | `5`, `3.14` | |
| `bool` | `true` | |
| `list(T)` | `["a", "b"]` | ordered, index from 0, duplicates allowed |
| `set(T)` | `toset(["a","b"])` | unordered, unique, **no index access** |
| `map(T)` | `{ a = 1, b = 2 }` | string keys, all values same type |
| `object({...})` | `{ name = "x", size = 2 }` | fixed attribute names, each its own type |
| `tuple([...])` | `["x", 2, true]` | fixed length, each position its own type |
| `any` | | placeholder; Terraform infers a concrete type |
| `null` | `null` | "unset" — argument treated as omitted |

```hcl
variable "servers" {
  type = map(object({
    size     = string
    disk_gb  = optional(number, 20)   # optional attr with default (1.3+)
    public   = optional(bool)         # optional, defaults to null
  }))
}
```

Conversions: `list` ↔ `set` with `toset()`/`tolist()`; sets of strings are what `for_each`
needs. Converting a list to a set **removes duplicates and loses order**.

### C4. Locals

```hcl
locals {
  name_prefix = "${var.project}-${var.env}"
  common_tags = {
    Project = var.project
    Env     = var.env
  }
}
# use: local.name_prefix  (block is "locals", reference is "local.")
```
- Can reference variables, resources, data sources, other locals (no cycles).
- Cannot be set from outside the module. Use them to avoid repetition and name complex expressions.

### C5. Outputs

```hcl
output "db_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.main.endpoint
}

output "db_password" {
  value     = random_password.db.result
  sensitive = true          # REQUIRED if value is derived from a sensitive value
}
```
- Root module outputs print after apply; `terraform output [-json|-raw] [NAME]` reads them from state.
- Child module outputs are how parents read child values: `module.db.db_endpoint`.
- If an output's value is sensitive and you don't mark it `sensitive = true`, Terraform
  errors: *"Output refers to sensitive values"*.
- `terraform output` lists sensitive outputs as `<sensitive>`; `terraform output NAME` or
  `-json` shows the real value — sensitivity is a display guard, not security.
- Outputs can have `precondition` blocks and `depends_on` (rare).

### C6. Expressions

**References**

| Expression | Refers to |
|---|---|
| `var.NAME` | input variable |
| `local.NAME` | local value |
| `TYPE.NAME.ATTR` | managed resource attribute |
| `data.TYPE.NAME.ATTR` | data source attribute |
| `module.NAME.OUTPUT` | child module output |
| `count.index` | current index inside a `count` resource |
| `each.key` / `each.value` | inside `for_each` |
| `self.ATTR` | inside provisioners / connection / postconditions |
| `path.module`, `path.root`, `path.cwd` | filesystem paths |
| `terraform.workspace` | current CLI workspace name |

**Strings**: interpolation `"${var.env}-app"`; directives
`"%{ if var.prod }prod%{ else }dev%{ endif }"` and `%{ for x in list }...%{ endfor }`.

**Operators**: `+ - * / %`, `== != < > <= >=`, `&& || !`.

**Conditional**: `condition ? true_val : false_val` — both results must be compatible types.
```hcl
instance_type = var.env == "prod" ? "m5.large" : "t3.micro"
count         = var.create_bastion ? 1 : 0       # classic "optional resource" idiom
```

**`for` expressions**
```hcl
[for s in var.names : upper(s)]                    # list → list
[for s in var.names : s if s != "bravo"]           # filter
{ for s in var.names : s => length(s) }            # list → map
{ for k, v in var.tags : lower(k) => v }           # map → map
{ for u in var.users : u.team => u.name... }       # "..." groups duplicates into lists
```
`[...]` produces a tuple/list; `{...}` produces an object/map.

**Splat**: `aws_instance.web[*].id` ≡ `[for i in aws_instance.web : i.id]` (works on lists /
`count` resources; for `for_each` (a map) use `values(aws_instance.web)[*].id` or a `for`).

**Dynamic blocks** — generate repeated *nested blocks*:
```hcl
variable "ports" { default = [80, 443] }

resource "aws_security_group" "web" {
  name = "web"
  dynamic "ingress" {                 # name of the nested block to generate
    for_each = var.ports              # collection
    content {                         # body of each generated block
      from_port   = ingress.value     # iterator defaults to the block name
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}
```
- `iterator = port` renames the iterator (`port.value`, `port.key`).
- `dynamic` generates **nested blocks only** — not arguments, not top-level resources,
  not meta-argument blocks such as `lifecycle` or `provisioner`.
- Overuse hurts readability; HashiCorp advises using it sparingly.

### C7. Functions you must recognise

No user-defined functions. Test functions with `terraform console`.

| Category | Functions | Example → result |
|---|---|---|
| String | `upper lower title format join split replace trimspace substr` | `join("-", ["a","b"])` → `"a-b"`; `split(",", "a,b")` → `["a","b"]`; `format("%s-%03d", "web", 7)` → `"web-007"` |
| Collection | `length concat merge flatten distinct keys values lookup contains element zipmap slice toset tolist tomap coalesce one` | `merge({a=1},{a=2,b=3})` → `{a=2,b=3}`; `lookup({a=1}, "z", 0)` → `0`; `element(["a","b"], 3)` → `"b"` (wraps); `flatten([[1],[2,3]])` → `[1,2,3]`; `concat([1],[2])` → `[1,2]`; `coalesce("", "x")` → `"x"` |
| Numeric | `min max abs ceil floor` | `max(3, 7)` → `7`; `max([3,7]...)` → `7` (expansion) |
| Encoding | `jsonencode jsondecode yamlencode base64encode` | IAM policies: `jsonencode({...})` |
| Filesystem | `file templatefile fileexists` | `templatefile("${path.module}/user_data.tftpl", { port = 8080 })` |
| Network | `cidrsubnet cidrhost` | `cidrsubnet("10.0.0.0/16", 8, 2)` → `"10.0.2.0/24"` |
| Type/errors | `can try type` conversions | `try(var.obj.optional_attr, "default")` |
| Hash/crypto | `sha256 md5 uuid bcrypt` | `uuid()` changes every run — causes perpetual diffs! |
| Date | `timestamp formatdate` | `timestamp()` also changes every run |

`can(expr)` → bool "did it evaluate without error?" (used in validations).
`try(a, b, c)` → first one that doesn't error.

### C8. Dependencies

**Implicit**: any reference creates a graph edge.
```hcl
resource "aws_vpc" "main"   { cidr_block = "10.0.0.0/16" }
resource "aws_subnet" "app" { vpc_id = aws_vpc.main.id  cidr_block = "10.0.1.0/24" }
```

**Explicit** with `depends_on` when the dependency is real but invisible in arguments:
```hcl
resource "aws_iam_role_policy" "lambda_logs" { ... }

resource "aws_lambda_function" "api" {
  # function code writes logs on first invocation; policy must exist first,
  # but no argument references it
  depends_on = [aws_iam_role_policy.lambda_logs]
}
```
- `depends_on` takes a list of **references to whole resources/modules** (not attributes,
  not strings): `depends_on = [aws_iam_role_policy.lambda_logs]`.
- Usable on resources, data sources, modules (0.13+), outputs.
- Use sparingly — it makes plans more conservative (e.g. on a data source it can defer the
  read to apply time, causing "known after apply" values downstream).

**Graph behaviour**
- Independent resources are created in parallel (`-parallelism=10` default).
- Destroy happens in **reverse** dependency order.
- A **cycle** (A refs B, B refs A) → `Error: Cycle: ...`.

```
            ┌────────────┐
            │ aws_vpc    │
            └─────┬──────┘
         ┌────────┴─────────┐
   ┌─────▼─────┐      ┌─────▼──────┐
   │ subnet a  │      │ subnet b   │   ← created in parallel
   └─────┬─────┘      └─────┬──────┘
         └────────┬─────────┘
            ┌─────▼──────┐
            │ aws_lb     │   (subnets = [a.id, b.id])
            └────────────┘
 Create order: vpc → {a,b} → lb      Destroy order: lb → {a,b} → vpc
```

---

## D. Why it matters

Your 3-tier project's VPC/subnets/ALB/ECS/RDS chain is a dependency graph; when a destroy
hangs on "DependencyViolation", it's often a hidden dependency Terraform couldn't see (e.g. an
ENI created by a service). The exam tests precedence, types, `for`/splat outputs, and
implicit vs explicit dependencies with code snippets you must mentally evaluate.

---

## E. Syntax reference — quick table

| Want | Write |
|---|---|
| Optional resource | `count = var.enabled ? 1 : 0` then reference `aws_x.y[0]` (or `one(aws_x.y[*].id)`) |
| Map of objects input | `type = map(object({ ... }))` |
| Default for missing key | `lookup(var.m, "k", "default")` |
| Combine tags | `merge(local.common_tags, { Name = "web" })` |
| Read JSON file | `jsondecode(file("${path.module}/cfg.json"))` |
| Policy document | `jsonencode({ Version = "2012-10-17", Statement = [...] })` |
| Force order | `depends_on = [module.network]` |

Easily confused: `local` vs `locals`; `lookup` vs `element`; `concat` (lists) vs `merge`
(maps) vs `join` (→ string); `toset` vs `tolist`; argument vs attribute; `[*]` vs `for`.

---

## F. Worked examples

### F1. Variables + validation + locals + outputs
```hcl
variable "env" {
  type = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.env)
    error_message = "env must be dev, staging, or prod."
  }
}

variable "buckets" {
  type    = list(string)
  default = ["logs", "assets", "logs"]
}

locals {
  unique_buckets = toset(var.buckets)                       # {"assets","logs"}
  bucket_names   = [for b in local.unique_buckets : "${var.env}-${b}"]
}

output "bucket_names" {
  value = local.bucket_names
}
```
`terraform plan -var=env=qa` → fails with "env must be dev, staging, or prod."
`terraform plan -var=env=dev` → output `["dev-assets", "dev-logs"]` (sets iterate in
lexical order for strings; duplicates removed).

### F2. Predict the output (evaluate before reading the answer)
```hcl
locals {
  sizes = { web = "t3.micro", api = "t3.small", db = "m5.large" }
  a = [for k, v in local.sizes : k if startswith(v, "t3")]
  b = { for k, v in local.sizes : upper(k) => v }
  c = length(local.sizes)
  d = keys(local.sizes)
}
```
<details><summary>Answer</summary>

- `a` = `["api", "web"]` (maps iterate in lexical key order: api, db, web; db filtered out)
- `b` = `{ API = "t3.small", DB = "m5.large", WEB = "t3.micro" }`
- `c` = `3`
- `d` = `["api", "db", "web"]` (sorted)
</details>

---

## G. Visual — how a value flows

```
 CLI -var / tfvars / env / default
            │  (precedence resolves ONE value)
            ▼
       var.env ──────────┐
                         ▼
               local.name_prefix ──► resource args ──► provider ──► API
                                                 │
                                    attributes ◄─┘ (known after apply)
                                         │
                                         ▼
                                    output "x" ──► terraform output / module.X.x
```

---

## H. Common misconceptions

| # | Misconception | Reality |
|---|---|---|
| 1 | "Environment variables override tfvars." | `TF_VAR_` is near the **bottom**; tfvars, auto.tfvars and CLI all beat it. |
| 2 | "Any `*.tfvars` file is auto-loaded." | Only `terraform.tfvars(.json)` and `*.auto.tfvars(.json)`. Others need `-var-file`. |
| 3 | "`sensitive` encrypts the value." | It only hides it in CLI output. State holds plaintext. |
| 4 | "Locals can be overridden from the CLI." | Locals are internal; only variables are inputs. |
| 5 | "`depends_on` takes attribute references like `aws_vpc.main.id`." | It takes whole objects: `[aws_vpc.main]`. |
| 6 | "Sets can be indexed `myset[0]`." | Sets are unordered; convert with `tolist()` first. |
| 7 | "`dynamic` can create multiple resources." | It creates repeated **nested blocks**. Multiple resources = `count`/`for_each`. |
| 8 | "File order defines creation order." | The graph does. |
| 9 | "HCL supports user-defined functions." | No (provider-defined functions exist from 1.8, but you can't define functions in HCL). |

---

## I. Exam traps

- A question shows `prod.tfvars` in the directory and asks which value applies with plain
  `terraform plan` → that file is **ignored**.
- `variable` with no default and `-input=false` in CI → error "No value for required variable".
- Output of a `for` with `[]` vs `{}` brackets — check the bracket.
- `element()` wraps around (modulo); indexing `list[5]` on a 3-element list errors.
- `count.index` is only valid inside a resource that has `count`.
- `var.x` used inside its own `validation` — fine. Before 1.9, referencing *another*
  variable there was an error.

**More traps from the original notes**
- **`depends_on` is not a valid argument in a `variable` block.** Valid ones: `type`,
  `default`, `description`, `validation`, `sensitive`, `nullable`, `ephemeral`.
- **Precedence direction gets flipped under pressure:** CLI `-var` is the **highest**,
  `default` is the **lowest**, and `TF_VAR_` env vars are second-lowest.
- **You can't write your own functions in HCL.** Everything comes from the built-in library
  (plus provider-defined functions from 1.8).
- **`count.index` starts at 0.**

---

## J. Active recall

1. Recite variable precedence from lowest to highest.
2. What is the difference between `local` and `locals`?
3. When must an output be marked `sensitive`?
4. What does `[for k, v in var.m : v]` return if `var.m` is a map?
5. Which meta-argument creates an explicit dependency, and what does it accept?
6. What type should `for_each` receive?

<details><summary>Answers</summary>

1. default → TF_VAR env → terraform.tfvars → terraform.tfvars.json → *.auto.tfvars(.json) lexically → -var / -var-file in CLI order.
2. `locals { }` is the block that declares them; `local.name` is how you reference one.
3. When its value derives from a sensitive value (otherwise plan errors).
4. A list (tuple) of the map's values, in lexical key order.
5. `depends_on`, a list of resource/module/data references (whole objects).
6. A map, or a set of strings (lists must be converted with `toset()`). (Day 4 detail.)
</details>

---

## K. Practice exercises

**K1 — Fix the errors**
```hcl
variable "region" {
  type = string
  default = 10
}
locals {
  name = "app-${var.env}"
}
resource "terraform_data" "x" {
  input = locals.name
  depends_on = [terraform_data.y.id]
}
```

**K2 — Predict**: `cidrsubnet("10.0.0.0/16", 4, 3)`.

**K3 — Scenario**: CI runs `terraform plan -var-file=prod.tfvars`. There is also
`terraform.tfvars` with `instance_count = 2` and `prod.tfvars` with `instance_count = 6`, and
`override.auto.tfvars` with `instance_count = 4`. Which value is used?

**K4 — Write**: a variable `users` of type map of objects with `role` (string, required) and
`mfa` (bool, optional, default true).

<details><summary>Answers</summary>

**K1.**
- `default = 10` for `type = string` actually **converts** to `"10"` — valid, but suspicious
  for a region (not an error). Good catch if you flagged it as a logic issue.
- `var.env` is undeclared → "Reference to undeclared input variable".
- `locals.name` → must be `local.name`.
- `depends_on = [terraform_data.y.id]` → must reference the whole resource, and `y` must exist.

**K2.** /16 + 4 bits = /20; the 4th /20 (index 3): each /20 spans 16 in the third octet →
`10.0.48.0/20`.

**K3.** `6`. CLI `-var-file` beats `*.auto.tfvars` (4) and `terraform.tfvars` (2).

**K4.**
```hcl
variable "users" {
  type = map(object({
    role = string
    mfa  = optional(bool, true)
  }))
}
```
</details>

> Optional real-cloud practice: [AWS lab A3 — variables and precedence](../labs/aws-optional/README.md#a3--variables-outputs-and-precedence-day-2).

---

## L. Lesson assessment — mastery quiz

Closed book. Write every answer down **before** opening the answers, and give each a confidence (1 = guess, 2 = unsure, 3 = sure). Pass mark: **10/12**. Record the score in [SCORECARD.md](../SCORECARD.md) and log misses in [mistakes/error-log.md](../mistakes/error-log.md).

*These questions are the self-test questions from the original 15-day notes, corrected and regrouped by topic.*

1. When do you actually need an explicit `depends_on` instead of relying on implicit dependencies?
2. Which command visualizes the dependency graph, and in what format?
3. Write the reference to the `id` attribute of `aws_instance.web`.
4. What does `aws_instance.web[*].id` return, and when is it useful?
5. Rank by precedence, highest first: `terraform.tfvars`, `-var` flag, environment variable, variable default.
6. Which arguments are valid in a `variable` block, and which commonly assumed one is not?
7. Does `sensitive = true` on an output encrypt its value in state?
8. What is the difference between `object` and `tuple`?
9. Which file names are loaded automatically without `-var-file`?
10. What does `jsonencode()` do? Give one common use.
11. Can a `dynamic` block create multiple top-level resources?
12. Write a conditional that gives `"t3.large"` when `var.is_prod` is true, else `"t3.micro"`.

<details><summary>Answers</summary>

1. Only when a real dependency exists that no attribute reference expresses (e.g. an IAM policy that must exist before a function first runs).
2. `terraform graph`, which outputs DOT (render it with Graphviz).
3. `aws_instance.web.id`
4. A list of `id`s from every instance of a `count` resource; useful to pass "all IDs" as one value. For a `for_each` resource use `values(aws_instance.web)[*].id` or a `for` expression.
5. `-var` flag → `terraform.tfvars` → `TF_VAR_` environment variable → default.
6. Valid: `type`, `default`, `description`, `validation`, `sensitive`, `nullable`, `ephemeral` (1.10+). Not valid: `depends_on`.
7. No. It only redacts the value in CLI output; state still holds plain text.
8. `object` has named attributes, each with its own type; `tuple` is a fixed-length sequence with a type per position and no names.
9. `terraform.tfvars`, `terraform.tfvars.json`, and any `*.auto.tfvars` / `*.auto.tfvars.json`.
10. Converts a Terraform value to a JSON string, e.g. writing an IAM policy as an HCL object.
11. No. It generates repeated nested blocks inside one resource (e.g. `ingress`). Multiple resources need `count` or `for_each`.
12. `var.is_prod ? "t3.large" : "t3.micro"`
</details>

## M. Summary
- Block / argument / attribute / expression. Map argument (`=`) vs nested block.
- Variables: inputs with type, default, validation, sensitive, nullable, ephemeral.
- Precedence **D-E-T-J-A-C**; non-auto tfvars need `-var-file`.
- Locals: internal names; outputs: return values; sensitive outputs need `sensitive = true`.
- `for` (`[]` → list, `{}` → map), splat `[*]`, conditional `?:`, `dynamic` for nested blocks.
- Implicit deps from references; `depends_on` for hidden ones; destroy reverses the order.

### Flashcards (Day 2)
| Front | Back |
|---|---|
| Variable precedence | default < TF_VAR < terraform.tfvars < .tfvars.json < *.auto.tfvars < -var/-var-file |
| Auto-loaded var files | `terraform.tfvars`, `terraform.tfvars.json`, `*.auto.tfvars`, `*.auto.tfvars.json` |
| `merge` vs `concat` | merge = maps; concat = lists |
| `lookup(map, key, default)` | Value for key, or default if missing |
| `element(list, i)` | Wraps around with modulo |
| `dynamic` block | Generates repeated nested blocks from a collection |
| `depends_on` value | List of whole resource/module references |
| `optional(type, default)` | Optional object attribute (1.3+) |
| Validation failure happens at | plan (before any changes) |
| `can()` vs `try()` | can → bool success; try → first non-erroring value |

## N. Mastery decision
8–10 ✅ proceed · 6–7 ➕ redo F2/K-section + 5 extra predicts · ≤5 🔁 re-teach C2, C6.
