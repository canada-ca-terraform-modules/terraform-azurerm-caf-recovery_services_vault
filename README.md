# Deploys an Azure Recovery Service Vault

Creates an Azure Recovery Service Vault, along with any VM backup policies (`azurerm_backup_policy_vm`)
declared under `recovery_services_vault.schedules`, following the SSC CAF naming convention.
Requires the `azurerm` provider `~> 5.0`.

Reference the module to a specific version (recommended):

```hcl
module Project-rsv {
  source = "github.com/canada-ca-terraform-modules/terraform-azurerm-caf-recovery_services_vault.git?ref=v1.3.0"

  env                 = var.env
  userDefinedString   = "${var.group}_${var.project}"
  resource_group      = local.resource_groups_L1.Network
  sku                 = try(var.optionalFeaturesConfig.recovery_services_vault.sku, "Standard")
  tags                = var.tags
}

locals {
  Project-rsv = module.Project-rsv.recovery_services_vault
}
```

> **Note:** `soft_delete_enabled` is no longer passed to the underlying resource — the property was
> removed from `azurerm_recovery_services_vault` in azurerm provider v5.0 (soft delete is now
> always enabled and cannot be disabled through the API). The `soft_delete_enabled` module variable
> is retained for backward compatibility with existing callers but is now a no-op.

## New optional arguments (azurerm >= 5.0)

### `recovery_services_vault` — new top-level keys

| Key | Type | Description |
|---|---|---|
| `name` | string | Override the auto-generated vault name (default: `{env4}CNR-{userDefinedString}-rsv`) |
| `public_network_access_enabled` | bool | Defaults to `true` |
| `storage_mode_type` | string | `GeoRedundant` \| `LocallyRedundant` \| `ZoneRedundant`. Defaults to `GeoRedundant` |
| `cross_region_restore_enabled` | bool | Only valid when `storage_mode_type = GeoRedundant`. Defaults to `false` |
| `immutability` | string | `Locked` \| `Unlocked` \| `Disabled` |
| `classic_vmware_replication_enabled` | bool | Changing this forces a new resource |
| `identity` | object | `{ type, identity_ids }` |
| `encryption` | object | `{ key_id, infrastructure_encryption_enabled, user_assigned_identity_id, use_system_assigned_identity }`. Requires `identity` |
| `monitoring` | object | `{ alerts_for_all_job_failures_enabled, alerts_for_all_failover_issues_enabled, alerts_for_all_replication_issues_enabled, alerts_for_critical_operation_failures_enabled, email_notifications_for_site_recovery_enabled }` |

### `recovery_services_vault.schedules.<key>` — new keys

| Key | Type | Description |
|---|---|---|
| `name` | string | Override the auto-generated backup policy name (default: `{env}CNR-{group}_{project}-{key}-rsvp`) |
| `policy_type` | string | `V1` \| `V2` (Enhanced Policy). Defaults to `V1`. Changing this forces a new resource |
| `consistency_type` | string | Only valid when `policy_type = V2`. Only possible value is `OnlyCrashConsistent` |
| `backup.hour_interval` / `backup.hour_duration` | number | Used when `backup.frequency = Hourly` |
| `retention_monthly.days` / `retention_monthly.include_last_days` | list(number) / bool | Alternative to `weekdays`/`weeks` |
| `retention_yearly.days` / `retention_yearly.include_last_days` | list(number) / bool | Alternative to `weekdays`/`weeks` |
| `instant_restore_resource_group` | object | `{ prefix, suffix }` |
| `tiering_policy` | object | `{ archived_restore_point = { mode, duration, duration_type } }` |

See [`ESLZ/recovery_services_vault.tfvars`](ESLZ/recovery_services_vault.tfvars) for full commented examples.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_backup_policy_vm.backup_policy_vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/backup_policy_vm) | resource |
| [azurerm_recovery_services_vault.recovery_services_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/recovery_services_vault) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_env"></a> [env](#input\_env) | (Required) You can use a prefix to add to the list of resource groups you want to create | `string` | n/a | yes |
| <a name="input_group"></a> [group](#input\_group) | (Required) Group part of the name of the backup\_policy | `string` | n/a | yes |
| <a name="input_maxLength"></a> [maxLength](#input\_maxLength) | (Optional) Maximum length of the generated Recovery Services Vault name. | `number` | `50` | no |
| <a name="input_project"></a> [project](#input\_project) | (Required) Project part of the name of the backup\_policy | `string` | n/a | yes |
| <a name="input_recovery_services_vault"></a> [recovery\_services\_vault](#input\_recovery\_services\_vault) | Object containing all optional parameters for the Recovery Services Vault and its backup policies (schedules). See README and ESLZ/recovery\_services\_vault.tfvars for the full supported shape. | `any` | `{}` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | (Required) Resource group object where the Recovery Services Vault will be created. Must contain a `Backups` key with `.name` and `.location` attributes. Changing this forces a new resource to be created. | `any` | n/a | yes |
| <a name="input_sku"></a> [sku](#input\_sku) | (Optional) sku of the resource | `string` | `"Standard"` | no |
| <a name="input_soft_delete_enabled"></a> [soft\_delete\_enabled](#input\_soft\_delete\_enabled) | (Deprecated/no-op) Retained for backward compatibility only. The soft\_delete\_enabled property was removed from azurerm\_recovery\_services\_vault in azurerm provider v5.0 - soft delete is now always enabled and cannot be disabled through the API. This variable is no longer passed to the resource. | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Required) Tags to be applied to the Recovery Services Vault. | `map(string)` | n/a | yes |
| <a name="input_userDefinedString"></a> [userDefinedString](#input\_userDefinedString) | (Required) UserDefinedString part of the name of the resource | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backup_policy_vm"></a> [backup\_policy\_vm](#output\_backup\_policy\_vm) | Returns the full set of backup\_policy\_vm created |
| <a name="output_recovery_services_vault"></a> [recovery\_services\_vault](#output\_recovery\_services\_vault) | Returns the full set of recovery\_services\_vault created |
<!-- END_TF_DOCS -->
