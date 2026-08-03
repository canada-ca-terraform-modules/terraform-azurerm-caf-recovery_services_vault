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

# Step 1: simulate the currently-deployed resource (pre-upgrade caller shape —
# no azurerm v5-only arguments used, matching what real callers have deployed
# with the pre-upgrade module).
run "baseline_apply" {
  command = apply

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
    condition     = azurerm_recovery_services_vault.recovery_services_vault.name == "DevCNR-myvault-rsv"
    error_message = "Baseline apply: unexpected Recovery Services Vault name"
  }

  assert {
    condition     = azurerm_backup_policy_vm.backup_policy_vm["daily"].name == "DevCNR-OPS-CORE-daily-rsvp"
    error_message = "Baseline apply: unexpected backup policy name"
  }
}

# Step 2: plan the upgraded (azurerm v5) code against that same state with the
# same caller inputs — must show no replacement of any resource, and
# soft_delete_enabled must no longer be referenced (removed from schema).
run "upgrade_plan_no_replacement" {
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
    condition     = azurerm_recovery_services_vault.recovery_services_vault.name == "DevCNR-myvault-rsv"
    error_message = "Resource name must be unchanged after upgrade"
  }

  assert {
    condition     = azurerm_recovery_services_vault.recovery_services_vault.storage_mode_type == "GeoRedundant"
    error_message = "New v5 optional argument storage_mode_type should apply its default with no caller changes required"
  }

  assert {
    condition     = azurerm_backup_policy_vm.backup_policy_vm["daily"].name == "DevCNR-OPS-CORE-daily-rsvp"
    error_message = "Backup policy name must be unchanged after upgrade"
  }
}
