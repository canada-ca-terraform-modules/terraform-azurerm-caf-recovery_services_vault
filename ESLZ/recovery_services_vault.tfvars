recovery_services_vaults = {
  # --- EXISTING ENTRY (unchanged) ---
  rsv = {
    # name = "" # Optional: Override the auto-generated vault name (default: {env4}CNR-{userDefinedString}-rsv)

    schedules = {
      daily = {
        # name = "" # Optional: Override the auto-generated backup policy name (default: {env}CNR-{group}_{project}-{key}-rsvp)

        timezone                       = "Eastern Standard Time"
        instant_restore_retention_days = 2
        # policy_type      = "V1"                  # (Optional) V1 or V2 (Enhanced Policy). Defaults to V1.
        # consistency_type = "OnlyCrashConsistent"  # (Optional) Only valid when policy_type = "V2".

        backup = {
          frequency = "Daily"
          time      = "23:00"
          # weekdays      = []   # (Optional) Used when frequency = "Weekly"
          # hour_interval = 4    # (Optional) Used when frequency = "Hourly". Possible values: 4, 6, 8, 12.
          # hour_duration = 4    # (Optional) Used when frequency = "Hourly". Must be a multiple of hour_interval.
        }

        retention_daily = {
          count = 7 # Minimum is now 7 (was 1) for new/updated backup policies as of the Azure API.
        }

        # retention_weekly = {
        #   count    = 5
        #   weekdays = ["Sunday"]
        # }

        # retention_monthly = {
        #   count             = 12
        #   weekdays          = ["Sunday"]  # Either weekdays+weeks OR days+include_last_days must be set
        #   weeks             = ["Last"]
        #   # days              = [1, 15]
        #   # include_last_days = false
        # }

        # retention_yearly = {
        #   count             = 12
        #   weekdays          = ["Sunday"]
        #   weeks             = ["Last"]
        #   months            = ["January"]
        #   # days              = [1]
        #   # include_last_days = false
        # }

        # instant_restore_resource_group = {
        #   prefix = "rg-instant-restore-"
        #   suffix = "rsv"
        # }

        # tiering_policy = {
        #   archived_restore_point = {
        #     mode          = "TierRecommended" # or "TierAfter"
        #     duration      = 30
        #     duration_type = "Days"
        #   }
        # }
      }
    }

    # --- NEW ARGUMENT EXAMPLES (azurerm >= 5.0, commented out) ---
    # public_network_access_enabled      = true            # (Optional) Defaults to true
    # storage_mode_type                  = "GeoRedundant"  # (Optional) GeoRedundant | LocallyRedundant | ZoneRedundant. Defaults to GeoRedundant.
    # cross_region_restore_enabled       = false           # (Optional) Only valid when storage_mode_type = GeoRedundant.
    # immutability                       = "Disabled"      # (Optional) Locked | Unlocked | Disabled
    # classic_vmware_replication_enabled = false            # (Optional) Changing this forces a new resource.

    # identity = {
    #   type         = "SystemAssigned" # SystemAssigned | UserAssigned | "SystemAssigned, UserAssigned"
    #   identity_ids = []               # Required when type includes UserAssigned
    # }

    # encryption = {
    #   key_id                             = ""    # (Required) Key Vault key id. Requires identity block above.
    #   infrastructure_encryption_enabled  = false
    #   user_assigned_identity_id          = null
    #   use_system_assigned_identity       = true
    # }

    # monitoring = {
    #   alerts_for_all_job_failures_enabled            = true
    #   alerts_for_all_failover_issues_enabled          = true
    #   alerts_for_all_replication_issues_enabled       = true
    #   alerts_for_critical_operation_failures_enabled  = true
    #   email_notifications_for_site_recovery_enabled   = true
    # }
  }
}
