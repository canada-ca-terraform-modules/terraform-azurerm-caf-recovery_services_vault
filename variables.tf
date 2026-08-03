variable "env" {
  description = "(Required) You can use a prefix to add to the list of resource groups you want to create"
  type        = string
}

variable "resource_group" {
  description = "(Required) Resource group object where the Recovery Services Vault will be created. Must contain a `Backups` key with `.name` and `.location` attributes. Changing this forces a new resource to be created."
  type        = any
}

variable "tags" {
  description = "(Required) Tags to be applied to the Recovery Services Vault."
  type        = map(string)
}

variable "maxLength" {
  description = "(Optional) Maximum length of the generated Recovery Services Vault name."
  default     = 50
  type        = number
}

variable "userDefinedString" {
  description = "(Required) UserDefinedString part of the name of the resource"
  type        = string
}

variable "sku" {
  description = "(Optional) sku of the resource"
  type        = string
  default     = "Standard"
}

# Intentionally retained for backward compat; azurerm v5 removed the property this fed.
# tflint-ignore: terraform_unused_declarations
variable "soft_delete_enabled" {
  description = "(Deprecated/no-op) Retained for backward compatibility only. The soft_delete_enabled property was removed from azurerm_recovery_services_vault in azurerm provider v5.0 - soft delete is now always enabled and cannot be disabled through the API. This variable is no longer passed to the resource."
  type        = bool
  default     = true
}

variable "recovery_services_vault" {
  description = "Object containing all optional parameters for the Recovery Services Vault and its backup policies (schedules). See README and ESLZ/recovery_services_vault.tfvars for the full supported shape."
  type        = any
  default     = {}
}

variable "group" {
  description = "(Required) Group part of the name of the backup_policy"
  type        = string
}

variable "project" {
  description = "(Required) Project part of the name of the backup_policy"
  type        = string
}
