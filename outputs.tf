output "recovery_services_vault" {
  description = "Returns the full set of recovery_services_vault created"
  value       = azurerm_recovery_services_vault.recovery_services_vault
}

output "backup_policy_vm" {
  value = azurerm_backup_policy_vm.backup_policy_vm#[keys(try(var.recovery_services_vault.schedules, {}))[0]]
}