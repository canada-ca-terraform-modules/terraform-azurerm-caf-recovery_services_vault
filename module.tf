resource "azurerm_recovery_services_vault" "recovery_services_vault" {
  # Optional override: recovery_services_vault.name (default: CAF-generated local.name)
  name                = try(var.recovery_services_vault.name, local.name)
  location            = var.resource_group.Backups.location
  resource_group_name = var.resource_group.Backups.name
  sku                 = var.sku
  tags                = var.tags

  # soft_delete_enabled intentionally NOT set: the property was removed from this
  # resource in azurerm provider v5.0 (soft delete is now always-on and cannot be
  # disabled through the API/provider). var.soft_delete_enabled is retained for
  # backward compatibility with existing callers but is now a no-op.

  public_network_access_enabled      = try(var.recovery_services_vault.public_network_access_enabled, true)
  storage_mode_type                  = try(var.recovery_services_vault.storage_mode_type, "GeoRedundant")
  cross_region_restore_enabled       = try(var.recovery_services_vault.cross_region_restore_enabled, false)
  immutability                       = try(var.recovery_services_vault.immutability, null)
  classic_vmware_replication_enabled = try(var.recovery_services_vault.classic_vmware_replication_enabled, null)

  dynamic "identity" {
    for_each = try(var.recovery_services_vault.identity, null) != null ? [var.recovery_services_vault.identity] : []
    content {
      type         = identity.value.type
      identity_ids = try(identity.value.identity_ids, null)
    }
  }

  dynamic "encryption" {
    for_each = try(var.recovery_services_vault.encryption, null) != null ? [var.recovery_services_vault.encryption] : []
    content {
      key_id                            = encryption.value.key_id
      infrastructure_encryption_enabled = encryption.value.infrastructure_encryption_enabled
      user_assigned_identity_id         = try(encryption.value.user_assigned_identity_id, null)
      use_system_assigned_identity      = try(encryption.value.use_system_assigned_identity, null)
    }
  }

  dynamic "monitoring" {
    for_each = try(var.recovery_services_vault.monitoring, null) != null ? [var.recovery_services_vault.monitoring] : []
    content {
      alerts_for_all_job_failures_enabled            = try(monitoring.value.alerts_for_all_job_failures_enabled, null)
      alerts_for_all_failover_issues_enabled         = try(monitoring.value.alerts_for_all_failover_issues_enabled, null)
      alerts_for_all_replication_issues_enabled      = try(monitoring.value.alerts_for_all_replication_issues_enabled, null)
      alerts_for_critical_operation_failures_enabled = try(monitoring.value.alerts_for_critical_operation_failures_enabled, null)
      email_notifications_for_site_recovery_enabled  = try(monitoring.value.email_notifications_for_site_recovery_enabled, null)
    }
  }
}

resource "azurerm_backup_policy_vm" "backup_policy_vm" {
  for_each = try(var.recovery_services_vault.schedules, {})

  # Optional override: schedules.<key>.name (default: CAF-generated formula below)
  name                = try(each.value.name, replace("${var.env}CNR-${var.group}_${var.project}-${each.key}-rsvp", "_", "-"))
  resource_group_name = var.resource_group.Backups.name
  recovery_vault_name = azurerm_recovery_services_vault.recovery_services_vault.name
  # Possible timezone values at https://jackstromberg.com/2017/01/list-of-time-zones-consumed-by-azure/
  timezone                       = try(each.value.timezone, "Eastern Standard Time")
  instant_restore_retention_days = try(each.value.instant_restore_retention_days, 2)
  policy_type                    = try(each.value.policy_type, "V1")
  consistency_type               = try(each.value.consistency_type, null)

  backup {
    frequency     = try(each.value.backup.frequency, "Daily")
    time          = try(each.value.backup.time, "23:00")
    weekdays      = try(each.value.backup.weekdays, null)
    hour_interval = try(each.value.backup.hour_interval, null)
    hour_duration = try(each.value.backup.hour_duration, null)
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

  # weekdays/weeks and days/include_last_days are mutually exclusive per the
  # azurerm_backup_policy_vm schema — days takes priority when the caller sets it.
  dynamic "retention_monthly" {
    for_each = try(each.value.retention_monthly, null) != null ? [1] : []
    content {
      count             = try(each.value.retention_monthly.count, 12)
      weekdays          = try(each.value.retention_monthly.days, null) == null ? try(each.value.retention_monthly.weekdays, ["Sunday"]) : null
      weeks             = try(each.value.retention_monthly.days, null) == null ? try(each.value.retention_monthly.weeks, ["Last"]) : null
      days              = try(each.value.retention_monthly.days, null)
      include_last_days = try(each.value.retention_monthly.days, null) != null ? try(each.value.retention_monthly.include_last_days, false) : null
    }
  }

  dynamic "retention_yearly" {
    for_each = try(each.value.retention_yearly, null) != null ? [1] : []
    content {
      count             = try(each.value.retention_yearly.count, 12)
      weekdays          = try(each.value.retention_yearly.days, null) == null ? try(each.value.retention_yearly.weekdays, ["Sunday"]) : null
      weeks             = try(each.value.retention_yearly.days, null) == null ? try(each.value.retention_yearly.weeks, ["Last"]) : null
      months            = try(each.value.retention_yearly.months, ["January"])
      days              = try(each.value.retention_yearly.days, null)
      include_last_days = try(each.value.retention_yearly.days, null) != null ? try(each.value.retention_yearly.include_last_days, false) : null
    }
  }

  dynamic "instant_restore_resource_group" {
    for_each = try(each.value.instant_restore_resource_group, null) != null ? [each.value.instant_restore_resource_group] : []
    content {
      prefix = instant_restore_resource_group.value.prefix
      suffix = try(instant_restore_resource_group.value.suffix, null)
    }
  }

  dynamic "tiering_policy" {
    for_each = try(each.value.tiering_policy, null) != null ? [each.value.tiering_policy] : []
    content {
      archived_restore_point {
        mode          = tiering_policy.value.archived_restore_point.mode
        duration      = try(tiering_policy.value.archived_restore_point.duration, null)
        duration_type = try(tiering_policy.value.archived_restore_point.duration_type, null)
      }
    }
  }

  lifecycle {
    ignore_changes = [name] # due to the underscore being removed on new names, but allowed on existing resources, changing this in the newer module should not trigger a replace.
  }
}
