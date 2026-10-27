# Lab 04 — Solution

## Task 1 — graph
```
network ──► database ──(depends_on)──► migration
app_version ──(replace_triggered_by)──► server
tagged, protected: independent
```
The `migration → database` edge exists only because of `depends_on`.

## Task 2
- Order: `network`, `app_version`, `tagged`, `protected` start in parallel; `database` after `network`; `migration` after `database`; `server` after `app_version`.
- Warning: `Check block assertion failed … app_version is a new major (x.0.0)` — apply **succeeds**.
- `provisioner.log`: one "created migration" line.

## Task 3
"No changes", no new log line — creation-time provisioners run only on create.

## Task 4–5 (`app_version = 1.1.0`)
- `app_version`: `~ update in-place` (input changed).
- `server`: **`+/- create replacement and then destroy`** — triggered by `replace_triggered_by` *and* ordered by `create_before_destroy`. (Its own `input` also changed, but that alone would be an in-place update.)
- Check warning disappears (1.1.0 does not end in `.0.0`).

## Task 6
- `0.9.0` → passes validation (format OK) but **precondition** on `server` fails: "Pre-1.0 versions may not be deployed." Plan errors.
- `banana` → **validation** fails: "app_version must look like 1.2.3." Plan errors before resources are evaluated.

## Task 7
"No changes" for `tagged` — `ignore_changes = [input]` makes Terraform ignore config changes to `input` after creation. (It would still use the new value if the resource were re-created.)

## Task 8
```
Error: Instance cannot be destroyed
  Resource terraform_data.protected has lifecycle.prevent_destroy set, but the plan calls for this resource to be destroyed.
```
Note: deleting the whole resource block would remove the protection along with it.

## Task 9
- Apply errors: `local-exec provisioner error … exit status 1`.
- The new `migration` object exists but is marked **tainted** in state (`terraform state show` shows it; plan says "is tainted, so must be replaced").
- Restoring the command and applying replaces it again, and the provisioner succeeds.

## Task 10
- Destroy order is the reverse of dependencies: `migration` before `database` before `network`; `server` before `app_version`.
- `provisioner.log` gains a "destroyed migration" line from the `when = destroy` provisioner.

## Takeaways
| Mechanism | Failure effect |
|---|---|
| validation | error, before resources are planned |
| precondition / postcondition | error, stops that resource and dependents |
| check | warning only |
| provisioner failure on create | resource tainted |
