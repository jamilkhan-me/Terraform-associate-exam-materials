# Labs Index

All labs run **offline** with Terraform ≥ 1.5 (1.12+ recommended). They use only the built-in
`terraform` provider (`terraform_data`, `terraform_remote_state`) and `local-exec`
provisioners — **no downloads, no cloud account, no cost**. Labs 09 has an optional
AWS-based section that is conceptual only and requires your explicit go-ahead before any
real-cloud work.

> These labs were authored without a Terraform binary available, so they have **not been
> executed** in the authoring environment. Expected outputs are based on documented
> Terraform behaviour; minor wording differences between Terraform versions are normal.
> If you see a real difference in *behaviour*, tell your instructor — that's a learning moment.

| Lab | Topic | Day | Est. time |
|---|---|---|---|
| [01](lab-01/README.md) | First configuration & core workflow | 1, 3 | 40 min |
| [02](lab-02/README.md) | Variables, locals, outputs, validation, precedence | 2 | 60 min |
| [03](lab-03/README.md) | Resources vs data sources (`terraform_remote_state`) | 4 | 35 min |
| [04](lab-04/README.md) | Dependencies, lifecycle, custom conditions, provisioners | 4 | 60 min |
| [05](lab-05/README.md) | `count`, `for_each`, `for`, `dynamic`-style expressions | 2, 4 | 50 min |
| [06](lab-06/README.md) | Building and calling local modules | 6 | 60 min |
| [07](lab-07/README.md) | Reading plans, update vs replace, `-replace`, saved plans | 3, 8 | 45 min |
| [08](lab-08/README.md) | State inspection and safe state operations | 5 | 60 min |
| [09](lab-09/README.md) | Importing existing infrastructure | 5 | 40 min |
| [10](lab-10/README.md) | Backends, partial config, state migration | 5 | 40 min |
| [11](lab-11/README.md) | CLI workspaces and environment separation | 6 | 35 min |
| [12](lab-12/README.md) | Troubleshooting broken configurations | 8 | 60 min |

## Rules
1. Work inside `lab-NN/starter/` (copy it first if you want to keep the original: `cp -r starter work`).
2. Hints are progressive — read Hint 1, try again, then Hint 2.
3. Open `SOLUTION.md` only when finished or stuck for 20 minutes.
4. Never copy lab state files into a real project, and never run lab commands in a real project directory.

## Clean-up
Each lab can be reset with:
```bash
rm -rf .terraform .terraform.lock.hcl terraform.tfstate* terraform.tfstate.d *.tfplan
```
