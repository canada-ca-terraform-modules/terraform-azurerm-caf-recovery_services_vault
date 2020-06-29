output "recovery_services_vault" {
  depends_on = [azurerm_recovery_services_vault.recovery_services_vault]

  description = "Returns the full set of recovery_services_vault created"
  value = azurerm_recovery_services_vault.recovery_services_vault[0]
}