resource azurerm_recovery_services_vault recovery_services_vault {
  count               = var.deploy ? 1 : 0
  name                = local.name
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  sku                 = var.sku
  soft_delete_enabled = var.soft_delete_enabled
  tags                = var.tags
}