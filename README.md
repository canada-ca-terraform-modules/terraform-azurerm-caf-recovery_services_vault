# Deploys an Azure Recovery Service Vault

Creates an Azure Recovery Service Vault plan.

Reference the module to a specific version (recommended):

```hcl
module Project-rsv {
  deploy = var.deployOptionalFeatures.recovery_services_vault ? true : false
  env               = var.env
  userDefinedString = "${var.group}_${var.project}"
  resource_group    = local.resource_groups_L1.Network
  sku                 = try(var.optionalFeaturesConfig.recovery_services_vault.sku, "Standard")
  soft_delete_enabled = try(var.optionalFeaturesConfig.recovery_services_vault.soft_delete_enabled, true)
  tags                = var.tags
}

locals {
  Project-rsv = module.Project-rsv.recovery_services_vault
}
```

## Inputs

| Name                | Type   | Default  | Description                                                                                                       |
| ------------------- | ------ | -------- | ----------------------------------------------------------------------------------------------------------------- |
| resource_group      | object | None     | (Required) Resource group object where to create the resource. Changing this forces a new resource to be created. |
| tags                | map    | None     | (Required) Map of tags for the deployment.                                                                        |
| max_length          | string | None     | (Optional) maximum length to the name of the resource.                                                            |
| env                 | string | None     | (Required) You can use a prefix to add to the list of resource groups you want to create                          |
| userDefinedString   | string | None     | (Required) UserDefinedString part of the name of the resource                                                     |
| sku                 | string | Standard | (Optional) sku of the resource                                                                                    |
| soft_delete_enabled | bool   | true     | (Optional) soft delete enabled of the resource                                                                    |

## Output

| Name                         | Type   | Description                                                          |
| ---------------------------- | ------ | -------------------------------------------------------------------- |
| network_ddos_protection_plan | object | Returns the full object of the created network_ddos_protection_plan. |
