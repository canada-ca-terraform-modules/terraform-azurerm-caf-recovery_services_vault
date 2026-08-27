# `test/live/` - live-test harness

A live, real-Azure-resource harness used by the `live-test` PR check (see
the [`live-test-actions`](https://github.com/canada-ca-terraform-modules/live-test-actions)
repo and this module's own `.github/workflows/live-test.yml`) to prove that
an open PR doesn't destroy or replace a resource a real consumer already has
running.

## What's here

| File | Purpose |
|---|---|
| `main.tf` | Module block with `source = "../../"` (a relative path, not a pinned `?ref`), the `azurerm` provider config, and an empty `backend "local" {}` block (path supplied at `init` time). |
| `test_dependencies.tf` | A dedicated, throwaway resource group this harness owns outright. Its name is suffixed with `var.pr_number` so concurrently open PRs never collide. |
| `variables.tf` | `env`, `location`, `tags`, `pr_number`, `group`, `project`, and `recovery_services_vault` (typed `any`, passed straight through to the module). |
| `config/recovery_services_vault.tfvars` | One representative real-usage fixture: a single vault with a daily backup policy schedule, Standard SKU. |

## Running it manually

Requires your own `az login` session against the sandbox subscription (CI
uses OIDC instead).

```bash
cd test/live
terraform init
terraform plan  -var-file=config/recovery_services_vault.tfvars
terraform apply -var-file=config/recovery_services_vault.tfvars
```

Confirm only the live-test resource group and `module.recovery_services_vault`
are planned/applied, then tear it down:

```bash
terraform destroy -var-file=config/recovery_services_vault.tfvars
```

No `.tfstate` file is ever committed under `test/live/` - every run is
fully ephemeral, whether run by CI or by hand.

## Module-specific notes

- The module expects `resource_group.Backups.{name,location}` (a map keyed
  by RG "purpose", not a flat object). `test_dependencies.tf` provides this
  via a `locals` block wrapping the throwaway resource group.
- `soft_delete_enabled` is intentionally NOT exercised here - it's a
  deprecated no-op variable retained for backward compatibility only.
- Recovery Services Vault soft delete is always enabled by Azure - destroy
  operations can take longer than a simple resource group delete because the
  vault must be emptied of any registered items first. The workflow's
  `Destroy` step handles this via `terraform destroy -auto-approve`.
