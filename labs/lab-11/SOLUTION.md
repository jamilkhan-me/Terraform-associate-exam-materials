# Lab 11 — Solution

| Step | Result |
|---|---|
| 1 | `default`; list shows `* default` |
| 2 | `workspace = "default"`, `servers = ["web-default-0"]`; state in `./terraform.tfstate` |
| 3 | `servers = ["web-dev-0"]`, size t3.micro; `terraform.tfstate.d/dev/terraform.tfstate` |
| 4 | 3 servers `web-prod-0..2`, `m5.large` |
| 5 | 1 server, `t3.small` |
| 6 | Only `terraform_data.server[0]` from dev — workspaces isolate **state** |
| 7 | Active workspace can't be deleted. Non-empty workspace delete refused; `-force` deletes the state while leaving real resources running and **unmanaged** (orphans) |
| 8 | Refused — `default` can't be deleted |
| 9 | `TF_WORKSPACE` selects the workspace for that command (useful in CI) |

## Task 10 — why workspaces are weak for prod/non-prod
1. Same backend and same credentials → anyone who can apply dev can apply prod.
2. Nothing in the code shows which workspace is selected → easy to apply to the wrong one.
3. Environments can't diverge structurally without `terraform.workspace` conditionals everywhere.
4. Blast radius: one backend misconfiguration affects all environments.

Directory layout:
```
envs/
  dev/   main.tf (module "app" {...}), backend key dev/,  provider assumes dev role
  prod/  main.tf (module "app" {...}), backend key prod/, provider assumes prod role
modules/
  app/
```
In HCP Terraform: separate workspaces per env, team permissions per workspace/project.
