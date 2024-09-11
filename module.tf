resource azurerm_recovery_services_vault recovery_services_vault {
  name                = local.name
  location            = var.resource_group.Backups.location
  resource_group_name = var.resource_group.Backups.name
  sku                 = var.sku
  soft_delete_enabled = var.soft_delete_enabled
  tags                = var.tags
}

resource "azurerm_backup_policy_vm" "backup_policy_vm" {
  for_each = try(var.recovery_services_vault.schedules, {})
  
  name                = "${var.env}CNR-${var.group}_${var.project}-${each.key}-rsvp"
  resource_group_name = var.resource_group.Backups.name
  recovery_vault_name = azurerm_recovery_services_vault.recovery_services_vault.name
  # Possible timezone values at https://jackstromberg.com/2017/01/list-of-time-zones-consumed-by-azure/
  timezone                       = try(each.value.timezone, "Eastern Standard Time")
  instant_restore_retention_days = try(each.value.instant_restore_retention_days, 2)

  backup {
    frequency = try(each.value.backup.frequency, "Daily")
    time      = try(each.value.backup.time, "23:00")
    weekdays  = try(each.value.backup.weekdays, [])
  }

  dynamic "retention_daily" { 
    for_each = try(each.value.retention_daily, null) != null ? [1] : []
    content {
      count = try(each.value.retention_daily.count, 7)
    }
  }

  dynamic "retention_weekly" {
    for_each = try(each.value.retention_weekly, null) != null ? [1] : []
    content {
      count    = try(each.value.retention_weekly.count, 5)
      weekdays = try(each.value.retention_weekly.weekdays, ["Sunday"])
    }
  }

  dynamic "retention_monthly" {
    for_each = try(each.value.retention_monthly, null) != null ? [1] : []
    content {
      count    = try(each.value.retention_monthly.count, 12)
      weekdays = try(each.value.retention_monthly.weekdays, ["Sunday"])
      weeks    = try(each.value.retention_monthly.weeks, ["Last"])
    }
  }

  dynamic "retention_yearly" {
    for_each = try(each.value.retention_yearly, null) != null ? [1] : []
    content {
      count    = try(each.value.retention_yearly.count, 12)
      weekdays = try(each.value.retention_yearly.weekdays, ["Sunday"])
      weeks    = try(each.value.retention_yearly.weeks, ["Last"])
      months   = try(each.value.retention_yearly.months, ["January"])
    }
  }
}