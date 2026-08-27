variable "env" {
  description = "Environment prefix used in the generated Recovery Services Vault name"
  type        = string
  default     = "livetest"
}

variable "location" {
  description = "Location for the throwaway live-test resource group"
  type        = string
  default     = "canadacentral"
}

variable "tags" {
  description = "Tags applied to the Recovery Services Vault created by this harness"
  type        = map(string)
  default = {
    purpose = "module-live-test"
  }
}

variable "pr_number" {
  description = <<-EOT
    Suffix applied to test_dependencies.tf resource names so concurrent PRs
    against this module never collide on the same sandbox subscription. CI
    sources this from `TF_VAR_pr_number` (`github.event.number`); manual runs
    can leave the default or pass their own value.
  EOT
  type        = string
  default     = "manual"
}

variable "group" {
  description = "Group part of the name of the backup_policy"
  type        = string
  default     = "CTO"
}

variable "project" {
  description = "Project part of the name of the backup_policy"
  type        = string
  default     = "ESLZ"
}

variable "recovery_services_vault" {
  description = "Recovery Services Vault configuration object, passed straight through to the module under test"
  type        = any
  default     = {}
}
