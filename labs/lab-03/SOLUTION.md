# Lab 03 — Solution

| Step | Result | Explanation |
|---|---|---|
| 1–2 | Error during plan | The data source tries to read `../network/terraform.tfstate`, which doesn't exist yet. Data sources **never create** what they look up. |
| 4 | `+ terraform_data.service` only | Data sources are read during plan; they don't "create/update/destroy". `Plan: 1 to add`. |
| 5 | `data.terraform_remote_state.network` and `terraform_data.service` | Data source results are cached in state with `mode = "data"`. |
| 6 | Shows `backend`, `config`, `outputs` | Including all outputs of the other stack. |
| 7 | `~ terraform_data.service` update | The re-read produced new subnets `10.30.0.0/24…` → input changed. |
| 8 | Network untouched | Destroy affects only **managed** resources in *this* state. |

**Step 9 — security concerns**
1. Reading remote state requires read access to the entire state snapshot, which may contain secrets.
2. It couples the consumer to the producer's internal output structure.
Alternatives: provider data sources looking up real objects (e.g. `data "aws_vpc"` by tag), publishing values to SSM Parameter Store, HCP Terraform's `tfe_outputs` data source.

## Takeaways
- `resource` = managed lifecycle, address `TYPE.NAME`.
- `data` = read-only, address `data.TYPE.NAME`, stored in state, re-read every plan.
- Destroying a configuration never touches objects it only reads.
