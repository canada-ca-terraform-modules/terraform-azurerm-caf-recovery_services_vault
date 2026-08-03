## [1.3.0] - 2026-08-03

The format from this entry onward follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

### Changed

- Upgraded `azurerm` provider constraint to `~> 5.0` (created `providers.tf`; none existed before).
- `azurerm_recovery_services_vault.recovery_services_vault` output and `azurerm_backup_policy_vm.backup_policy_vm`
  output are now marked `sensitive = true` (both expose full resource objects).

### Fixed

- **Breaking (provider-side):** `azurerm_recovery_services_vault.soft_delete_enabled` was removed
  from the resource schema in azurerm provider v5.0 — soft delete is now always enabled and cannot
  be disabled through the API. The module no longer passes this argument to the resource.
  The `soft_delete_enabled` module input variable is retained (default `true`) so existing callers
  do not break `terraform plan`, but it is now a no-op — see README.

### Added

- `recovery_services_vault` new optional top-level keys: `name` (override), `public_network_access_enabled`,
  `storage_mode_type`, `cross_region_restore_enabled`, `immutability`, `classic_vmware_replication_enabled`,
  `identity`, `encryption`, `monitoring`.
- `recovery_services_vault.schedules.<key>` new optional keys: `name` (override), `policy_type`,
  `consistency_type`, `backup.hour_interval`, `backup.hour_duration`, `retention_monthly.days`,
  `retention_monthly.include_last_days`, `retention_yearly.days`, `retention_yearly.include_last_days`,
  `instant_restore_resource_group`, `tiering_policy`.
- `providers.tf`, `.tflint.hcl`, `.gitignore`, `.gitattributes` (none previously existed).
- `.github/workflows/terraform-ci.yml` and `.github/workflows/documentation.yml`.
- `ESLZ/recovery_services_vault.tf` (module block, previously absent) and updated
  `ESLZ/recovery_services_vault.tfvars` with commented examples for every new argument.
- `tests/recovery_services_vault.tftest.hcl` and `tests/upgrade_compat.tftest.hcl` (no prior test
  coverage existed).

### Known blockers

- None. All existing tfvars shapes continue to plan identically; all new arguments are additive and
  gated with `try(..., <safe-default>)`.

## v1.2.0 (Sept 2024)
FEATURES:
* Moved backup_policy_vm inside the module from the ESLZ. Fixes an issue when deploying more than one backup policy

BUGS:

## v1.1.0 (Aug 2020)

FEATURES: 
* Update code for terraform 0.13

IMPROVEMENTS:

BUGS:

## v1.0.0 (June 2020)

FEATURES: 
* **new feature:**  1st commit

IMPROVEMENTS:

BUGS:
