mock_provider "azurerm" {}

variables {
  env               = "Dev"
  userDefinedString = "myvault"
  group             = "OPS"
  project           = "CORE"
  tags              = { costCenter = "1234" }
  resource_group = {
    Backups = {
      name     = "rg-test"
      location = "canadacentral"
    }
  }
}

run "naming_convention" {
  command = plan

  assert {
    condition     = azurerm_recovery_services_vault.recovery_services_vault.name == "DevCNR-myvault-rsv"
    error_message = "Name must follow {env4}CNR-{userDefinedString}-rsv convention"
  }
}

run "default_values" {
  command = plan

  assert {
    condition     = azurerm_recovery_services_vault.recovery_services_vault.sku == "Standard"
    error_message = "sku must default to Standard"
  }

  assert {
    condition     = azurerm_recovery_services_vault.recovery_services_vault.storage_mode_type == "GeoRedundant"
    error_message = "storage_mode_type must default to GeoRedundant"
  }

  assert {
    condition     = azurerm_recovery_services_vault.recovery_services_vault.public_network_access_enabled == true
    error_message = "public_network_access_enabled must default to true"
  }

  assert {
    condition     = azurerm_recovery_services_vault.recovery_services_vault.cross_region_restore_enabled == false
    error_message = "cross_region_restore_enabled must default to false"
  }
}

run "soft_delete_enabled_is_noop" {
  command = plan

  variables {
    soft_delete_enabled = false
  }

  assert {
    condition     = azurerm_recovery_services_vault.recovery_services_vault.name == "DevCNR-myvault-rsv"
    error_message = "Passing soft_delete_enabled must not break plan (removed from azurerm v5 resource schema)"
  }
}

run "custom_vault_name_override" {
  command = plan

  variables {
    recovery_services_vault = {
      name = "my-existing-vault"
    }
  }

  assert {
    condition     = azurerm_recovery_services_vault.recovery_services_vault.name == "my-existing-vault"
    error_message = "recovery_services_vault.name override not applied"
  }
}

run "new_v5_optional_arguments" {
  command = plan

  variables {
    recovery_services_vault = {
      immutability                       = "Locked"
      classic_vmware_replication_enabled = false
      identity = {
        type = "SystemAssigned"
      }
      monitoring = {
        alerts_for_all_job_failures_enabled = false
      }
    }
  }

  assert {
    condition     = azurerm_recovery_services_vault.recovery_services_vault.immutability == "Locked"
    error_message = "immutability must be set from recovery_services_vault.immutability"
  }

  assert {
    condition     = azurerm_recovery_services_vault.recovery_services_vault.identity[0].type == "SystemAssigned"
    error_message = "identity block must render when recovery_services_vault.identity is set"
  }

  assert {
    condition     = azurerm_recovery_services_vault.recovery_services_vault.monitoring[0].alerts_for_all_job_failures_enabled == false
    error_message = "monitoring block must render when recovery_services_vault.monitoring is set"
  }
}

run "backup_policy_defaults" {
  command = plan

  variables {
    recovery_services_vault = {
      schedules = {
        daily = {
          retention_daily = { count = 7 }
        }
      }
    }
  }

  assert {
    condition     = azurerm_backup_policy_vm.backup_policy_vm["daily"].timezone == "Eastern Standard Time"
    error_message = "timezone must default to Eastern Standard Time"
  }

  assert {
    condition     = azurerm_backup_policy_vm.backup_policy_vm["daily"].policy_type == "V1"
    error_message = "policy_type must default to V1"
  }

  assert {
    condition     = azurerm_backup_policy_vm.backup_policy_vm["daily"].retention_daily[0].count == 7
    error_message = "retention_daily.count not applied"
  }
}

run "backup_policy_custom_name_override" {
  command = plan

  variables {
    recovery_services_vault = {
      schedules = {
        daily = {
          name            = "my-existing-policy"
          retention_daily = { count = 7 }
        }
      }
    }
  }

  assert {
    condition     = azurerm_backup_policy_vm.backup_policy_vm["daily"].name == "my-existing-policy"
    error_message = "schedules.<key>.name override not applied"
  }
}

run "backup_policy_v2_enhanced" {
  command = plan

  variables {
    recovery_services_vault = {
      schedules = {
        daily = {
          policy_type      = "V2"
          consistency_type = "OnlyCrashConsistent"
          retention_daily  = { count = 7 }
        }
      }
    }
  }

  assert {
    condition     = azurerm_backup_policy_vm.backup_policy_vm["daily"].policy_type == "V2"
    error_message = "policy_type must be settable to V2"
  }

  assert {
    condition     = azurerm_backup_policy_vm.backup_policy_vm["daily"].consistency_type == "OnlyCrashConsistent"
    error_message = "consistency_type must be applied when policy_type = V2"
  }
}

run "backup_policy_hourly_frequency" {
  command = plan

  variables {
    recovery_services_vault = {
      schedules = {
        hourly = {
          backup = {
            frequency     = "Hourly"
            time          = "23:00"
            hour_interval = 4
            hour_duration = 4
          }
          retention_daily = { count = 7 }
        }
      }
    }
  }

  assert {
    condition     = azurerm_backup_policy_vm.backup_policy_vm["hourly"].backup[0].hour_interval == 4
    error_message = "backup.hour_interval must be applied when frequency = Hourly"
  }

  assert {
    condition     = azurerm_backup_policy_vm.backup_policy_vm["hourly"].backup[0].hour_duration == 4
    error_message = "backup.hour_duration must be applied when frequency = Hourly"
  }
}

run "backup_policy_monthly_days_variant" {
  command = plan

  variables {
    recovery_services_vault = {
      schedules = {
        monthly = {
          retention_daily = { count = 7 }
          retention_monthly = {
            count             = 12
            days              = [1, 15]
            include_last_days = true
          }
        }
      }
    }
  }

  assert {
    condition     = azurerm_backup_policy_vm.backup_policy_vm["monthly"].retention_monthly[0].include_last_days == true
    error_message = "retention_monthly.include_last_days must be applied"
  }
}

run "backup_policy_tiering_and_instant_restore_rg" {
  command = plan

  variables {
    recovery_services_vault = {
      schedules = {
        tiered = {
          retention_daily = { count = 7 }
          instant_restore_resource_group = {
            prefix = "rg-instant-restore-"
          }
          tiering_policy = {
            archived_restore_point = {
              mode = "TierRecommended"
            }
          }
        }
      }
    }
  }

  assert {
    condition     = azurerm_backup_policy_vm.backup_policy_vm["tiered"].instant_restore_resource_group[0].prefix == "rg-instant-restore-"
    error_message = "instant_restore_resource_group block not rendered"
  }

  assert {
    condition     = azurerm_backup_policy_vm.backup_policy_vm["tiered"].tiering_policy[0].archived_restore_point[0].mode == "TierRecommended"
    error_message = "tiering_policy block not rendered"
  }
}

run "backup_policy_weekly_weekdays" {
  command = plan

  variables {
    recovery_services_vault = {
      schedules = {
        weekly = {
          backup = {
            frequency = "Weekly"
            time      = "23:00"
            weekdays  = ["Sunday", "Wednesday"]
          }
          retention_weekly = {
            count    = 5
            weekdays = ["Sunday", "Wednesday"]
          }
        }
      }
    }
  }

  assert {
    condition     = azurerm_backup_policy_vm.backup_policy_vm["weekly"].backup[0].frequency == "Weekly"
    error_message = "backup.frequency must be Weekly"
  }

  assert {
    condition     = toset(azurerm_backup_policy_vm.backup_policy_vm["weekly"].backup[0].weekdays) == toset(["Sunday", "Wednesday"])
    error_message = "backup.weekdays must be applied for Weekly frequency"
  }
}

run "backup_policy_daily_has_no_weekdays" {
  command = plan

  variables {
    recovery_services_vault = {
      schedules = {
        daily = {
          retention_daily = { count = 7 }
        }
      }
    }
  }

  assert {
    condition     = try(length(azurerm_backup_policy_vm.backup_policy_vm["daily"].backup[0].weekdays), 0) == 0
    error_message = "backup.weekdays must be null/empty for Daily frequency (only applies to Weekly)"
  }
}
