# test_dependencies.tf
# Self-contained dependency resources, owned entirely by this harness.
#
# Deliberately NOT reusing any shared/production resource group: writing into
# a shared RG usually requires elevated, non-sandbox permissions. A dedicated
# throwaway RG here needs only Contributor on the sandbox subscription and
# can never collide with or affect any production resource.
#
# terraform-azurerm-caf-recovery_services_vault does not consume a
# virtual_network/subnet directly - no vnet dependency is created here.

resource "azurerm_resource_group" "live_test" {
  # PR-number suffix keeps two concurrently open PRs against this module from
  # colliding on the same sandbox resource group.
  name     = "${var.env}-caf-recovery-services-vault-live-test-${var.pr_number}-rg"
  location = var.location

  # pr-number tag: lets a nightly orphan sweeper find this RG by tag and
  # match it back to a PR, independent of naming convention.
  tags = {
    "pr-number" = var.pr_number
  }
}

locals {
  # terraform-azurerm-caf-recovery_services_vault expects
  # resource_group.Backups.{name,location} - a map keyed by RG "purpose".
  resource_group = {
    Backups = {
      name     = azurerm_resource_group.live_test.name
      location = azurerm_resource_group.live_test.location
    }
  }
}
