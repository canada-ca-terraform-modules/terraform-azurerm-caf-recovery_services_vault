terraform {
  required_version = ">= 1.9"
}

variable "recovery_services_vaults" {
  type        = any
  default     = {}
  description = "Map of recovery_services_vault objects. Key is used as userDefinedString. See recovery_services_vault.tfvars for shape."
}

module "recovery_services_vault" {
  for_each = var.recovery_services_vaults
  source   = "github.com/canada-ca-terraform-modules/terraform-azurerm-caf-recovery_services_vault.git?ref=v1.3.0"

  env                     = var.env
  userDefinedString       = each.key
  resource_group          = local.resource_groups_all
  tags                    = var.tags
  group                   = var.group
  project                 = var.project
  sku                     = try(each.value.sku, "Standard")
  recovery_services_vault = each.value
}
