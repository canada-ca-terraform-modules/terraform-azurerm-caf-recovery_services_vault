output "recovery_services_vault" {
  description = "Returns the full set of recovery_services_vault created"
  value       = azurerm_recovery_services_vault.recovery_services_vault
  sensitive   = true
}

output "backup_policy_vm" {
  description = "Returns the full set of backup_policy_vm created"
  value       = azurerm_backup_policy_vm.backup_policy_vm
  sensitive   = true
}
